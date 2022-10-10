import 'package:ali_mobile_store/collection.dart';
import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:ali_mobile_store/dataBase/installmentsDatabase.dart';
import 'package:ali_mobile_store/firebase_services.dart';
import 'package:ali_mobile_store/screens/installmentDataScreen.dart';
import 'package:ali_mobile_store/screens/paymentRecordScreen.dart';
import 'package:ali_mobile_store/sharedWidgets/sharedBottomSheet.dart';
import 'package:ali_mobile_store/theme.dart';
import 'package:ali_mobile_store/widgets/sharedLoadingWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../Models/endInstallmentMessageModel.dart';
import '../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // important

// ignore: must_be_immutable
class ClientPageScreen extends StatefulWidget {
  ClientPageScreen(
      {Key key,
      this.installmentId,
      this.installmentNum,
      this.fireStoreCollectionName})
      : super(key: key);
  final String installmentId;
  final int installmentNum;
  final String fireStoreCollectionName;

  @override
  _ClientPageScreenState createState() => _ClientPageScreenState();
}

class _ClientPageScreenState extends State<ClientPageScreen> {
  FireStoreServices _fireStoreServices = FireStoreServices();
  InstallmentsModel model;
  Future<InstallmentsModel> futureModel;
  InstallmentsDatabase database;
  Collection collection;
  TextEditingController paidByClientController = TextEditingController();
  AppLocalizations al;
  bool localizationState;
  int additionalProfit;
  bool additionalProfitState = true;
  Stream _stream;
  TextEditingController _finishedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stream = _fireStoreServices.getClient(
        widget.installmentId, widget.fireStoreCollectionName);
  }

  @override
  void dispose() async {
    super.dispose();
    if (model.lastInstallment.contains(true) &&
        widget.fireStoreCollectionName == 'clients')
      await _fireStoreServices.deleteClient(model);
  }

  @override
  Widget build(BuildContext context) {
    collection = Collection(context);
    al = AppLocalizations.of(context);
    localizationState = (al.localeName == 'ar') ? true : false;
    return Scaffold(
      backgroundColor: offWhiteColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 36, 12, 8),
        child: streamBuilderWidget(),
      ),
    );
  }

  listViewWidget(){

  }

  streamBuilderWidget() {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('something went wrong'));
        if (snapshot.connectionState == ConnectionState.waiting)
          return Text('loading');

        return ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: snapshot.data.docs.map<Widget>((DocumentSnapshot document) {
            Map<String, dynamic> map = document.data() as Map<String, dynamic>;
            model = InstallmentsModel.toObject(map);

            return pageDesign();
          }).toList(),
        );
      },
    );
  }

  pageDesign() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.0),
        Row(
          children: [
            clientNumberWidget(),
            SizedBox(
              width: 8,
            ),
            clientNameWidget(),
            moreOptionsWidget(),
          ],
        ),
        SizedBox(height: 24),
        expansionTileWidget(),
        SizedBox(height: 16),
        paymentRecordWidget(),
        totalPaidWidget(),
        additionalProfitWidget(),
        additionalProfitWarning(),
        endInstallmentWidget(),
        installmentListWidget(),
        SizedBox(
          height: 8,
        )
      ],
    );
  }

  moreOptionsWidget() {
    return Align(
      // use alignment with this dimensions to make more icon after 8 pixel from left only
      alignment: (localizationState) ? Alignment(-1.5, 0) : Alignment(-1.05, 0),
      child: Container(
        width: 18,
        child: GestureDetector(
          onTap: () {
            showBottomSheet();
          },
          child: Icon(
            moreOptionsIcon,
            color: darkGreenColor,
            size: 28,
          ),
        ),
      ),
    );
  }

  showBottomSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(24), topLeft: Radius.circular(24))),
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: [
              GestureDetector(
                onTap: () async {
                  FlutterPhoneDirectCaller.callNumber(
                      '0${model.clientNum.toString()}');
                  Navigator.pop(context);
                },
                child: ListTile(
                  leading: Icon(
                    numberIcon,
                    color: darkGreenColor,
                  ),
                  title: Text(
                    al.callingClient,
                  ),
                ),
              ),
              Divider(
                height: 2,
                thickness: 2,
              ),
              GestureDetector(
                onTap: () async {
                  FlutterPhoneDirectCaller.callNumber(
                      '0${model.guarantorNum.toString()}');
                  Navigator.pop(context);
                },
                child: ListTile(
                  leading: Icon(
                    numberIcon,
                    color: darkGreenColor,
                  ),
                  title: Text(
                    al.callingGuarantor,
                  ),
                ),
              ),
              Divider(
                height: 2,
                thickness: 2,
              ),
              ListTile(
                leading: Icon(
                  paymentRecordIcon,
                  color: darkGreenColor,
                ),
                title: Text(
                  al.paymentRecord,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentRecordScreen(
                                installmentId: widget.installmentId,
                                fireStoreCollectionName:
                                    widget.fireStoreCollectionName,
                              )));
                },
              ),
              Divider(
                height: 2,
                thickness: 2,
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  // check if this installment is complete to prevent updating
                  if (model.lastInstallment.contains(true))
                    showSnackBar(
                        al.completeInstallmentsCanNotBeUpdated, darkRedColor);
                  else
                    navigateAndGetNewModel();
                },
                leading: Icon(updateDataIcon),
                title: Text(
                  al.updateClientData,
                ),
              ),
              Divider(
                height: 2,
                thickness: 2,
              ),
              Visibility(
                visible: (model.lastInstallment.contains(true)? false : true),
                child: ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    showBottomSheetForEndingInstallment();
                  },
                  leading: Icon(
                    trendingDownIcon,
                    color: redColor,
                  ),
                  title: Text(
                    al.endTheInstallment,
                    style: TextStyle(color: redColor),
                  ),
                ),
              ),
            ],
          );
        });
  }

  navigateAndGetNewModel() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InstallmentsDataScreen(
                installmentId: widget.installmentId,
                foreStoreCollectionName: widget.fireStoreCollectionName)));
  }

  clientNameWidget() {
    return Expanded(
      flex: 1,
      child: SizedBox(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
                color: darkGreenColor,
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                collection.convertNumbers(model.clientName).toString(),
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ),
      ),
    );
  }

  clientNumberWidget() {
    return Container(
      decoration: BoxDecoration(
        color: darkGreenColor,
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 24),
        child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
          collection.convertNumbers(widget.installmentNum).toString(),
          style: Theme.of(context).textTheme.headline6,
        ),
            )),
      ),
    );
  }

  paidMonthlyToString() {
    if (model.installmentPeriod == 1) {
      return model.paidMonthlyDeal[0].toString();
    }
    // if there is a fractions
    else if (model.paidMonthlyDeal[0] != model.paidMonthlyDeal[1]) {
      return '${al.month} * ${model.paidMonthlyDeal[0]} ${al.and} ${model.installmentPeriod - 1} ${al.months} * ${model.paidMonthlyDeal[1]}';
    }
    return model.paidMonthlyDeal[0].toString();
  }

  expansionTileWidget() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: lightGreenColor,
          border: Border.all(color: darkGreenColor, width: 1.5)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.only(right: 8, left: 8),
        title: Text(
          al.clientData,
        ),
        trailing: Icon(
          arrowDownIcon,
          color: darkGreenColor,
        ),
        children: [
          dataWidget(al.clientName, collection.convertNumbers(model.clientName),
              nameIcon),
          dataWidget(
              al.clientNumber,
              '${collection.convertNumbers(0)}${collection.convertNumbers(model.clientNum)}',
              numberIcon),
          dataWidget(al.clientId, collection.convertNumbers(model.clientId),
              idCardIcon),
          dataWidget(al.guarantorName,
              collection.convertNumbers(model.guarantorName), nameIcon),
          dataWidget(
              al.guarantorNumber,
              '${collection.convertNumbers(0)}${collection.convertNumbers(model.guarantorNum)}',
              numberIcon),
          dataWidget(al.guarantorId,
              collection.convertNumbers(model.guarantorId), idCardIcon),
          dataWidget(al.brandName, model.brandName, brandIcon),
          dataWidget(al.phoneName, model.phoneName, phoneNameIcon),
          dataWidget(al.phonePrice, collection.convertNumbers(model.phonePrice),
              phonePriceIcon),
          dataWidget(
              al.advancedAmount,
              collection.convertNumbers(model.advancedAmount),
              advancedAmountIcon),
          dataWidget(
              al.installmentPeriod,
              collection.convertNumbers(model.installmentPeriod),
              installmentPeriodIcon),
          dataWidget(al.theRest, collection.convertNumbers(model.restFromDeal),
              restIcon),
          dataWidget(al.theProfit,
              collection.convertNumbers(model.initialProfit), profitIcon),
          dataWidget(
              al.paidMonthly,
              collection.convertNumbers(paidMonthlyToString()),
              paidMonthlyIcon),
          dataWidget(al.receivedDate, collection.dateFormat(model.receivedDate),
              receivedDateIcon),
        ],
      ),
    );
  }

  dataWidget(description, data, icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4, left: 4),
// data icon
              child: Icon(icon),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 8),
              child: Text(
// description
                description,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
// divider
            Padding(
              padding:
                  const EdgeInsets.only(right: 4, top: 6, bottom: 6, left: 4),
              child: SizedBox(
                  width: 1,
                  height: 25,
                  child: VerticalDivider(
                    color: darkGreenColor,
                    thickness: 1,
                    width: 1,
                  )),
            ),
// the value
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, left: 8),
                child: Text(
                  // add Zero to left of phone number
                  data.toString(),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ],
        ),
        Visibility(
// if this item is last one make divider invisible
          visible: (description == al.receivedDate) ? false : true,
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: SizedBox(
              height: 3,
              width: double.infinity,
              child: Divider(
                color: offWhiteColor,
                height: 1,
                thickness: 1,
              ),
            ),
          ),
        )
      ],
    );
  }

  determineAdditionalProfitVisibility() {
    int lastInstallmentIndex = model.installmentPeriod - 1;
    DateTime lastInstallmentDate =
        model.installmentsDates[lastInstallmentIndex];
    lastInstallmentDate = DateTime(lastInstallmentDate.year,
        lastInstallmentDate.month, lastInstallmentDate.day + 1);
    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    int difference = currentDate.difference(lastInstallmentDate).inDays;
    // check if current date is equal to only day after last installment or current date is after last installment
    if (currentDate.isAfter(lastInstallmentDate) || difference > 0) {
      if (model.lastInstallment.contains(true)) return false;

      return true;
    }
    return false;
  }

  determineAdditionalProfitWarningVisibility() {
    int lastInstallmentIndex = model.installmentPeriod - 1;
    DateTime lastInstallmentDate =
        model.installmentsDates[lastInstallmentIndex];
    lastInstallmentDate = DateTime(lastInstallmentDate.year,
        lastInstallmentDate.month, lastInstallmentDate.day + 1);
    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    int difference = currentDate.difference(lastInstallmentDate).inDays;
    // check if current date is equal to only day after last installment or current date is after last installment
    if (currentDate == lastInstallmentDate || difference == 0) {
      return true;
    }
    return false;
  }

  additionalProfitWarning() {
    return Visibility(
      visible: determineAdditionalProfitWarningVisibility(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          color: lightGreenColor,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    al.additionalProfitWarning,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  installmentItem(monthIndex) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: BoxDecoration(
          color: lightGreenColor,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 4, left: 4),
          child: Column(
            children: [
// installment number and installment state
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
// check box
                    Visibility(
                      visible: determineCheckboxVisibility(monthIndex),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: determineCheckboxValue(monthIndex),
                          onChanged: (boxState) {
                            determineOnChangedCheckbox(monthIndex);
                          },
                        ),
                      ),
                    ),
// installment number
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        collection.convertNumbers((monthIndex + 1)).toString(),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Align(
                          alignment: (localizationState)
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
// installment state
                          child: Container(
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                              border: Border.all(
                                color: collection
                                    .determineInstallmentStateInMonth(
                                        model, monthIndex)
                                    .borderColor,
                              ),
                              color: collection
                                  .determineInstallmentStateInMonth(
                                      model, monthIndex)
                                  .fillColor,
                            ),
                            child: Center(
                              child: Text(
                                collection
                                    .determineInstallmentStateInMonth(
                                        model, monthIndex)
                                    .state,
                                style: TextStyle(
                                    color: collection
                                        .determineInstallmentStateInMonth(
                                            model, monthIndex)
                                        .borderColor,
                                    fontSize: 12),
                              ),
                            ),
                          ),
                        ))
                  ],
                ),
              ),

// installment price
              Padding(
                padding: (localizationState)
                    ? const EdgeInsets.only(top: 0)
                    : const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        al.installmentPrice,
                      ),
                    ),
                    Text(
                      collection
                          .convertNumbers(model.paidMonthlyDeal[monthIndex])
                          .toString(),
                      style:
                          normalPaidMonthlyTheme(collection, model, monthIndex),
                    ),
                    SizedBox(
                      width: 4,
                    ),
// final paid monthly
                    Visibility(
                      visible: (collection.determineFinalPaidVisibility(
                          model, monthIndex)),
                      child: Text(
                        collection
                            .convertNumbers(model.finalPaidMonthly[monthIndex])
                            .toString(),
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      al.pound,
                    ),
                  ],
                ),
              ),
//divider
              Padding(
                padding: (localizationState)
                    ? const EdgeInsets.all(0.0)
                    : const EdgeInsets.only(top: 4, bottom: 4),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: offWhiteColor,
                ),
              ),
// the amount paid
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      al.theAmountPaid,
                    ),
                  ),
                  Text(
                    collection
                        .convertNumbers(determineAmountPaid(monthIndex))
                        .toString(),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    al.pound,
                  ),
                ],
              ),
//divider
              Padding(
                padding: (localizationState)
                    ? const EdgeInsets.all(0.0)
                    : const EdgeInsets.only(top: 4, bottom: 4),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: offWhiteColor,
                ),
              ),
// installment date
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      al.installmentDate,
                    ),
                  ),
                  Text(
                    collection.dateFormat(model.installmentsDates[monthIndex]),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    determineInstallmentDate(monthIndex),
                  ),
                ],
              ),
//divider
              Padding(
                padding: (localizationState)
                    ? const EdgeInsets.all(0.0)
                    : const EdgeInsets.only(top: 4, bottom: 4),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: offWhiteColor,
                ),
              ),
// payment date
              Padding(
                padding: (localizationState)
                    ? const EdgeInsets.only(bottom: 0)
                    : const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        al.paymentDate,
                      ),
                    ),
                    Text(
                      determinePaymentDate(monthIndex),
                    ),
                    SizedBox(
                      width: 8,
                    ),
// payment day
                    Text(
                      determinePaymentDay(monthIndex),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  determineAdditionalProfit() {
    return additionalProfit = collection.calculateAdditionalProfitOnly(model);
  }

  additionalProfitWidget() {
    return Visibility(
      visible: determineAdditionalProfitVisibility(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          color: lightGreenColor,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: additionalProfitState,
                        onChanged: (value) {
                          setState(() {
                            additionalProfitState = value;
                          });
                        },
                      )),
                ),
                SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: Text(
                    '${al.additionalProfitNumOne} ${collection.convertNumbers(determineAdditionalProfit())} '
                    '${al.additionalProfitNumTwo} ${collection.convertNumbers(collection.calculatePastDaysForPayment(model))} ${al.additionalProfitNumThree}',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  paymentRecordWidget() {
    return Text(
      al.installmentsRecord,
      textAlign: TextAlign.start,
    );
  }

  totalPaidWidget() {
    int total = 0;
    for (int i = 1; i < model.paymentRecord.length; i++) {
      total += model.paymentRecord[i];
    }
    return Text(
      '${al.total} : ${collection.convertNumbers(total)} ${al.pound}',
    );
  }

  installmentListWidget() {
    return ListView.builder(
// this two lines must be that
// physics like that to prevent scroll in this list view and make scroll with parent listView Only
// shrinkWrap like this to make this list view to take it's space and not less than it's space to appear in screen
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      reverse: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return installmentItem(index);
      },
      itemCount: model.installmentPeriod,
    );
  }

  determineTextFormFieldValue(int index) {
    return model.finalPaidMonthly[index].toString();
  }

  validateTheAmountPaid() {
    int paidByClient = 0;
    try {
      paidByClient = int.parse(paidByClientController.text);
    } catch (e) {
      paidByClient = 0;
      Navigator.pop(context);
      showSnackBar('correct numbers only', darkRedColor);
    }

    return paidByClient;
  }

  showSnackBar(String content, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: backgroundColor,
      content: Text(content),
    ));
  }

  determineCheckboxValue(monthNum) {
    if (model.completeInstallment[monthNum]) return true;

    return false;
  }

  determineCheckboxVisibility(int index) {
    // check if this installment has finished so make any incomplete installment invisible
    if (model.lastInstallment.contains(true) &&
        model.completeInstallment[index] == false)
      return false;
    // check if this installment has finished so make any complete installment visible
    else if (model.lastInstallment.contains(true) &&
        model.completeInstallment[index])
      return true;
    // check if this installment is first one to make it visible
    else if (index == 0)
      return true;
    // check if this installment is complete to make it visible
    else if (model.completeInstallment[index])
      return true;
    // check if this installment is false and the installment before it is complete make it visible
    else if (model.completeInstallment[index - 1]) return true;

    return false;
  }

  determineOnChangedCheckbox(int monthIndex) {
    if (model.completeInstallment[monthIndex])
      return null;
    else
      sharedBottomSheetForPaying(
          context, model, monthIndex, collection, additionalProfitState);
  }

  determineAmountPaid(index) {
    int amountPaid = model.paidForEachInstallment[index];
    if (amountPaid == 0)
      return '____';
    else
      return amountPaid.toString();
  }

  determinePaymentDate(index) {
    DateTime date = model.paymentDates[index];
    if (date == null)
      return '____';
    else
      return collection.dateFormat(date);
  }

  determinePaymentDay(index) {
    DateTime date = model.paymentDates[index];
    if (date == null)
      return '____';
    else
      return collection.dayFormat(date);
  }

  determineInstallmentDate(index) {
    String date;
    try {
      date = collection.dayFormat(model.installmentsDates[index]);
    } catch (e) {
      date = '';
    }
    return date;
  }

  showBottomSheetForEndingInstallment() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(24), topLeft: Radius.circular(24)),
        ),
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 0,
                  child: Center(
                    child: Text(
                      '${al.endTheInstallmentWithALoseOf}'
                      ' ${collection.convertNumbers(collection.calculateBiggestPriceToPay(model, additionalProfitState))}'
                      ' ${al.pound}',
                      style: TextStyle(color: redColor, fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  '${al.fromOriginalPhonePrice} ${collection.convertNumbers(collection.calculateTheRestFromOriginalPhoneAmount(model))} ${al.pound}',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Divider(
                  thickness: 1.5,
                  color: lightGreenColor,
                ),
                Text(
                    '${al.fromProfitUntilKnow} ${collection.convertNumbers(collection.calculateRestFromProfitUntilKnow(model, additionalProfitState))} ${al.pound}',
                style: Theme.of(context).textTheme.subtitle1,),
                Divider(
                  thickness: 1.5,
                  color: lightGreenColor,
                ),
                TextField(
                  controller: _finishedController..text = '0',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: al.enterTheAmount,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: darkGreenColor)
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: darkGreenColor),
                    )
                  ),
                ),
                SizedBox(height: 24,),
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Row(
                    children: [
// pay button
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
                            collection.installmentPaymentToFinished(model, _finishedController.text, additionalProfitState).then((value) {
                              Navigator.pop(context);
                            });
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                                color: redColor),
                            child: Center(
                                child: Text(al.ok,
                                    style: TextStyle(
                                        fontSize: 16, color: offWhiteColor))),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
// cancel button
                      Flexible(
                          flex: 2,
                          child: GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                                color: darkGreenColor,
                              ),
                              child: Center(
                                child: Text(
                                    al.cancel,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: offWhiteColor,
                                    )),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  EndInstallmentMessageModel determineEndInstallmentMessage(InstallmentsModel model) {
    if (model.finished == true && model.loseFromProfit == 0) {
      String message = '${al
          .installmentWasEndWithAdditionalProfitOf} ${collection.convertNumbers(model.additionalProfit)} ${al.pound}';

      return EndInstallmentMessageModel(
          true, message, trendingUpIcon, darkGreenColor, lightGreenColor);
    }
    else if (model.finished == true && model.loseFromProfit < 0){
      int total = model.loseFromOriginalPhonePrice + model.loseFromProfit;
      String message =
          '${al.installmentWasEndWithAtALoseOne} ${collection.convertNumbers(model.loseFromOriginalPhonePrice)} ${al.pound}'
          ' ${al.installmentWasEndWithAtALoseTwo} ${al.and} ${collection.convertNumbers(model.loseFromProfit)} ${al.pound} ${al.installmentWasEndWithAtALoseThree} ${collection.convertNumbers(total)} ${al.pound}';

      return EndInstallmentMessageModel(true, message, trendingDownIcon, darkRedColor, lightRedColor);
    }

    return EndInstallmentMessageModel(false, '', trendingDownIcon, darkRedColor, lightGreenColor);
  }

  endInstallmentWidget(){
    return Visibility(
      visible: determineEndInstallmentMessage(model).displayed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: determineEndInstallmentMessage(model).backgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                determineEndInstallmentMessage(model).icon,
                color: determineEndInstallmentMessage(model).iconColor,
              ),
              SizedBox(width: 4,),
              Expanded(
                child: Text(
                  determineEndInstallmentMessage(model).message
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
