import 'package:ali_mobile_store/collection.dart';
import 'package:ali_mobile_store/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // important

// ignore: must_be_immutable
import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:flutter/material.dart';

TextEditingController paymentController = TextEditingController();

sharedBottomSheetForPaying(BuildContext context, InstallmentsModel model, int monthIndex, Collection collection, bool additionalProfitState) {
  int monthIndex = collection.determineIndexForInstallmentShouldPaid(model);
  AppLocalizations al = AppLocalizations.of(context);
  return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(24), topLeft: Radius.circular(24)),
      ),
      backgroundColor: offWhiteColor,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
// client name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${model.clientName} - ${model.brandName} ${model.phoneName}',
                    style: TextStyle(
                        color: darkGreenColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
// installment number
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${al.installmentNum} '
                        '${collection.convertNumbers(monthIndex + 1)} '
                        '${al.from} ${collection.convertNumbers(model.installmentPeriod)}',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (context, index){
                  String text;
                  switch(index){
                    case 0:
                      text = '${al.endTheInstallmentByPaying} '
                          '${collection.convertNumbers(collection.calculateBiggestPriceToPay(model, additionalProfitState)).toString()} ${al.pound}';
                      break;
                    case 1:
                      text = '${al.lateReceivables} '
                        '${collection.convertNumbers(collection.determineLateReceivables(model, additionalProfitState))} ${al.pound}';
                      break;
                    case 2:
                      text = '${al.restFromOriginalPhonePrice} ${collection.convertNumbers(collection.calculateTheRestFromOriginalPhoneAmount(model))} '
                          ' ${al.from} ${collection.convertNumbers(model.restFromDeal)} ${al.pound}';
                      break;
                      default: text = '${al.restFromProfitOfAgreement} ${collection.convertNumbers(collection.calculateRestFromInitProfit(model, additionalProfitState))}'
                          ' ${al.from} ${collection.convertNumbers(collection.calculateAdditionalProfitOnly(model) + model.initialProfit)} ${al.pound}';
                      break;
                  }
                  return bottomSheetItemsDesign(context, text);
                }
              ),
              TextField(
                controller: paymentController..text = model.finalPaidMonthly[monthIndex].toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: al.enterPaymentAmount,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: darkGreenColor),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: darkGreenColor),
                  )
                ),
              ),
              SizedBox(height: 16,),

              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Row(
                  children: [
// pay button
                    Flexible(
                      flex: 2,
                      child: GestureDetector(
                        onTap: (){
                          collection.installmentPayment(model, paymentController.text, additionalProfitState).then((value) {
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: darkGreenColor),
                          child: Center(
                              child: Text(al.pay,
                                  style: TextStyle(
                                      fontSize: 16, color: offWhiteColor))),
                        ),
                      ),
                    ),
                    SizedBox(width: 8,),
// cancel button
                    Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: darkGreenColor,
                            ),
                            child: Center(
                              child: Text(al.cancel,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: offWhiteColor,
                                  )),
                            ),
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        );
      });


}

bottomSheetItemsDesign(BuildContext context, String text){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
          text,
          style: Theme.of(context).textTheme.subtitle1),
      Divider(
        thickness: 1.5,
        color: lightGreenColor,
      ),
    ],
  );
}

circularProgressIndicatorWidget(){
  return CircularProgressIndicator(
    color: offWhiteColor,
  );
}
