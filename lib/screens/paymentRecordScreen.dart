import 'package:ali_mobile_store/collection.dart';
import 'package:ali_mobile_store/constants.dart';
import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:ali_mobile_store/firebase_services.dart';
import 'package:ali_mobile_store/widgets/InstallmentsListWidget.dart';
import 'package:ali_mobile_store/widgets/sharedLoadingWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PaymentRecordScreen extends StatefulWidget {
  final String installmentId;
  final String fireStoreCollectionName;
  PaymentRecordScreen({this.installmentId, this.fireStoreCollectionName});

  @override
  _PaymentRecordScreenState createState() => _PaymentRecordScreenState();
}

class _PaymentRecordScreenState extends State<PaymentRecordScreen> {
  AppLocalizations al;

  bool localizationState;

  Collection collection;

  FireStoreServices _fireStoreServices = FireStoreServices();

  InstallmentsModel model;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    collection = Collection(context);
    al = AppLocalizations.of(context);
    localizationState = (al.localeName == 'ar') ? true : false;

    return SafeArea(
      child: Scaffold(
         backgroundColor: offWhiteColor,
        appBar: appBar(),
        body: streamBuilderWidget(),
      ),
    );
  }

  streamBuilderWidget() {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStoreServices.getClient(
            widget.installmentId, widget.fireStoreCollectionName),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> querySnapshot) {

          if (querySnapshot.hasError) return Center(child: Text('something went wrong'));
          if (querySnapshot.connectionState == ConnectionState.waiting)
            return sharedLoadingWidget(al.loading);
          if (querySnapshot.data.docs.length == 0)
            return Center(child: ListIsEmptyWidget(al.installmentsListIsEmpty));

          QueryDocumentSnapshot documentSnapshot = querySnapshot.data.docs[0];
          Map<String, dynamic> map = documentSnapshot.data();
          model = InstallmentsModel.toObject(map);

          return pageDesignWidget();
        });
  }

  pageDesignWidget() {
    return ListView(
      shrinkWrap: true,
      children: [
        SizedBox(height: 16,),
        paidWidget(al.paidFromInstallments, totalPaidByClient()),
        paidWidget(al.advancedAmount, model.advancedAmount),
        paidWidget(al.total, totalPaid()),
        listBuilder()
      ],
    );
  }

  appBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: offWhiteColor,
      toolbarHeight: barDimen,
      elevation: 0,
      title: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: darkGreenColor),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            al.paymentRecord,
          ),
        ),
      ),
    );
  }

  paidWidget(String description, int price) {
    return Padding(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${collection.convertNumbers(price)} ${al.pound}',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                )
              ],
            ),
            Divider(
              thickness: 1.5,
              color: lightGreenColor,
            ),
          ],
        ));
  }

  totalPaid() {
    int total = totalPaidByClient() + model.advancedAmount;
    return total;
  }

  totalPaidByClient() {
    int total = 0;
    for (int i = 1; i < model.paymentRecord.length; i++) {
      total += model.paymentRecord[i];
    }
    return total;
  }

  recordDesign(int index) {
    List<int> paymentRecord = model.paymentRecord.reversed.toList();
    List<DateTime> paymentRecordDates =
        model.paymentRecordDates.reversed.toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
// row sign
              Container(
                height: 10,
                width: 10,
                color: darkGreenColor,
              ),
              SizedBox(
                width: 10,
              ),
// price
              Text(
                collection
                    .convertNumbers(paymentRecord[index].toString())
                    .toString(),
                style: TextStyle(fontSize: 18, color: darkGreenColor),
              ),
              SizedBox(
                width: 8,
              ),
// pound word
              Expanded(
                flex: 1,
                child: Text(
                  al.pound,
                  style: TextStyle(fontSize: 18, color: darkGreenColor),
                ),
              ),
// day of date
              Text(collection.dayFormat(paymentRecordDates[index]),
                  style: TextStyle(fontSize: 18, color: darkGreenColor)),
              SizedBox(
                width: 14,
              ),
// date
              Text(
                collection.dateFormat(paymentRecordDates[index]),
                style: TextStyle(fontSize: 18, color: darkGreenColor),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Divider(
            thickness: 1,
            height: 1,
          )
        ],
      ),
    );
  }

  listBuilder() {
    // make length minus one to avoid the first value in list which will be null and add one in record design parameter also
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: model.paymentRecord.length - 1,
        itemBuilder: (context, index) {
          return recordDesign(index);
        },
      ),
    );
  }
}
