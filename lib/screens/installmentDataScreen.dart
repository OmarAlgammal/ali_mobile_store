import 'package:ali_mobile_store/collection.dart';
import 'package:ali_mobile_store/dataBase/installmentsDatabase.dart';
import 'package:ali_mobile_store/firebase_services.dart';
import 'package:ali_mobile_store/widgets/InstallmentsListWidget.dart';
import 'package:ali_mobile_store/widgets/sharedLoadingWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import 'dart:ui' as ui;
import '../dataBase/installmentDataModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // important

class InstallmentsDataScreen extends StatefulWidget {

  final String installmentId;
  final String foreStoreCollectionName;
  InstallmentsDataScreen({this.installmentId, this.foreStoreCollectionName});

  @override
  _InstallmentsDataScreenState createState() => _InstallmentsDataScreenState();
}

class _InstallmentsDataScreenState extends State<InstallmentsDataScreen> {
  InstallmentsDatabase database;

  Collection collection;

  FireStoreServices fireStoreServices = FireStoreServices();

  InstallmentsModel model;

  AppLocalizations al;

  DateTime _dateTime = DateTime.now();

  int _phonePrice, _advancedAmount, _installmentPeriod;

  final _globalKey = GlobalKey<FormState>();

  final _clientNameKey = GlobalKey<FormFieldState>();

  final _clientNumberKey = GlobalKey<FormFieldState>();

  final _clientIdKey = GlobalKey<FormFieldState>();

  final _guarantorNameKey = GlobalKey<FormFieldState>();

  final _guarantorNumberKey = GlobalKey<FormFieldState>();

  final _guarantorIdKey = GlobalKey<FormFieldState>();

  final _brandKey = GlobalKey<FormFieldState>();

  final _phoneNameKey = GlobalKey<FormFieldState>();

  final _phonePriceKey = GlobalKey<FormFieldState>();

  final _advancedAmountKey = GlobalKey<FormFieldState>();

  final _installmentPeriodKey = GlobalKey<FormFieldState>();

  String _selectedBrand;

  String _selectedPhone;

  TextEditingController clientNameController = TextEditingController();

  TextEditingController clientNumberController = TextEditingController();

  TextEditingController clientIdController = TextEditingController();

  TextEditingController guarantorNameController = TextEditingController();

  TextEditingController guarantorNumberController = TextEditingController();

  TextEditingController guarantorIdController = TextEditingController();

  TextEditingController brandNameController = TextEditingController();

  TextEditingController phoneNameController = TextEditingController();

  TextEditingController phonePriceController = TextEditingController();

  TextEditingController advancedAmountController = TextEditingController();

  TextEditingController installmentPeriodController = TextEditingController();

  TextEditingController theRestController = TextEditingController();

  TextEditingController theProfitController = TextEditingController();

  TextEditingController paidMonthlyController = TextEditingController();

  TextEditingController receivedDateController = TextEditingController();


  int _currentYear;
  int _nextInstallmentNum;


  @override
  void initState() {
    super.initState();
    getCurrentYearAndNextNum();
  }

  Future getCurrentYearAndNextNum() async{
    _currentYear = await fireStoreServices.getCurrentYear();
    _nextInstallmentNum = await fireStoreServices.getNextInstallmentNum();
  }

  String getNextInstallmentId(){
    String nextInstallmentId = '$_nextInstallmentNum-$_currentYear';
    return nextInstallmentId;
  }

  @override
  Widget build(BuildContext context) {

    collection = Collection(context);
    al = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: offWhiteColor,
        body: (widget.installmentId == null)? listViewWidget(): streamWidgetForUpdating(),
      ),
    );
  }

  listViewWidget() {
    return ListView(
      shrinkWrap: true,
      children: [
        appBar(al.installmentData),
        form(),
        buttonsWidget(),
      ],
    );
  }

  streamWidgetForUpdating(){
    return StreamBuilder<QuerySnapshot>(
      stream: fireStoreServices.getClient(widget.installmentId, widget.foreStoreCollectionName),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> querySnapshot){
        if (querySnapshot.hasError) return Center(child: Text('something went wrong'));
        if (querySnapshot.connectionState == ConnectionState.waiting)
          return Text('loading');
        if (querySnapshot.data.docs.length == 0)
          return Center(child: ListIsEmptyWidget(al.installmentsListIsEmpty));

        QueryDocumentSnapshot documentSnapshot = querySnapshot.data.docs[0];
        Map<String, dynamic> map = documentSnapshot.data();
        model = InstallmentsModel.toObject(map);

        return ListView(
          shrinkWrap: true,
          children: [
            appBar(al.updateInstallmentData),
            formForUpdating(),
            buttonsWidget(),
          ],
        );
      });
  }

  buttonsWidget(){
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        children: [
// show button
          Expanded(
            flex: 1,
            child: Center(
              child: TextButton(
                  onPressed: showButtonCheck,
                  child: Text(
                    al.show,
                    style: TextStyle(
                        color: darkGreenColor, fontSize: eighteenDimen),
                  )),
            ),
          ),
// save button
          Expanded(
            flex: 1,
            child: Center(
              child: TextButton(
                  onPressed: () async{
                    (widget.installmentId != null)
                        ? await saveButtonForUpdating()
                        : saveButton();
                  },
                  child: Text(
                    al.save,
                    style: TextStyle(
                        color: darkGreenColor, fontSize: eighteenDimen),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  appBar(String title) {
    return Container(
      child: AppBar(
          automaticallyImplyLeading: false,
          elevation: zeroDimen,
          toolbarHeight: barDimen,
          backgroundColor: transparentColor,
          title: Align(
            alignment: (AppLocalizations.of(context).localeName == 'ar')
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: darkGreenColor),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headline6
                ),
              ),
            ),
          )),
    );
  }

  determineUpdatability() {
    // get all paid by client
    int allPaidByClient = 0;
    for (int i = 1; i < getUpdatedInstallment().paymentRecord.length; i++) {
      allPaidByClient += getUpdatedInstallment().paymentRecord[i];
    }

    int biggestPriceToPay =
        collection.calculateBiggestPriceToPay(getUpdatedInstallment(), true);
    int sumOfProfitAndTheRestInUpdate =
        getUpdatedInstallment().initialProfit + getUpdatedInstallment().restFromDeal;

    // check if biggest price to pay is more than zero to ensure that the client did not paid more than biggest price to pay (look at collection >> biggestPriceToPay() for more details)
    if (allPaidByClient <= sumOfProfitAndTheRestInUpdate &&
        biggestPriceToPay > 0)
      return true;
    else if (allPaidByClient >= sumOfProfitAndTheRestInUpdate) {
      showSnackBar(al.amountPaidIsBiggerThanRequiredOne, darkRedColor);
      return false;
    } else if (allPaidByClient >= biggestPriceToPay) {
      showSnackBar(al.amountPaidIsBiggerThanRequiredTwo, darkRedColor);
      return false;
    }

    return false;
  }

  showButtonCheck() {
    if (_phonePriceKey.currentState.validate() &
        _advancedAmountKey.currentState.validate() &
        _installmentPeriodKey.currentState.validate()) {
      theRestController.text = getTheRestFromDeal().toString();
      theProfitController.text = getInitialProfit().toString();
      paidMonthlyController.text = paidMonthlyToString();
      receivedDateController.text = receivedDateToString();
    }
  }

  // return true if user make any changes in installments data
  isInstallmentUpdated(){
    if (model.clientName == getClientName() &&
    model.clientNum == getClientNumber()&&
    model.clientId == getClientId()&&
    model.guarantorName == getGuarantorName()&&
    model.guarantorNum == getGuarantorNumber()&&
    model.guarantorId == getGuarantorId()&&
    model.phonePrice == getPhonePrice()&&
    model.advancedAmount == getAdvancedAmount()&&
    model.installmentPeriod == getInstallmentPeriod()&&
    model.receivedDate == getReceivedDate())
      return false;

    return true;
  }

  saveButton() async{
    var result = await collection.checkConnectivity();
    // check if user is offline
    if (result == false)
      return showSnackBar(al.youCanNotAddAInstallmentWhenYouAreOffline, darkRedColor);

    if (_globalKey.currentState.validate()
    )
    {
      theRestController.text = getTheRestFromDeal().toString();
      theProfitController.text = getInitialProfit().toString();
      paidMonthlyController.text = paidMonthlyToString();

      await fireStoreServices.setClient(getInstallment()).then((value) => Navigator.pop(context));
    }
  }

  saveButtonForUpdating() async {
    var result = await collection.checkConnectivity();
    // check if user is offline
    if (result == false)
      return showSnackBar(al.youAreOffline, darkRedColor);

    if (_globalKey.currentState.validate() &&
        determineUpdatability()) {

      theRestController.text = getTheRestFromDeal().toString();
      theProfitController.text = getInitialProfit().toString();
      paidMonthlyController.text = paidMonthlyToString();
      receivedDateController.text = receivedDateToString();

      if (isInstallmentUpdated() == true){
        print('yes it is true');
        await collection.installmentPaymentForUpdate(getUpdatedInstallment(), true).then((value) => Navigator.pop(context));
      }else
        Navigator.pop(context, model);
    }
  }

  getInstallment() {
    return InstallmentsModel(
        getNextInstallmentId(),
        _nextInstallmentNum,
        getClientName(),
        getClientNumber(),
        getClientId(),
        getGuarantorName(),
        getGuarantorNumber(),
        getGuarantorId(),
        getBrandName(),
        getPhoneName(),
        getPhonePrice(),
        getAdvancedAmount(),
        getInstallmentPeriod(),
        getTheRestFromDeal(),
        getInitialProfit(),
        getPaidMonthlyDeal(),
        getReceivedDate(),
        getInstallmentDates(),
        getPaymentRecord(),
        getPaymentRecordDates(),
        getPaidForEachInstallment(),
        getPaymentDates(),
        getTheRestFromInstallment(),
        getFinalPaidMonthly(),
        getCompleteInstallment(),
        getAdjustmentDate(),
        getLastInstallment(),
        getFinalProfit(),
        0, // additionalProfit
        0, // lose from final profit
        0, // rest form original phone price
        false, // finished
        0, // was biggest price to pay
    );
  }

  getUpdatedInstallment() {
    InstallmentsModel updatedModel = InstallmentsModel(
      // don't forget to get installment id from model
      model.installmentId,
      model.installmentNum,
      getClientName(),
      getClientNumber(),
      getClientId(),
      getGuarantorName(),
      getGuarantorNumber(),
      getGuarantorId(),
      brandNameController.text,
      phoneNameController.text,
      getPhonePrice(),
      getAdvancedAmount(),
      getInstallmentPeriod(),
      getTheRestFromDeal(),
      getInitialProfit(),
      getPaidMonthlyDeal(),
      getReceivedDate(),

      getInstallmentDates(),
      model.paymentRecord,//
      model.paymentRecordDates,//
      getPaidForEachInstallment(),
      getPaymentDates(),
      getTheRestFromInstallment(),
      getFinalPaidMonthly(),
      getCompleteInstallment(),
      getAdjustmentDate(),
      getLastInstallment(),
      getFinalProfit(),
      model.additionalProfit,
      model.loseFromProfit,
      model.loseFromOriginalPhonePrice,
      model.finished,
      model.wasBiggestPriceToPayWhenFinished,
    );

    return updatedModel;
  }

  int toInt(num) => int.parse(num);

  String getClientName() => clientNameController.text;

  int getClientNumber() => int.parse(clientNumberController.text);

  int getClientId() => int.parse(clientIdController.text);

  String getGuarantorName() => guarantorNameController.text;

  int getGuarantorNumber() => int.parse(guarantorNumberController.text);

  int getGuarantorId() => int.parse(guarantorIdController.text);

  String getBrandName() => _selectedBrand.toString();

  String getPhoneName() => _selectedPhone.toString();

  int getPhonePrice() => int.parse(phonePriceController.text);

  int getAdvancedAmount() => int.parse(advancedAmountController.text);

  int getInstallmentPeriod() => int.parse(installmentPeriodController.text);

  int getTheRestFromDeal() {
    _phonePrice = toInt(phonePriceController.text);
    _advancedAmount = toInt(advancedAmountController.text);
    return _phonePrice - _advancedAmount;
  }

  int getInitialProfit() {
    _installmentPeriod = toInt(installmentPeriodController.text);
    int theRest = getPhonePrice() - getAdvancedAmount();
    int profit = ((theRest / 100) * 3 * getInstallmentPeriod()).round();
    return profit;
  }

  List<int> getPaidMonthlyDeal() {
    int restAndProfit = getTheRestFromDeal() + getInitialProfit();
    double paidMonthlyWithFractions = (restAndProfit / _installmentPeriod);
    double fractions = (paidMonthlyWithFractions % 10);
    int paidMonthly = (paidMonthlyWithFractions - fractions).round();
    List<int> paidMonthlyList = <int>[];
    // if there is no fractions
    if (fractions == 0) {
      for (int i = 0; i < _installmentPeriod; i++) {
        paidMonthlyList.add(paidMonthly);
      }
    } else {
      for (int i = 0; i < _installmentPeriod; i++) {
        // if this the first installment
        if (i == 0) {
          // add all fractions to first installment
          paidMonthlyList
              .add(paidMonthly + (fractions * _installmentPeriod).round());
        } else {
          paidMonthlyList.add(paidMonthly);
        }
      }
    }
    return paidMonthlyList;
  }

  String paidMonthlyToString() {
    // if there is a fractions
    if (getInstallmentPeriod() > 1) {
      if (getPaidMonthlyDeal()[0] != getPaidMonthlyDeal()[1]) {
        return 'شهر * ${getPaidMonthlyDeal()[0]} و ${_installmentPeriod - 1} شهور * ${getPaidMonthlyDeal()[1]}';
      }
    }
    return getPaidMonthlyDeal()[0].toString();
  }

  DateTime getReceivedDate() {
    try {
      DateTime dateParsed = DateTime.parse(receivedDateController.text);
      return dateParsed;
    } catch (e) {
      return _dateTime;
    }
  }

  String receivedDateToString() {
    // this format must be like this 'yyyy-MM-dd' don't do this 'yyyy/MM/ddd'
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    return dateFormat.format(getReceivedDate());
  }

  List<DateTime> getInstallmentDates() {
    List<DateTime> list = <DateTime>[];
    DateTime date = getReceivedDate();
    int dayReceived = date.day;
    int daysOfTheMonth = DateUtils.getDaysInMonth(date.year, date.month);
    // if client will buy a device in last day in the month
    if (dayReceived == daysOfTheMonth) {
      for (int i = 0; i < getInstallmentPeriod(); i++) {
        // add one day to date to become in the next month
        date = date.add(Duration(days: 1));
        // get first day in the new month
        int firstDayOfMonth = date.day;
        // get last day in the new month
        int lastDayOfMonth = DateUtils.getDaysInMonth(date.year, date.month);
        // add the difference between first and last day to get last day in the month and become the date of paying off
        date = date.add(Duration(days: (lastDayOfMonth - firstDayOfMonth)));
        list.add(date);
      }
    } else {
      // i must start from 1 because it's mean a month
      for (int i = 1; i <= getInstallmentPeriod(); i++) {
        date = DateTime(getReceivedDate().year, getReceivedDate().month + i,
            getReceivedDate().day);
        list.add(date);
      }
    }
    return list;
  }

  List<DateTime> getPaymentDates() {
    List<DateTime> list = <DateTime>[];
    for (int i = 0; i < getInstallmentPeriod(); i++) {
      list.add(null);
    }
    return list;
  }

  List<int> getPaidForEachInstallment() {
    List<int> list = <int>[];
    for (int i = 0; i < getInstallmentPeriod(); i++) {
      list.add(0);
    }
    return list;
  }

  List<int> getFinalPaidMonthly() {
    return getPaidMonthlyDeal();
  }

  List<int> getPaymentRecord() {
    List<int> list = <int>[];
    list.add(0);
    return list;
  }

  List<DateTime> getPaymentRecordDates() {
    List<DateTime> list = <DateTime>[];
    list.add(DateTime.now());
    return list;
  }

  List<int> getTheRestFromInstallment() {
    List<int> list = <int>[];
    for (int i = 0; i < getInstallmentPeriod(); i++) {
      list.add(null);
    }
    return list;
  }

  List<bool> getCompleteInstallment() {
    List<bool> list = <bool>[];
    for (int i = 0; i < _installmentPeriod; i++) {
      list.add(false);
    }
    return list;
  }

  List<bool> getLastInstallment() {
    List<bool> list = <bool>[];
    for (int i = 0; i < _installmentPeriod; i++) {
      list.add(false);
    }
    return list;
  }

  int getFinalProfit() {
    return null;
  }

  DateTime getAdjustmentDate() {
    return _dateTime;
  }

  showSnackBar(String content, Color backgroundColor){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor,
          content: Text(content),
        )
    );

  }

  form() {
    return Form(
      key: _globalKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
// client name form
            TextFormField(
              textDirection: (al.localeName == 'ar')
                  ? ui.TextDirection.rtl
                  : ui.TextDirection.ltr,
              key: _clientNameKey,
              controller: clientNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return al.clientNamePlease;
                }
                return null;
              },
              keyboardType: TextInputType.name,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.clientName,
                prefixIcon: Icon(nameIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),

                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// client number form
            TextFormField(
              key: _clientNumberKey,
              controller: clientNumberController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return al.clientNumberPlease;
                return null;
              },
              maxLength: 11,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.clientNumber,
                prefixIcon: Icon(numberIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// client id form
            TextFormField(
              key: _clientIdKey,
              controller: clientIdController,
              validator: (value) {
                if (clientIdController.text.toString().startsWith('0') ==
                    false) {
                  if (value.length != 14) return al.clientIdPlease;
                }
                return null;
              },
              keyboardType: TextInputType.number,
              maxLength: 14,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.clientId,
                prefixIcon: Icon(idCardIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// guarantor name form
            TextFormField(
              key: _guarantorNameKey,
              controller: guarantorNameController,
              validator: (value) {
                if (value.isEmpty || value == null)
                  return al.guarantorNamePlease;
                return null;
              },
              keyboardType: TextInputType.name,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.guarantorName,
                prefixIcon: Icon(nameIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// guarantor number form
            TextFormField(
              key: _guarantorNumberKey,
              controller: guarantorNumberController,
              keyboardType: TextInputType.number,
              maxLength: 11,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return al.guarantorNumberPlease;
                return null;
              },
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.guarantorNumber,
                prefixIcon: Icon(numberIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// guarantor id form
            TextFormField(
              key: _guarantorIdKey,
              controller: guarantorIdController,
              maxLength: 14,
              validator: (value) {
                if (guarantorIdController.text.startsWith('0') == false) {
                  if (value.length != 14) al.guarantorIdPlease;
                }
                return null;
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.guarantorId,
                prefixIcon: Icon(idCardIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// phone brand drop down button
            DropdownButtonFormField<String>(
              key: _brandKey,
              value: _selectedBrand,
              validator: (value) {
                if (value == null) return al.brandPlease;
                return null;
              },
              onChanged: (value) {
                _selectedBrand = value;
              },
              decoration: InputDecoration(
                labelText: al.brandName,
                prefixIcon: Icon(brandIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
              focusColor: darkGreenColor,
              items: ['OPPO', 'Vivo', 'Samsnug']
                  .map((String value) => DropdownMenuItem(
                        child: Text(value),
                        value: value,
                      ))
                  .toList(),
            ),
// phone name form
            DropdownButtonFormField<String>(
              key: _phoneNameKey,
              value: _selectedPhone,
              validator: (value) {
                if (value == null) return al.phoneName;
                return null;
              },
              onChanged: (value) {
                _selectedPhone = value;
              },
              decoration: InputDecoration(
                labelText: al.phoneName,
                prefixIcon: Icon(phoneNameIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
              focusColor: darkGreenColor,
              items: ['Y12s', 'Y20', 'V21e']
                  .map((String value) => DropdownMenuItem(
                        child: Text(value),
                        value: value,
                      ))
                  .toList(),
            ),
// phone price form
            TextFormField(
              key: _phonePriceKey,
              controller: phonePriceController,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return al.phonePricePlease;
                // check if phone price < 0
                else if (int.parse(value.toString()) < 0)
                  return al.phonePriceCant;
                return null;
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.phonePrice,
                prefixIcon: Icon(phonePriceIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// advanced amount form
            TextFormField(
              key: _advancedAmountKey,
              controller: advancedAmountController,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return al.advancedAmount;
                // check if advanced amount < 0
                else if (int.parse(value.toString()) < 0)
                  return al.advancedAmountCant;
                return null;
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.advancedAmount,
                prefixIcon: Icon(advancedAmountIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// installment period form
            TextFormField(
              key: _installmentPeriodKey,
              controller: installmentPeriodController,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return al.installmentPeriodPlease;
                // check if installment period < 0
                else if (int.parse(value.toString()) < 0)
                  return al.installmentPeriodCant;
                return null;
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.installmentPeriod,
                prefixIcon: Icon(installmentPeriodIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// the rest form
            TextFormField(
              controller: theRestController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.theRest,
                prefixIcon: Icon(restIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// profit form
            TextFormField(
              controller: theProfitController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.theProfit,
                prefixIcon: Icon(profitIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// paid monthly form
            TextFormField(
              controller: paidMonthlyController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.paidMonthly,
                prefixIcon: Icon(paidMonthlyIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// received date form
            TextFormField(
              controller: receivedDateController,
              keyboardType: TextInputType.datetime,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.receivedDate,
                labelStyle: TextStyle(color: greenColor),
                floatingLabelStyle: TextStyle(color: darkGreenColor),
                prefixIcon: Icon(receivedDateIcon,),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  formForUpdating() {
    return Form(
      key: _globalKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
// client name form
            TextFormField(
              textDirection: (al.localeName == 'ar')
                  ? ui.TextDirection.rtl
                  : ui.TextDirection.ltr,
              key: _clientNameKey,
              controller: clientNameController..text = model.clientName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return al.clientNamePlease;
                }
                return null;
              },
              keyboardType: TextInputType.name,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.clientName,
                prefixIcon: Icon(nameIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// client number
            TextFormField(
              key: _clientNumberKey,
              controller: clientNumberController
                ..text = '0${model.clientNum.toString()}',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return al.clientNumberPlease;
                return null;
              },
              maxLength: 11,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.clientNumber,
                prefixIcon: Icon(numberIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// client id
            TextFormField(
              key: _clientIdKey,
              controller: clientIdController..text = model.clientId.toString(),
              validator: (value) {
                if (clientIdController.text.toString().startsWith('0') ==
                    false) {
                  if (value.length != 14) return al.clientIdPlease;
                }
                return null;
              },
              keyboardType: TextInputType.number,
              maxLength: 14,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.clientId,
                prefixIcon: Icon(idCardIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// guarantor name
            TextFormField(
              key: _guarantorNameKey,
              controller: guarantorNameController..text = model.guarantorName,
              validator: (value) {
                if (value.isEmpty || value == null)
                  return al.guarantorNamePlease;
                return null;
              },
              keyboardType: TextInputType.name,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.guarantorName,
                prefixIcon: Icon(nameIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// guarantor number
            TextFormField(
              key: _guarantorNumberKey,
              controller: guarantorNumberController
                ..text = '0${model.guarantorNum.toString()}',
              keyboardType: TextInputType.number,
              maxLength: 11,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return al.guarantorNumberPlease;
                return null;
              },
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.guarantorNumber,
                prefixIcon: Icon(numberIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// guarantor id
            TextFormField(
              key: _guarantorIdKey,
              controller: guarantorIdController
                ..text = model.guarantorId.toString(),
              maxLength: 14,
              validator: (value) {
                if (guarantorIdController.text.startsWith('0') == false) {
                  if (value.length != 14) return al.guarantorIdPlease;
                }
                return null;
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.guarantorId,
                prefixIcon: Icon(idCardIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// brand name
            TextFormField(
              key: _brandKey,
              controller: brandNameController
                ..text = model.brandName.toString(),
              enabled: false,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.brandName,
                prefixIcon: Icon(idCardIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// phone name
            TextFormField(
              key: _phoneNameKey,
              controller: phoneNameController
                ..text = model.phoneName.toString(),
              enabled: false,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.phoneName,
                prefixIcon: Icon(idCardIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// phone price form
            TextFormField(
              key: _phonePriceKey,
              controller: phonePriceController
                ..text = model.phonePrice.toString(),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return al.phonePricePlease;
                // check if phone price < 0
                else if (int.parse(value.toString()) < 0)
                  return al.phonePriceCant;
                return null;
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.phonePrice,
                prefixIcon: Icon(phonePriceIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// advanced amount form
            TextFormField(
              key: _advancedAmountKey,
              controller: advancedAmountController
                ..text = model.advancedAmount.toString(),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return al.advancedAmount;
                // check if advanced amount < 0
                else if (int.parse(value.toString()) < 0)
                  return al.advancedAmountCant;
                return null;
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.advancedAmount,
                prefixIcon: Icon(advancedAmountIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// installment period form
            TextFormField(
              key: _installmentPeriodKey,
              controller: installmentPeriodController
                ..text = model.installmentPeriod.toString(),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return al.installmentPeriodPlease;
                // check if installment period < 0
                else if (int.parse(value.toString()) < 0)
                  return al.installmentPeriodCant;
                return null;
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.installmentPeriod,
                prefixIcon: Icon(installmentPeriodIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// the rest form
            TextFormField(
              enabled: false,
              controller: theRestController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.theRest,
                prefixIcon: Icon(restIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// profit form
            TextFormField(
              enabled: false,
              controller: theProfitController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.theProfit,
                prefixIcon: Icon(profitIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// paid monthly form
            TextFormField(
              enabled: false,
              controller: paidMonthlyController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.paidMonthly,
                prefixIcon: Icon(paidMonthlyIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
// received date form
            TextFormField(
              // use date format here because i want to put date in english numbers to avoid editing of date when use pressed on show or save button
              controller: receivedDateController
                ..text = DateFormat('yyyy-MM-dd').format(model.receivedDate),
              keyboardType: TextInputType.datetime,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                labelText: al.receivedDate,
                prefixIcon: Icon(receivedDateIcon),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
