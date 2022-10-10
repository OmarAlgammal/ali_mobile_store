import 'package:ali_mobile_store/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // important

Widget sharedLoadingWidget(String loadingText) {
  return Text(
    loadingText,
    style: TextStyle(
        fontSize: 18, color: darkGreenColor, fontWeight: FontWeight.bold),
  );
}
