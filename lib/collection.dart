import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:ali_mobile_store/firebase_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // important
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:intl/intl.dart';
import 'Models/InstallmentStateModel.dart';
import 'constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Collection {
  BuildContext context;

  Collection(this.context) {
    al = AppLocalizations.of(context);
    localizationState = (al.localeName == 'ar') ? true : false;
  }

  FireStoreServices _fireStoreServices = FireStoreServices();
  AppLocalizations al;
  bool localizationState;
  ArabicNumbers arabicNumbers = ArabicNumbers();

  calculateAllPaidFromInstallmentsUntilKnow(InstallmentsModel model){
    int paidUntilKnow = 0;
    for (int i = 0; i < model.paymentRecord.length; i++) {
      if (model.paymentRecord[i] != null)
        paidUntilKnow += model.paymentRecord[i];

    }

    return paidUntilKnow;
  }

  int calculateBiggestPriceToPay(InstallmentsModel model , bool additionalProfitState) {

    int biggestPriceToPay = (model.restFromDeal + model.initialProfit) - calculateAllPaidFromInstallmentsUntilKnow(model);

    if (additionalProfitState)
      biggestPriceToPay = (model.restFromDeal + calculateProfitUntilKnow(model)) - calculateAllPaidFromInstallmentsUntilKnow(model);

    return biggestPriceToPay;
  }

  calculateAdditionalProfitOnly(InstallmentsModel model){
    return calculateProfit(model, false);
  }

  int calculateProfitUntilKnow(InstallmentsModel model){
    return calculateProfit(model, true);
  }

  // calculate additional profit from received date until know or from last installment date until know
  int calculateProfit(InstallmentsModel model, bool fromReceivedDate) {
    int lastIndexInThisInstallment = model.installmentPeriod -1;
    // get last installments date
    DateTime lastDateInThisInstallment = model.installmentsDates[lastIndexInThisInstallment];
    DateTime receivedDate = model.receivedDate;
    // determine starting date to calculate profit
    DateTime startDate;
    // determine the starting date to calculate the profit
    if (fromReceivedDate)
      startDate = receivedDate;
    else
      startDate = lastDateInThisInstallment;
    // add 2 days to last installment to calculate the profit from one day after ending installment
    startDate = DateTime(startDate.year,
        startDate.month, startDate.day + 1);
    // get current date
    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    // get date to calculate on it
    DateTime changingDate = startDate;

    DateTime thisDate = DateTime(startDate.year, startDate.month +1, startDate.day);
    int profitUntilKnow = 0;
    for (int i = 1;
         changingDate.isBefore(currentDate) ||
            changingDate == currentDate;
        i++) {

      int daysInThisMonth = thisDate.difference(changingDate).inDays;
      double monthProfit = (model.restFromDeal / 100) * 3;
      double dayProfit = monthProfit / daysInThisMonth;
      int passedDays;
      // check if this month is last month
      if (thisDate.isAfter(currentDate))
        passedDays = currentDate.difference(changingDate).inDays;
      else
        passedDays = thisDate.difference(changingDate).inDays;

      int profitForPassedDays = (dayProfit * passedDays).round();
      profitUntilKnow += profitForPassedDays;


      changingDate = DateTime(startDate.year, startDate.month +i, startDate.day);

      thisDate = DateTime(startDate.year, startDate.month +(i+1), startDate.day);

    }
    return profitUntilKnow;
  }

  checkPaymentValidate(InstallmentsModel model, String paid, bool additionalProfitState){
    int paidByClient;
    try{
      paidByClient = int.parse(paid);
    }catch(e){
      print('error here omar $paidByClient');
      return false;
    }

    if (paidByClient == 0 && paidByClient != calculateBiggestPriceToPay(model, additionalProfitState)){
      showSnackBar(al.youCantPayZeroInThisCase);
      return false;
    }

    if (paidByClient > calculateBiggestPriceToPay(model, additionalProfitState)){
      showSnackBar(al.thisAmountIsGreaterThanTerminationAmount);
      return false;
    }
      // return snackBar

     return true;
  }

  int calculatePastDaysForPayment(InstallmentsModel m) {
    InstallmentsModel model = m;
    int lastInstallmentIndex = model.installmentPeriod - 1;
    DateTime lastInstallmentDate =
        model.installmentsDates[lastInstallmentIndex];
    DateTime currentDate = DateTime.now();
    Duration difference = currentDate.difference(lastInstallmentDate);
    // i subtract one from past days because in don't want to calculate the day which the client will pay in it
    int pastDays = difference.inDays - 1;
    return pastDays;
  }

  Future installmentPayment(InstallmentsModel model, String paidByClientText, bool additionalProfitState) async {

    // check the value of paid by client is validate or not
    if (checkPaymentValidate(model, paidByClientText, additionalProfitState)){
      int paidByClientNum = int.parse(paidByClientText);
      InstallmentsModel result = calculatePayment(model, paidByClientNum, DateTime.now(),  additionalProfitState);

      result.paymentRecord.add(paidByClientNum);
      result.paymentRecordDates.add(DateTime.now());

      if (result.lastInstallment.contains(true))
        await _fireStoreServices.setCompleteInstallment(model);

      await _fireStoreServices.setClient(result);
    }

  }

  Future installmentPaymentToFinished(InstallmentsModel model, String paidByClientText, bool additionalProfitState) async{
    // validate if user is enter valid value;
    int paidByClientNum;
    try{
      paidByClientNum = int.parse(paidByClientText);
    }catch(e){
      showSnackBar('Invalid value');
      return;
    }
    // it must get biggest price to pay before payment to avoid mistakes
    int biggestPriceToPay = calculateBiggestPriceToPay(model, additionalProfitState);

    if (paidByClientNum == biggestPriceToPay){
      model = calculatePayment(model, paidByClientNum, DateTime.now(),  additionalProfitState);
      model.paymentRecord.add(paidByClientNum);
      model.paymentRecordDates.add(DateTime.now());
    }
    else if (paidByClientNum < biggestPriceToPay){
      int monthIndex = determineIndexForInstallmentShouldPaid(model);
      model = calculatePayment(model, paidByClientNum, DateTime.now(),  additionalProfitState);
      model.paymentRecord.add(paidByClientNum);
      model.paymentRecordDates.add(DateTime.now());
      model.lastInstallment.replaceRange(monthIndex, monthIndex +1, [true]);
      model.wasBiggestPriceToPayWhenFinished = biggestPriceToPay;
      model.finalProfit = getFinalProfit(model);
      model.additionalProfit = getAdditionalProfit(model);
      model.loseFromProfit = getLoseFromProfit(model);
      model.loseFromOriginalPhonePrice = calculateTheRestFromOriginalPhoneAmount(model);
      model.finished = true;

    }

    else {
      int monthIndex = determineIndexForInstallmentShouldPaid(model);
      model.paymentRecord.add(paidByClientNum);
      model.paymentRecordDates.add(DateTime.now());
      model.lastInstallment.replaceRange(monthIndex, monthIndex +1, [true]);
      model.wasBiggestPriceToPayWhenFinished = biggestPriceToPay;
      model.finalProfit = getFinalProfit(model);
      model.additionalProfit = getAdditionalProfit(model);
      model.loseFromProfit = getLoseFromProfit(model);
      model.loseFromOriginalPhonePrice = calculateTheRestFromOriginalPhoneAmount(model);
      model.finished = true;
    }

    await _fireStoreServices.setCompleteInstallment(model);
    await _fireStoreServices.setClient(model);
  }

  Future installmentPaymentForUpdate(InstallmentsModel model, bool additionalProfitState) async {
    int monthIndex = 0;
    List<InstallmentsModel> listOfModels = [];
    listOfModels.add(model);
    for (int i = monthIndex; i < listOfModels.last.paymentRecord.length; i++){
      DateTime oldDate = listOfModels.last.paymentRecordDates[i];
      int paidByClient =  listOfModels.last.paymentRecord[i];
      InstallmentsModel result = calculatePayment(listOfModels.last, paidByClient, oldDate, additionalProfitState);
      listOfModels.add(result);

      monthIndex = determineIndexForInstallmentShouldPaid(listOfModels.last);

    }
    await _fireStoreServices.setClient(listOfModels.last);

  }

  InstallmentsModel calculatePayment(InstallmentsModel model, int paidByClient, DateTime paymentDate, bool additionalProfitState){

    int biggestPriceToPay = calculateBiggestPriceToPay(model, additionalProfitState);
    int index = determineIndexForInstallmentShouldPaid(model);
    // get last index for installment
    int lastIndex = model.installmentPeriod - 1;
    // get all paid by client
    int allPaidByClient = calculateAllPaidFromInstallmentsUntilKnow(model);

    model.adjustmentTime = DateTime.now();

// if paid by client is equal to biggest price to pay
    if (paidByClient == biggestPriceToPay) {

      int restFromPaid = paidByClient;
      for (int nextIndex = index; restFromPaid > 0; nextIndex++){
        // if this installment is last one
        if (nextIndex == lastIndex) {
          model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
              [model.paidForEachInstallment[nextIndex] + restFromPaid]);
          model.paymentDates.replaceRange(nextIndex, nextIndex + 1, [paymentDate]);
          model.restFromInstallment.replaceRange(
              nextIndex, nextIndex + 1, [restFromPaid - model.finalPaidMonthly[nextIndex]]);
          model.completeInstallment.replaceRange(nextIndex, nextIndex + 1, [true]);
          model.finalPaidMonthly.replaceRange(
              nextIndex, nextIndex + 1, [restFromPaid]);
          model.lastInstallment.replaceRange(nextIndex, nextIndex +1, [true]);
          model.finalProfit = allPaidByClient - model.phonePrice;
          restFromPaid = 0;
        }
        // if the rest from paid is bigger than or equal to biggest price to pay
        else if (restFromPaid >= model.finalPaidMonthly[nextIndex]) {
          model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
              [model.paidForEachInstallment[nextIndex] + model.finalPaidMonthly[nextIndex]]);
          model.paymentDates.replaceRange(nextIndex, nextIndex + 1, [paymentDate]);
          model.completeInstallment.replaceRange(nextIndex, nextIndex + 1, [true]);
          restFromPaid -= model.finalPaidMonthly[nextIndex];
          // this line must be after calculate the new value of rest from paid
          model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1, [0]);
          model.lastInstallment.replaceRange(nextIndex, nextIndex +1, [true]);
        }
        // if the rest from paid is less than biggest price to pay
        else if (restFromPaid < biggestPriceToPay){
          model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
              [model.paidForEachInstallment[nextIndex] + restFromPaid]);
          model.paymentDates.replaceRange(nextIndex, nextIndex + 1, [paymentDate]);
          model.completeInstallment.replaceRange(nextIndex, nextIndex + 1, [true]);
          model.finalPaidMonthly.replaceRange(
              nextIndex, nextIndex + 1, [model.finalPaidMonthly[nextIndex] - restFromPaid]);
          restFromPaid = 0;
        }

        if (restFromPaid == 0){
          model.completeInstallment.replaceRange(nextIndex, nextIndex +1, [true]);
          model.lastInstallment.replaceRange(nextIndex, nextIndex +1, [true]);
          model.finalProfit = allPaidByClient - model.phonePrice;
        }
      }
    }

// if this month is last month
    else if (index == lastIndex) {
      model.paidForEachInstallment.replaceRange(index, index + 1,
          [model.paidForEachInstallment[index] + paidByClient]);
      model.paymentDates.replaceRange(index, index + 1, [paymentDate]);
      model.restFromInstallment.replaceRange(
          index, index + 1, [model.finalPaidMonthly[index] - paidByClient]);
      // if paid by client is equal to biggest price to pay with additional profit or not
      if (paidByClient == biggestPriceToPay) {
        model.completeInstallment.replaceRange(index, index + 1, [true]);
        model.lastInstallment.replaceRange(index, index +1, [true]);
        model.lastInstallment.last = true;
        model.finalProfit = allPaidByClient - model.phonePrice;
        // if paid by client is less than biggest price to pay with additional profit or not
      }
      else if (paidByClient < biggestPriceToPay) {
        model.finalPaidMonthly.replaceRange(
            index, index + 1, [model.finalPaidMonthly[index] - paidByClient]);
      }
      // if paid by client is more than  biggest price to pay with additional profit or not
      else{
        var al = AppLocalizations.of(context);
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          SnackBar(
            backgroundColor: darkRedColor,
            content: Text(
              al.thisAmountIsGreaterThanTerminationAmount,
              style: TextStyle(fontSize: fourteenDimen),
            ),
          ),
        );
      }
    }

// if paid by client is equal to what should paid this month
    else if (paidByClient == model.finalPaidMonthly[index]) {
      model.paidForEachInstallment.replaceRange(index, index + 1,
          [model.paidForEachInstallment[index] + paidByClient]);
      model.paymentDates.replaceRange(index, index + 1, [paymentDate]);
      model.completeInstallment.replaceRange(index, index + 1, [true]);
      model.finalPaidMonthly.replaceRange(index, index + 1, [0]);
    }

// if client paid less than what should paid this month
// this condition paidByClient > 0 is necessary here
    else if (paidByClient < model.finalPaidMonthly[index] && paidByClient > 0) {
      model.paidForEachInstallment.replaceRange(index, index + 1,
          [model.paidForEachInstallment[index] + paidByClient]);
      model.paymentDates.replaceRange(index, index + 1, [paymentDate]);
      model.finalPaidMonthly.replaceRange(
          index, index + 1, [model.finalPaidMonthly[index] - paidByClient]);
    }

// if client paid more than what should paid this month
    else if (paidByClient > model.finalPaidMonthly[index]) {
      int restFromPaid = paidByClient;
      for (int nextIndex = index; restFromPaid > 0; nextIndex++) {

        // if this month is last month
        if (nextIndex == lastIndex) {

          // if the rest from paid is equal to what should be paid in last month
          if (restFromPaid == biggestPriceToPay) {
            model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
                [model.paidForEachInstallment[nextIndex] + restFromPaid]);
            model.paymentDates
                .replaceRange(nextIndex, nextIndex + 1, [paymentDate]);
            model.completeInstallment
                .replaceRange(nextIndex, nextIndex + 1, [true]);
            model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1, [0]);
            model.lastInstallment.replaceRange(nextIndex, nextIndex +1, [true]);
            model.finalProfit = allPaidByClient - model.phonePrice;
            restFromPaid = 0;
          }
          // if paid by client is less than what should be paid in last month
          else if (restFromPaid < biggestPriceToPay) {
            model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
                [model.paidForEachInstallment[nextIndex] + restFromPaid]);
            model.paymentDates
                .replaceRange(nextIndex, nextIndex + 1, [paymentDate]);
            model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1,
                [model.finalPaidMonthly[nextIndex] - restFromPaid]);
            restFromPaid = 0;
          }
          // if the rest from paid is bigger than expected in last month
          else {
            var al = AppLocalizations.of(context);
            final scaffold = ScaffoldMessenger.of(context);
            scaffold.showSnackBar(
              SnackBar(
                backgroundColor: darkRedColor,
                content: Text(
                  al.thisAmountIsGreaterThanTerminationAmount,
                  style: TextStyle(fontSize: fourteenDimen),
                ),
              ),
            );
          }

        }

        // if rest from paid by client is bigger than which paid this month
        else if (restFromPaid > model.finalPaidMonthly[nextIndex]) {
          model.paidForEachInstallment.replaceRange(
              nextIndex, nextIndex + 1, [model.paidMonthlyDeal[nextIndex]]);
          model.paymentDates
              .replaceRange(nextIndex, nextIndex + 1, [paymentDate]);
          model.completeInstallment
              .replaceRange(nextIndex, nextIndex + 1, [true]);
          restFromPaid -= model.finalPaidMonthly[nextIndex];
          // this line must be after
          model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1, [0]);

        }

        else if (restFromPaid < model.finalPaidMonthly[nextIndex]) {
          model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
              [model.paidForEachInstallment[nextIndex] + restFromPaid]);
          model.paymentDates
              .replaceRange(nextIndex, nextIndex + 1, [paymentDate]);
          model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1,
              [model.finalPaidMonthly[nextIndex] - restFromPaid]);
          restFromPaid = 0;
        }

        // check if rest from paid is equal to this installment price
        else {
          model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1, [0]);
          model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
              [model.finalPaidMonthly[nextIndex]]);
          model.paymentDates.replaceRange(nextIndex, nextIndex + 1, [paymentDate]);
          model.completeInstallment.replaceRange(nextIndex, nextIndex + 1, [true]);
          model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1, [0]);
          restFromPaid = 0;
        }
      }
    }

    return model;

  }

  determineIndexForInstallmentShouldPaid(InstallmentsModel model){
    for (int i = 0; i < model.installmentPeriod; i++){
      if (model.completeInstallment[i] == false)
        return i;
    }

    // return last index if user take additional profit from client to add this profit to paid for each installment
    return model.installmentPeriod -1;
  }

  int calculateTheRestFromOriginalPhoneAmount(InstallmentsModel model){
    if (calculateAllPaidFromInstallmentsUntilKnow(model) >= model.restFromDeal)
      return 0;
    int rest = model.restFromDeal - calculateAllPaidFromInstallmentsUntilKnow(model);
    return rest;
  }

  int getFinalProfit(InstallmentsModel model){
    if (calculateTheRestFromOriginalPhoneAmount(model) > 0)
      return 0;

    return calculateAllPaidFromInstallmentsUntilKnow(model) - model.restFromDeal;

  }

  int getLoseFromProfit(InstallmentsModel model){
    int allPaidAndShouldPaidBeforeLastTime = (calculateAllPaidFromInstallmentsUntilKnow(model) - model.paymentRecord.last) + model.wasBiggestPriceToPayWhenFinished;

    if (allPaidAndShouldPaidBeforeLastTime > calculateAllPaidFromInstallmentsUntilKnow(model))
      return calculateAllPaidFromInstallmentsUntilKnow(model) - allPaidAndShouldPaidBeforeLastTime;

    return 0;
  }

  getAdditionalProfit(InstallmentsModel model){
    int allPaidAndShouldPaidBeforeLastTime = (calculateAllPaidFromInstallmentsUntilKnow(model) - model.paymentRecord.last) + model.wasBiggestPriceToPayWhenFinished;
    if (getLoseFromProfit(model) == 0 && calculateAllPaidFromInstallmentsUntilKnow(model) > allPaidAndShouldPaidBeforeLastTime)
      return calculateAllPaidFromInstallmentsUntilKnow(model) - allPaidAndShouldPaidBeforeLastTime;

    return 0;
  }

  int calculateRestFromInitProfit(InstallmentsModel model, additionalProfitState){
    if (calculateTheRestFromOriginalPhoneAmount(model) > 0)
      return model.initialProfit;

    int rest = (model.restFromDeal + model.initialProfit) - calculateAllPaidFromInstallmentsUntilKnow(model);
    return rest;
  }

  int calculateRestFromProfitUntilKnow(InstallmentsModel model, bool additionalProfitState){
    if (calculateTheRestFromOriginalPhoneAmount(model) == 0){
      return (calculateProfitUntilKnow(model) + model.restFromDeal) - calculateAllPaidFromInstallmentsUntilKnow(model);
    }
    else if (additionalProfitState)
      return calculateProfitUntilKnow(model);
    else
      return model.initialProfit;
  }

  bool determineFinalPaidVisibility(InstallmentsModel model, int monthIndex) {
    // check if paid monthly deal is equal to final paid monthly in instance model or not
    int paidInDeal = model.paidMonthlyDeal[monthIndex];
    int finalPaid = model.finalPaidMonthly[monthIndex];
    if (paidInDeal == finalPaid || finalPaid == 0)
      return false;
    else
      return true;
  }

  showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: redColor,
        content: Text(message, style: TextStyle(color: offWhiteColor),),
      )
    );
  }

  String dateFormat(DateTime dateTime) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    // check app language to determine the date format
    if (localizationState) {
      List<String> numbersOfDate = convertNumbers(dateFormat.format(dateTime))
          .toString()
          .split('-')
          .reversed
          .toList();

      String numbersOfDateToString = numbersOfDate.toString().substring(1, 13);
      numbersOfDateToString = numbersOfDateToString.replaceAll(',', '-');
      return numbersOfDateToString;
    }
    return dateFormat.format(dateTime);
  }

  String dayFormat(DateTime dateTime) {
    // check app language to determine the date format
    DateFormat dateFormat =
        (localizationState) ? DateFormat.EEEE('ar_SA') : DateFormat('EEEE');
    String date = convertNumbers(dateFormat.format(dateTime)).toString();
    return date;
  }

  InstallmentStateModel determineInstallmentState(InstallmentsModel model){
    return determineInstallmentStateInMonth(model, null);
  }

  determineInstallmentStateInMonth(InstallmentsModel model, int monthIndex){

    if (monthIndex == null)
      monthIndex = determineIndexForInstallmentShouldPaid(model);

    DateFormat format = DateFormat('yyyy-MM-dd');
    // determine installment date variable to make filter in easy way
    DateTime installmentDate = model.installmentsDates[monthIndex];
    int installmentYear = installmentDate.year;
    int installmentMonth = installmentDate.month;
    int installmentDay = installmentDate.day;

    // determine dateScale variable to make filter in easy way
    DateTime dateScale = model.installmentsDates[monthIndex];
    dateScale = dateScale.add(Duration(days: 1));
    int yearScale = dateScale.year;
    int monthScale = dateScale.month;
    int dayScale = dateScale.day;

    // get current date
    DateTime currentDate = DateTime.now();
    currentDate = DateTime.parse(format.format(currentDate));
    int currentYear = currentDate.year;
    int currentMonth = currentDate.month;
    int currentDay = currentDate.day;

    // return true if  this installment is canceled and the installment is finished
    if (model.completeInstallment[monthIndex] == false && model.lastInstallment.contains(true)){
      return InstallmentStateModel(state: al.canceled, borderColor: darkGreenColor, fillColor: lightGreenColor);
    }
    // return true if this installment is complete
    else if (model.completeInstallment[monthIndex])
      return InstallmentStateModel(state: al.paid, borderColor: offWhiteColor, fillColor: darkGreenColor);
    // return true if this installment should paid today
    else if (installmentYear == currentYear &&
        installmentMonth == currentMonth &&
        installmentDay == currentDay)
      return InstallmentStateModel(state: al.today, borderColor: darkYellowColor, fillColor: lightYellowColor);
    // return true if this installment date has missed
    else if (yearScale == currentYear &&
        monthScale == currentMonth &&
        dayScale == currentDay ||
        currentDate.isAfter(dateScale))
      return InstallmentStateModel(state: al.late, borderColor: darkRedColor, fillColor: lightRedColor);
    // else this installment date has not yet come
    else
      return InstallmentStateModel(state: al.next, borderColor: darkGreenColor, fillColor: offWhiteColor);
  }

  determineLateReceivables(InstallmentsModel model, bool additionalProfitState) {
    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    int lateReceivables = 0;
    for (int i = 0; i < model.installmentPeriod; i++) {
      if (model.completeInstallment[i] == false) {
        if (model.installmentsDates[i] == currentDate ||
            currentDate.isAfter(model.installmentsDates[i]))
          lateReceivables += model.finalPaidMonthly[i];
      }
    }

    if (additionalProfitState)
      lateReceivables += calculateAdditionalProfitOnly(model);

    return lateReceivables;
  }

  checkConnectivity() async{
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  String convertNumbers(dynamic num) {
    if (al.localeName == 'ar')
      return arabicNumbers.convert(num.toString());

    return num.toString();
  }
}
