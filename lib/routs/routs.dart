
import 'package:ali_mobile_store/screens/employeeAuthScreens/employeeAuthScreen.dart';
import 'package:ali_mobile_store/screens/employerAuthScreen/employerOtpScreen.dart';
import 'package:ali_mobile_store/screens/employerAuthScreen/employerAuthScreen.dart';
import 'package:ali_mobile_store/screens/employerAuthScreen/employerPasswordScreen.dart';
import 'package:ali_mobile_store/screens/paymentRecordScreen.dart';
import 'package:ali_mobile_store/screens/bottomNavigationScreens/completeInstallments.dart';
import 'package:ali_mobile_store/screens/installmentDataScreen.dart';
import 'package:ali_mobile_store/screens/bottomNavigationScreens/installmentsListScreen.dart';
import 'package:ali_mobile_store/screens/bottomNavigationScreens/todayInstallmentsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ali_mobile_store/screens/clientPageScreen.dart';

import '../screens/homeScreen.dart';

const String otpScreen = 'otpScreen';
const String homeScreen = 'homeScreen';
const String employerPasswordScreen = 'employerPasswordScreen';
const String employeeAuthScreen = 'employeeAuthScreen';
const String employerAuthScreen = 'employerAuthScreen';
const String todayInstallments = 'todayInstallmentsScreen';
const String installmentsList = 'installmentsListScreen';
const String completeInstallments = 'completeInstallmentsScreen';
const String installmentData = 'installmentDataScreen';
const String clientPage = 'clientScreen';
const String paymentRecord = 'paymentRecordScreen';

Route<dynamic> generateRoute(RouteSettings settings){
  switch(settings.name){
    case employerPasswordScreen:
      return MaterialPageRoute(builder: (context) => EmployerPasswordScreen());
    case employerAuthScreen:
      return MaterialPageRoute(builder: (context) => EmployerAuthScreen());
    case employeeAuthScreen:
      return MaterialPageRoute(builder: (context) => EmployeeAuthScreen());
    case otpScreen:
      return MaterialPageRoute(builder: (context) => EmployerOTPScreen());
    case homeScreen:
      return MaterialPageRoute(builder: (context) => HomeScreen());
    case todayInstallments:
      return MaterialPageRoute(builder: (context) => TodayInstallmentsScreen());
    case installmentsList:
      return MaterialPageRoute(builder: (context) => InstallmentsListScreen());
    case installmentData:
      return MaterialPageRoute(builder: (context) => InstallmentsDataScreen());
    case completeInstallments:
      return MaterialPageRoute(builder: (context) => CompleteInstallmentsScreen());
    case clientPage:
      return MaterialPageRoute(builder: (context) => ClientPageScreen());
    case paymentRecord:
      return MaterialPageRoute(builder: (context) => PaymentRecordScreen());

    default: throw('this route name does not exist');

  }
}