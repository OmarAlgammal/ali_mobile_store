import 'package:ali_mobile_store/bloc/userAuthBloc/userAuthBloc.dart';
import 'package:ali_mobile_store/bloc/userAuthBloc/userAuthEvent.dart';
import 'package:ali_mobile_store/constants.dart';
import 'package:ali_mobile_store/repository/userAuthRepository/userAuthRepository.dart';
import 'package:ali_mobile_store/screens/employeeAuthScreens/WaitingApprovalScreen.dart';
import 'package:ali_mobile_store/screens/employeeAuthScreens/employeeAuthScreen.dart';
import 'package:ali_mobile_store/screens/employeeAuthScreens/employeeOtpScreen.dart';
import 'package:ali_mobile_store/screens/employerAuthScreen/employerOtpScreen.dart';
import 'package:ali_mobile_store/screens/employerAuthScreen/employerAuthScreen.dart';
import 'package:ali_mobile_store/screens/employerAuthScreen/employerPasswordScreen.dart';
import 'package:ali_mobile_store/screens/homeScreen.dart';
import 'package:ali_mobile_store/screens/loadingScreen.dart';
import 'package:ali_mobile_store/widgets/sharedLoadingWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'bloc/userAuthBloc/userAuthState.dart';
import 'package:ali_mobile_store/routs/routs.dart' as rout;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: offWhiteColor,
    statusBarIconBrightness: Brightness.dark
  ));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  AppLocalizations al;

  @override
  Widget build(BuildContext context) {
    al = AppLocalizations.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserAuthBloc>(
          create: ((context) => UserAuthBloc(userAuthRepository: UserAuthRepository())..add(AppStartedEvent())),
        )
      ],
      child: MaterialApp(
          theme: ThemeData(
            focusColor: darkGreenColor,
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: lightGreenColor,
              cursorColor: greenColor,
              selectionHandleColor: greenColor
            ),
            textTheme: TextTheme(
              // for titles in appbar and in alert dialog
              headline6: TextStyle(color: Colors.white, fontSize: 24, height: 1.4),
              // for main item (client name, date and price)
              headline3: TextStyle(color: Colors.blue,),
              // for numbers in main item
              headline4: TextStyle(color: Colors.yellow,),
              // for subtitle in dialog
              headline5: TextStyle(color: Colors.deepPurpleAccent,),
              // for content in alert dialog and normal titles in widgets
              subtitle1: TextStyle(color: darkGreenColor,),
              // for tab bar
              subtitle2: TextStyle(color: Colors.orange,),
              // for any bold normal text
              bodyText1: TextStyle(color: darkGreenColor, fontSize: 16, fontWeight: FontWeight.bold),
              // for any normal text
              bodyText2: TextStyle(color: darkGreenColor, fontSize: 14,),
            ),
            tabBarTheme: TabBarTheme(
              labelColor: greenColor
            ),
            checkboxTheme: CheckboxThemeData(
              checkColor: MaterialStateProperty.all(offWhiteColor),
              fillColor: MaterialStateProperty.all(darkGreenColor),
            ),
          ),
          debugShowCheckedModeBanner: false,
          onGenerateRoute: rout.generateRoute,
          // initialRoute: rout.homeScreen,
          localizationsDelegates:
          AppLocalizations.localizationsDelegates, // important
          supportedLocales: AppLocalizations.supportedLocales, // important
          home: BlocBuilder<UserAuthBloc, UserAuthState>(
            builder: (context, state){

              // if (state is InvalidEmployeePhoneNum)
              //   return EmployeeAuthScreen();
              // if (state is EmployeeCodeSent)
              //   return EmployeeOTPScreen(phoneNum: state.phoneNum, verificationId: state.verificationId,);
              // if (state is InvalidEmployeeOtpNum)
              //   return EmployeeOTPScreen(phoneNum: state.phoneNum, verificationId: state.verificationId,);
              // if (state is WaitingApprovalState)
              //   return WaitingApprovalScreen();
              //
              //
              // if (state is InitialEmployerPasswordState || state is WrongEmployerPassword)
              //   return EmployerPasswordScreen();
              // if (state is InitialEmployerAuthState || state is CorrectEmployerPassword || state is InvalidEmployerPhoneNum)
              //   return EmployerAuthScreen();
              // if (state is EmployerCodeSent)
              //   return EmployerOTPScreen(phoneNum: state.phoneNum, verificationId: state.verificationId,);
              // if (state is InvalidEmployerOtpNum)
              //   return EmployerOTPScreen(phoneNum: state.phoneNum, verificationId: state.verificationId,);
              // if (state is InvalidEmployerPhoneNum)
              //   return EmployerAuthScreen();
              //
              //
              // if (state is EmployeeAuthenticated || state is EmployerAuthenticated)
              //   return HomeScreen();
              //
              //
              // return LoadingScreen();
              return HomeScreen();
            },
          )
      ),
    );
  }


}

