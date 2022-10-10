import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:ali_mobile_store/collection.dart';
import 'constants.dart';

TextStyle stateTheme(
    Collection collection, InstallmentsModel model, int monthIndex) {
  return TextStyle(
    color: collection
        .determineInstallmentStateInMonth(model, monthIndex)
        .borderColor,
  );
}

TextStyle normalPaidMonthlyTheme(
    Collection collection, InstallmentsModel model, int monthIndex) {
  return TextStyle(
      color: darkGreenColor,
      fontSize: 16,
      decoration: (collection.determineFinalPaidVisibility(model, monthIndex)
          ? TextDecoration.lineThrough
          : TextDecoration.none));
}

TextStyle boldPaidMonthlyTheme(
    Collection collection, InstallmentsModel model, int monthIndex) {
  return TextStyle(
      color: darkGreenColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      decoration: (collection.determineFinalPaidVisibility(model, monthIndex)
          ? TextDecoration.lineThrough
          : TextDecoration.none));
}


TextStyle numTheme() {
  return TextStyle(
      color: offWhiteColor, fontSize: 16, fontWeight: FontWeight.bold);
}
