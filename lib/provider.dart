import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InstallmentState extends ChangeNotifier {

  List<InstallmentsModel> installmentList;
  // the index here means which installment will be paid first
  Future installmentPayment(BuildContext context, String installmentId, int paidByClient,
      int index, int biggestPriceToPay) async {


    // InstallmentsModel model;
    // await FirebaseDatabase.instance.reference().child('$_allInstallmentsCol/$installmentId').once().then((value) {
    //   Map<String, dynamic> map = Map.from(value.value);
    //   model = InstallmentsModel.toObject(map);
    // });
    //
    // model.paymentRecord.add(paidByClient);
    // model.paymentRecordDates.add(DateTime.now());
    // model.adjustmentTime = DateTime.now();

    // payment(context, model, index, paidByClient, null, biggestPriceToPay);

  }


//   Future<InstallmentsModel> payment(BuildContext context, InstallmentsModel model, int index, int paidByClient, DateTime thisDate, int biggestPriceToPay){
//     DateTime oldDate = (thisDate == null)? DateTime.now() : thisDate;
//     // get last index for installment
//     int lastIndex = model.installmentPeriod - 1;
//     // get all paid by client
//     int allPaidPrice = 0;
//     for (int i = 0; i < model.paymentRecord.length; i++){
//       if (model.paymentRecord[i] != null)
//         allPaidPrice += model.paymentRecord[i];
//     }
//
// // if paid by client is equal to biggest price to pay
//     if (paidByClient == biggestPriceToPay) {
//
//       int restFromPaid = paidByClient;
//       for (int nextIndex = index; restFromPaid > 0; nextIndex++){
//         // if this installment is last one
//         if (nextIndex == lastIndex) {
//           model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
//               [model.paidForEachInstallment[nextIndex] + restFromPaid]);
//           model.paymentDates.replaceRange(nextIndex, nextIndex + 1, [oldDate]);
//           model.restFromInstallment.replaceRange(
//               nextIndex, nextIndex + 1, [restFromPaid - model.finalPaidMonthly[nextIndex]]);
//           model.completeInstallment.replaceRange(nextIndex, nextIndex + 1, [true]);
//           model.finalPaidMonthly.replaceRange(
//               nextIndex, nextIndex + 1, [restFromPaid]);
//           model.lastInstallment.replaceRange(nextIndex, nextIndex +1, [true]);
//           model.finalProfit = allPaidPrice - model.phonePrice;
//           restFromPaid = 0;
//         }
//         // if the rest from paid is bigger than or equal to biggest price to pay
//         else if (restFromPaid >= model.finalPaidMonthly[nextIndex]) {
//           model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
//               [model.paidForEachInstallment[nextIndex] + model.finalPaidMonthly[nextIndex]]);
//           model.paymentDates.replaceRange(nextIndex, nextIndex + 1, [oldDate]);
//           model.completeInstallment.replaceRange(nextIndex, nextIndex + 1, [true]);
//           restFromPaid -= model.finalPaidMonthly[nextIndex];
//           // this line must be after calculate the new value of rest from paid
//           model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1, [0]);
//           model.lastInstallment.replaceRange(nextIndex, nextIndex +1, [true]);
//         }
//         // if the rest from paid is less than biggest price to pay
//         else if (restFromPaid < biggestPriceToPay){
//           model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
//               [model.paidForEachInstallment[nextIndex] + restFromPaid]);
//           model.paymentDates.replaceRange(nextIndex, nextIndex + 1, [oldDate]);
//           model.completeInstallment.replaceRange(nextIndex, nextIndex + 1, [true]);
//           model.finalPaidMonthly.replaceRange(
//               nextIndex, nextIndex + 1, [model.finalPaidMonthly[nextIndex] - restFromPaid]);
//           restFromPaid = 0;
//         }
//
//         if (restFromPaid == 0){
//           model.completeInstallment.replaceRange(nextIndex, nextIndex +1, [true]);
//           model.lastInstallment.replaceRange(nextIndex, nextIndex +1, [true]);
//           model.finalProfit = allPaidPrice - model.phonePrice;
//         }
//       }
//     }
//
// // if this month is last month
//     else if (index == lastIndex) {
//       model.paidForEachInstallment.replaceRange(index, index + 1,
//           [model.paidForEachInstallment[index] + paidByClient]);
//       model.paymentDates.replaceRange(index, index + 1, [oldDate]);
//       model.restFromInstallment.replaceRange(
//           index, index + 1, [model.finalPaidMonthly[index] - paidByClient]);
//       // if paid by client is equal to biggest price to pay with additional profit or not
//       if (paidByClient == biggestPriceToPay) {
//         model.completeInstallment.replaceRange(index, index + 1, [true]);
//         model.lastInstallment.replaceRange(index, index +1, [true]);
//         model.finalProfit = allPaidPrice - model.phonePrice;
//         // if paid by client is less than biggest price to pay with additional profit or not
//       }
//       else if (paidByClient < biggestPriceToPay) {
//         model.finalPaidMonthly.replaceRange(
//             index, index + 1, [model.finalPaidMonthly[index] - paidByClient]);
//       }
//       // if paid by client is more than  biggest price to pay with additional profit or not
//       else{
//         var al = AppLocalizations.of(context);
//         final scaffold = ScaffoldMessenger.of(context);
//         scaffold.showSnackBar(
//           SnackBar(
//             backgroundColor: darkRedColor,
//             content: Text(
//               al.biggestThanExpected,
//               style: TextStyle(fontSize: fourteenDimen),
//             ),
//           ),
//         );
//       }
//     }
//
// // if paid by client is equal to what should paid this month
//     else if (paidByClient == model.finalPaidMonthly[index]) {
//       model.paidForEachInstallment.replaceRange(index, index + 1,
//           [model.paidForEachInstallment[index] + paidByClient]);
//       model.paymentDates.replaceRange(index, index + 1, [oldDate]);
//       model.completeInstallment.replaceRange(index, index + 1, [true]);
//       model.finalPaidMonthly.replaceRange(index, index + 1, [0]);
//     }
//
// // if client paid less than what should paid this month
// // this condition paidByClient > 0 is necessary here
//     else if (paidByClient < model.finalPaidMonthly[index] && paidByClient > 0) {
//       model.paidForEachInstallment.replaceRange(index, index + 1,
//           [model.paidForEachInstallment[index] + paidByClient]);
//       model.paymentDates.replaceRange(index, index + 1, [oldDate]);
//       model.finalPaidMonthly.replaceRange(
//           index, index + 1, [model.finalPaidMonthly[index] - paidByClient]);
//     }
//
// // if client paid more than what should paid this month
//     else if (paidByClient > model.finalPaidMonthly[index]) {
//       int restFromPaid = paidByClient;
//       for (int nextIndex = index; restFromPaid > 0; nextIndex++) {
//
//         // if this month is last month
//         if (nextIndex == lastIndex) {
//
//           // if the rest from paid is equal to what should be paid in last month
//           if (restFromPaid == biggestPriceToPay) {
//             model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
//                 [model.paidForEachInstallment[nextIndex] + restFromPaid]);
//             model.paymentDates
//                 .replaceRange(nextIndex, nextIndex + 1, [oldDate]);
//             model.completeInstallment
//                 .replaceRange(nextIndex, nextIndex + 1, [true]);
//             model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1, [0]);
//             model.lastInstallment.replaceRange(nextIndex, nextIndex +1, [true]);
//             model.finalProfit = allPaidPrice - model.phonePrice;
//             restFromPaid = 0;
//           }
//           // if paid by client is less than what should be paid in last month
//           else if (restFromPaid < biggestPriceToPay) {
//             model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
//                 [model.paidForEachInstallment[nextIndex] + restFromPaid]);
//             model.paymentDates
//                 .replaceRange(nextIndex, nextIndex + 1, [oldDate]);
//             model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1,
//                 [model.finalPaidMonthly[nextIndex] - restFromPaid]);
//             restFromPaid = 0;
//           }
//           // if the rest from paid is bigger than expected in last month
//           else {
//             var al = AppLocalizations.of(context);
//             final scaffold = ScaffoldMessenger.of(context);
//             scaffold.showSnackBar(
//               SnackBar(
//                 backgroundColor: darkRedColor,
//                 content: Text(
//                   al.biggestThanExpected,
//                   style: TextStyle(fontSize: fourteenDimen),
//                 ),
//               ),
//             );
//           }
//
//         }
//
//         // if rest from paid by client is bigger than which paid this month
//         else if (restFromPaid > model.finalPaidMonthly[nextIndex]) {
//           model.paidForEachInstallment.replaceRange(
//               nextIndex, nextIndex + 1, [model.paidMonthlyDeal[nextIndex]]);
//           model.paymentDates
//               .replaceRange(nextIndex, nextIndex + 1, [oldDate]);
//           model.completeInstallment
//               .replaceRange(nextIndex, nextIndex + 1, [true]);
//           restFromPaid -= model.finalPaidMonthly[nextIndex];
//           // this line must be after
//           model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1, [0]);
//
//         }
//
//         else if (restFromPaid < model.finalPaidMonthly[nextIndex]) {
//           model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
//               [model.paidForEachInstallment[nextIndex] + restFromPaid]);
//           model.paymentDates
//               .replaceRange(nextIndex, nextIndex + 1, [oldDate]);
//           model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1,
//               [model.finalPaidMonthly[nextIndex] - restFromPaid]);
//           restFromPaid = 0;
//         }
//
//         // check if rest from paid is equal to this installment price
//         else {
//           model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1, [0]);
//           model.paidForEachInstallment.replaceRange(nextIndex, nextIndex + 1,
//               [model.finalPaidMonthly[nextIndex]]);
//           model.paymentDates.replaceRange(nextIndex, nextIndex + 1, [oldDate]);
//           model.completeInstallment.replaceRange(nextIndex, nextIndex + 1, [true]);
//           model.finalPaidMonthly.replaceRange(nextIndex, nextIndex + 1, [0]);
//           restFromPaid = 0;
//         }
//       }
//     }
//
//     // if this installment is completed it will added to complete installments list in firebase
//     if (model.completeInstallment[lastIndex] == true)
//       insertInstallment(model);
//
//
//     return updatedInstallment(model);
//   }



}
