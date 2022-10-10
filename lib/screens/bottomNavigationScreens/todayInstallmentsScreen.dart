import 'package:ali_mobile_store/collection.dart';
import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:ali_mobile_store/sharedWidgets/sharedBottomSheet.dart';
import 'package:ali_mobile_store/theme.dart';
import 'package:ali_mobile_store/widgets/sharedLoadingWidget.dart';
import 'package:ali_mobile_store/widgets/noInstallmentsInDayWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../clientPageScreen.dart';
import '../../constants.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'dart:ui' as ui;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../firebase_services.dart'; // important

class TodayInstallmentsScreen extends StatefulWidget {
  const TodayInstallmentsScreen({Key key}) : super(key: key);

  @override
  _TodayInstallmentsScreenState createState() => _TodayInstallmentsScreenState();
}

class _TodayInstallmentsScreenState extends State<TodayInstallmentsScreen> {

  final String _fireStroeCollectionName = 'clients';
  FireStoreServices _fireStoreServices = FireStoreServices();
  AppLocalizations al;
  bool localizationState;
  Collection collection;
  String _collectionName = 'clients';
  List<InstallmentsModel> allInstallmentsList = [];
  int numOfShow = 0;
  DateTime determinedDate;
  TextEditingController paidByClientController = TextEditingController();
  bool searchAppBarVisible = false;
  String searchText = '';
  TextEditingController textSearchController = TextEditingController();
  int firebaseCustomIndex = 0;
  Stream _stream;
  int nextInstallmentId;
  List<MissedModel> listOfModels = [];

  @override
  void initState() {
    super.initState();
    _stream = _fireStoreServices.getCollectionOfSnapshot(_collectionName);
  }

  @override
  Widget build(BuildContext context) {
    collection = Collection(context);
    al = AppLocalizations.of(context);
    localizationState = (al.localeName == 'ar') ? true : false;
    return DefaultTabController(
      length: 1,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: offWhiteColor,
            body: CustomScrollView(
              slivers: [
                (searchAppBarVisible)? sliverAppBarForSearch() : sliverAppBar(),
                sliverListWidget(),
              ],
            ),
        ),
      ),
    );
  }

  sliverAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: offWhiteColor,
      toolbarHeight: barDimen,
      stretch: true,

      floating: true,
      title: (localizationState)? SvgPicture.asset('assets/app_logo_ar.svg') : SvgPicture.asset('assets/app_logo_ar.svg'),
      actions: [
// search icon
        IconButton(
          onPressed: () {
            setState(() {
              searchAppBarVisible = true;
            });
          },
          icon: Icon(
            searchIcon,
            color: darkGreenColor,
            size: 28,
          ),
        ),
// more option icon
        IconButton(
          onPressed: () {
            bottomSheetWidget();
          },
          icon: Icon(
            moreOptionsIcon,
            color: darkGreenColor,
            size: 28,
          ),
        ),
      ],
      bottom: TabBar(
        labelPadding: EdgeInsets.zero,
        indicatorColor: transparentColor,
        tabs: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                ),
// clients
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      al.clients,
                    ),
                  ),
                ),
// installment state text
                SizedBox(
                  width: installmentStateWidthDimen,
                  child: Center(
                    child: Text(
                      al.state,
                    ),
                  ),
                ),
// installment date and time
                SizedBox(
                  width: installmentDateTimeWidthDimen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        al.da,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  sliverAppBarForSearch() {
    return SliverAppBar(
      backgroundColor: offWhiteColor,
      toolbarHeight: barDimen,
      floating: true,
      actions: [
// arrow back icon
        IconButton(
          onPressed: () {
            setState(() {
              searchAppBarVisible = false;
            });
          },
          icon: Icon(
            rightArrowIcon,
            color: darkGreenColor,
          ),
        ),
// search text form field
        Expanded(
          flex: 1,
          child: Visibility(
            visible: true,
            child: TextFormField(
              controller: textSearchController,
              autofocus: true,
              // key: _clientNumberKey,
              // controller: clientNumberController,
              onChanged: (q) {
                setState(() {
                  searchText = q;
                });
              },
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
          ),
        ),
// close icon
        IconButton(
          onPressed: () {
            setState(() {
              searchText = '';
              textSearchController.text = searchText;
            });
          },
          icon: Icon(
            closeIcon,
            color: darkGreenColor,
          ),
        ),
      ],
      bottom: TabBar(
        labelPadding: EdgeInsets.zero,
        indicatorColor: transparentColor,
        tabs: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                ),
// clients
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      al.clients,
                    ),
                  ),
                ),
// installment state text
                SizedBox(
                  width: installmentStateWidthDimen,
                  child: Center(
                    child: Text(
                      al.state,
                    ),
                  ),
                ),
// installment date and time
                SizedBox(
                  width: installmentDateTimeWidthDimen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        al.da,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  bottomSheetWidget() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: [
              ListTile(
                leading: Visibility(
                  visible: (numOfShow == 0) ? true : false,
                  child: Icon(checkedInstallmentDateIcon),
                ),
                onTap: () {
                  setState(() {
                    numOfShow = 0;
                    Navigator.pop(context);
                  });
                },
                title: Text(al.todayInstallments),
              ),
              Divider(
                height: 2,
                thickness: 1,
              ),
              ListTile(
                title: Text(
                  al.tomorrowInstallments,
                ),
                leading: Visibility(
                  visible: (numOfShow == 1) ? true : false,
                  child: Icon(checkedInstallmentDateIcon),
                ),
                onTap: () {
                  setState(() {
                    numOfShow = 1;
                    Navigator.pop(context);
                  });
                },
              ),
              Divider(
                height: 2,
                thickness: 1,
              ),
              ListTile(
                leading: Visibility(
                  visible: (numOfShow == 2) ? true : false,
                  child: Icon(checkedInstallmentDateIcon),
                ),
                title: Text(al.missedInstallments),
                onTap: () {
                  setState(() {
                    numOfShow = 2;
                    Navigator.pop(context);
                  });
                },
              ),
              Divider(
                height: 2,
                thickness: 1,
              ),
              ListTile(
                leading: Visibility(
                  visible: (numOfShow == 3) ? true : false,
                  child: Icon(checkedInstallmentDateIcon),
                ),
                title: Text(al.determineDate),
                onTap: () {
                  Navigator.pop(context);
                  buildMaterialDatePickerWidget();
                },
              ),
            ],
          );
        });
  }

  buildMaterialDatePickerWidget() {
    DateTime currentDate = DateTime.now();
    DateTime firstDate = DateTime(currentDate.year - 5);
    DateTime lastDate = DateTime(currentDate.year + 5);
    DatePicker.showSimpleDatePicker(
      context,
      initialDate: currentDate,
      firstDate: firstDate,
      lastDate: lastDate,
      // lastDate: DateTime(2012),
      // i must set date format here
      dateFormat: "dd-MM-yyyy",
      locale: DateTimePickerLocale.ar,
      looping: true,
      titleText: al.selectDate,
      confirmText: al.ok,
      cancelText: al.cancel,
      textColor: darkGreenColor,
    ).then((value) {
      // check if date is not null
      if (value != null) {
        setState(() {
          numOfShow = 3;
          determinedDate = DateTime(value.year, value.month, value.day);
        });
      }
    });
  }

  sliverListWidget() {
    return SliverList(
      delegate: SliverChildListDelegate(
          [
            streamBuilderWidget(),
          ]
      ),

    );
  }

  streamBuilderWidget(){
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if (snapshot.hasError) return Center(child: Text('something went wrong'));
        if (snapshot.connectionState == ConnectionState.waiting)
          return sharedLoadingWidget(al.loading);
        if (snapshot.data.docs.length == 0)
          return Center(child: NoInstallmentsInDayWidget(numOfShow));

        // get last model to use it next to check if there is no data to show
        Map<String, dynamic> lastMap = snapshot.data.docs.last.data();
        InstallmentsModel lastModel = InstallmentsModel.toObject(lastMap);
        listOfModels.clear();
        return ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: snapshot.data.docs.map<Widget>((DocumentSnapshot document) {

            // get map and convert it to model
            Map<String, dynamic> map = document.data();
            InstallmentsModel model = InstallmentsModel.toObject(map);

            // get the data which the user want to show
            // data is stream of single models or stream of list of models
            var data = determineDisplayData(model);

            // if user will search in  installments
            if (searchAppBarVisible == true && data is MissedModel){
              if (data.model.clientName.toLowerCase().contains(searchText.toLowerCase()))
                return itemDesign(data.model, data.monthIndex);
              return SizedBox();
            }
            // if user will search in missed installments
            if (searchAppBarVisible == true && data is List<MissedModel>){
              List<MissedModel> list = [];
              for(int i = 0; i < data.length; i++){
                if (data[i].model.clientName.toLowerCase().contains(searchText.toLowerCase()))
                  list.add(data[i]);
              }
              // return missed installments widget if there is data to show else return sized box
              if (list.length > 0)
                return missedInstallmentsWidget(list);
              return SizedBox();
            }

            if (data is MissedModel && data != null)
              return itemDesign(data.model, data.monthIndex);

            if (data is List<MissedModel> && data.length > 0){
              print('list length is ${listOfModels.length}');
              return missedInstallmentsWidget(data);

            }



            // return true if this last model from fire store and list of models is empty to tell user that no data to show
            if (lastModel.installmentId == model.installmentId && data == null && listOfModels.length == 0)
              return NoInstallmentsInDayWidget(numOfShow);

            if (lastModel.installmentId == model.installmentId && data is List<MissedModel> && data.length == 0)
              return NoInstallmentsInDayWidget(numOfShow);


            return SizedBox();
          }).toList(),
        );
    }
    );
  }

  determineDisplayData(InstallmentsModel model){
    // determine which data should display
    var missedModel;
    if (numOfShow == 0)
      missedModel = determineTodayInstallmentsTwo(model);
    else if (numOfShow == 1)
      missedModel = determineTomorrowInstallmentsTwo(model);
    else if (numOfShow == 2)
      missedModel = determineMissedInstallmentsTwo(model);
    else
      missedModel = determineInstallmentsAccordingToDateTwo(model);

    // return true if the type is missedModel not List<MissedModel> and it not null and put it to list
    if (missedModel is MissedModel && missedModel != null)
      listOfModels.add(missedModel);

    return missedModel;
  }

  missedInstallmentsWidget(List<MissedModel> listOfMissedModels) {
    return ListView.builder(
      itemCount: listOfMissedModels.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        var missedModel = listOfMissedModels[index].model;
        var monthIndex = listOfMissedModels[index].monthIndex;
        return itemDesign(missedModel, monthIndex);
      },
    );
  }

  checkIfModelIsExist(InstallmentsModel model) {
    for (int i = 0; i < determineFilteredData().length; i++) {
      if (determineFilteredData()[i].model.installmentId == model.installmentId)
        return true;
    }
    return false;
  }

  List<MissedModel> determineFilteredData() {
    if (searchAppBarVisible) {
      if (searchText.isEmpty || searchText == null) {
        return determineShowingData();
      }
      return determineShowingData()
          .where((element) => element.model.clientName
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    }
    return determineShowingData();
  }

  List<MissedModel> determineShowingData() {
    if (numOfShow == 0)
      return determineTodayInstallments(allInstallmentsList);
    else if (numOfShow == 1)
      return determineTomorrowInstallments(allInstallmentsList);
    else if (numOfShow == 2)
      return determineMissedModels(allInstallmentsList);

    return determineInstallmentsAccordingToDate(allInstallmentsList);
  }

  String determineTextFormFieldValue(InstallmentsModel model, int monthIndex) {
    return model.finalPaidMonthly[monthIndex].toString();
  }

  determineBiggestPriceToPay(InstallmentsModel model) {
    int biggestPriceToPay = collection.calculateBiggestPriceToPay(model, true);
    return biggestPriceToPay;
  }

  bool determineCheckboxValue(InstallmentsModel model, int monthIndex) {
    if (model.completeInstallment[monthIndex])
      return true;
    else
      return false;
  }

  determineOnChangedCheckbox(InstallmentsModel model, int monthIndex) {

    if (model.completeInstallment[monthIndex])
      return null;
    else {
      setState(() {
        sharedBottomSheetForPaying(context, model, monthIndex, collection, true);
      });
    }
  }

  determineTodayInstallments(List<InstallmentsModel> allInstallmentsList) {
    List<MissedModel> list = [];
    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    for (int modelIndex = 0;
        modelIndex < allInstallmentsList.length;
        modelIndex++) {
      InstallmentsModel model = allInstallmentsList[modelIndex];
      List<DateTime> installmentsDates = model.installmentsDates;
      for (int monthIndex = 0;
          monthIndex < model.installmentPeriod;
          monthIndex++) {
        if (installmentsDates[monthIndex] == currentDate)
          list.add(MissedModel(
              model: model, monthIndex: monthIndex));
      }
    }

    return list;
  }

  determineTodayInstallmentsTwo(InstallmentsModel model) {
    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    List<DateTime> installmentsDates = model.installmentsDates;
    for (int monthIndex = 0; monthIndex < model.installmentPeriod; monthIndex++) {
      if (installmentsDates[monthIndex] == currentDate)
        return MissedModel(model: model, monthIndex: monthIndex);
    }
    return null;
  }

  determineTomorrowInstallments(List<InstallmentsModel> allInstallmentsList) {
    List<MissedModel> list = [];
    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day + 1);
    for (int modelIndex = 0;
        modelIndex < allInstallmentsList.length;
        modelIndex++) {
      InstallmentsModel model = allInstallmentsList[modelIndex];
      List<DateTime> installmentsDates = model.installmentsDates;
      for (int monthIndex = 0;
          monthIndex < model.installmentPeriod;
          monthIndex++) {
        if (installmentsDates[monthIndex] == currentDate)
          list.add(MissedModel(
              model: model, monthIndex: monthIndex));
      }
    }
    return list;
  }

  determineTomorrowInstallmentsTwo(InstallmentsModel model) {
    DateTime currentDate = DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day + 1);
    List<DateTime> installmentsDates = model.installmentsDates;
    for (int monthIndex = 0;
    monthIndex < model.installmentPeriod;
    monthIndex++) {
      if (installmentsDates[monthIndex] == currentDate)
        return MissedModel(
            model: model, monthIndex: monthIndex);
    }
    return null;
  }

  List<MissedModel> determineMissedInstallments(MissedModel missedModel) {
    List<MissedModel> list = [];
    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    InstallmentsModel model = missedModel.model;
    List<DateTime> installmentsDates = model.installmentsDates;
    List<bool> completeInstallments = model.completeInstallment;

    for (int monthIndex = 0;
    monthIndex < model.installmentPeriod;
    monthIndex++) {
      // check if this installment is missed and not complete
      if (installmentsDates[monthIndex].isBefore(currentDate) &&
          completeInstallments[monthIndex] == false) {
        list.add(MissedModel(
            model: model, monthIndex: monthIndex));
      }
    }
    return list;
  }

  List<MissedModel> determineMissedInstallmentsTwo(InstallmentsModel model) {
    List<MissedModel> list = [];
    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    List<DateTime> installmentsDates = model.installmentsDates;
    List<bool> completeInstallments = model.completeInstallment;

    for (int monthIndex = 0;
    monthIndex < model.installmentPeriod;
    monthIndex++) {
      // check if this installment is missed and not complete
      if (installmentsDates[monthIndex].isBefore(currentDate) &&
          completeInstallments[monthIndex] == false) {
        list.add(MissedModel(
            model: model, monthIndex: monthIndex));
      }
    }
    return list;
  }

  determineMissedModels(List<InstallmentsModel> allInstallmentsList) {
    List<MissedModel> list = [];
    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    for (int modelIndex = 0;
        modelIndex < allInstallmentsList.length;
        modelIndex++) {
      InstallmentsModel model = allInstallmentsList[modelIndex];
      List<DateTime> installmentsDates = model.installmentsDates;
      List<bool> completeInstallments = model.completeInstallment;

      for (int monthIndex = 0;
          monthIndex < model.installmentPeriod;
          monthIndex++) {
        // check if this installment is missed and not complete
        if (installmentsDates[monthIndex].isBefore(currentDate) &&
            completeInstallments[monthIndex] == false) {
          list.add(MissedModel(
              model: model, monthIndex: monthIndex));
          monthIndex = model.installmentPeriod +5;
        }
      }
    }
    return list;
  }

  determineInstallmentsAccordingToDate(
      List<InstallmentsModel> allInstallmentsList) {
    List<MissedModel> filteredInstallments = [];
    DateTime date =
        DateTime(determinedDate.year, determinedDate.month, determinedDate.day);
    for (int modelIndex = 0;
        modelIndex < allInstallmentsList.length;
        modelIndex++) {
      InstallmentsModel model = allInstallmentsList[modelIndex];
      List<DateTime> installmentsDates = model.installmentsDates;
      for (int monthIndex = 0;
          monthIndex < model.installmentPeriod;
          monthIndex++) {
        if (installmentsDates[monthIndex] == date)
          filteredInstallments.add(MissedModel(
              model: model, monthIndex: monthIndex));
      }
    }
    return filteredInstallments;
  }

  determineInstallmentsAccordingToDateTwo(InstallmentsModel model) {
    DateTime date = DateTime(determinedDate.year, determinedDate.month, determinedDate.day);
    List<DateTime> installmentsDates = model.installmentsDates;
    for (int monthIndex = 0; monthIndex < model.installmentPeriod; monthIndex++) {
      if (installmentsDates[monthIndex] == date)
        return MissedModel(
            model: model, monthIndex: monthIndex);
    }
    return null;
  }

  determineCheckboxVisibility(InstallmentsModel model, monthIndex) {

    // check if this installment is not first one and the installment before that is false to make it invisible
    if (monthIndex > 0 && model.completeInstallment[monthIndex - 1] == false)
      return false;
    return true;
  }

  showAlertDialog(InstallmentsModel model, monthIndex) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
// pay installments num
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: darkGreenColor,
                  child: Text(
                    '${al.payTheInstallmentNum} '
                        '${collection.convertNumbers(monthIndex + 1)} '
                        '${al.from} ${collection.convertNumbers(model.installmentPeriod)}',
                  ),
                ),
              ],
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
// biggest price to pay
                Container(
                  color: darkGreenColor,
                  child: Text(
                    '${al.endTheInstallmentByPaying} ${collection.convertNumbers(determineBiggestPriceToPay(model)).toString()}',

                  ),
                ),
                SizedBox(
                  height: 8,
                ),
// late receivables
                Container(
                  color: darkGreenColor,
                  child: Text(
                    '${al.lateReceivables} ${collection.convertNumbers(collection.determineLateReceivables(model, true).toString())}',

                  ),
                ),
                TextFormField(
                  controller: paidByClientController
                    ..text =
                    determineTextFormFieldValue(model, monthIndex),
                  textAlign: ui.TextAlign.start,
                  keyboardType: TextInputType.number,
                )
              ],
            ),
            actions: [
// ok button
              TextButton(
                onPressed: () {
                  collection.installmentPayment(model, paidByClientController.text, true);
                },
                child: Text(
                  al.ok,
                ),
              ),
// cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  al.cancel,
                  style: TextStyle(color: darkGreenColor),
                ),
              )
            ],
          );
        });
  }

  itemDesign(InstallmentsModel model, int monthIndex) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ClientPageScreen(
                  installmentId: model.installmentId,
                  installmentNum: model.installmentNum,
                  fireStoreCollectionName: _fireStroeCollectionName,
                )));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Container(
          height: installmentItemHeightDimen,
          decoration: BoxDecoration(
            color: lightGreenColor,
            borderRadius: BorderRadius.all(Radius.circular(fourDimen)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
//checkbox
                Visibility(
                  visible:
                  determineCheckboxVisibility(model, monthIndex),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: determineCheckboxValue(model, monthIndex),
                      onChanged: (boxState) {
                        determineOnChangedCheckbox(model, monthIndex);
                      },
                    ),
                  ),
                ),
//client name
                Expanded(
                    flex: 1,
                    child: SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            collection.convertNumbers(model.clientName).toString(),
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ),
                    )),
// installment state
                Container(
                  width: installmentStateWidthDimen,
                  height: installmentStateHeightDimen,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100),),
                    border: Border.all(color: collection.determineInstallmentStateInMonth(model, monthIndex).borderColor,),
                    color: collection.determineInstallmentStateInMonth(model, monthIndex).fillColor,
                  ),
                  child: Center(
                    child: Text(
                      collection.determineInstallmentStateInMonth(model, monthIndex).state,
                      style: TextStyle(color: collection.determineInstallmentStateInMonth(model, monthIndex).borderColor),
                    ),
                  ),
                ),

// installment date and price
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: installmentDateTimeWidthDimen),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
// date text
                      Text(
                        collection
                            .dateFormat(model.installmentsDates[monthIndex]),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
// paid monthly text
                          Text(
                            collection.convertNumbers(model.paidMonthlyDeal[monthIndex]).toString(),
                            style: boldPaidMonthlyTheme(collection, model, monthIndex),
                          ),
                          SizedBox(
                            width: 4,
                          ),
// final paid monthly
                          Visibility(
                            visible: (collection.determineFinalPaidVisibility(model, monthIndex)),
                            child: Text(
                              collection.convertNumbers(
                                  model.finalPaidMonthly[monthIndex]).toString(),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
// pound word
                          Text(
                            al.pound,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      )

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// to send the filtered installment with it's index in the new list
class MissedModel {
  InstallmentsModel model;
  int monthIndex;

  MissedModel({this.model, this.monthIndex});
}
