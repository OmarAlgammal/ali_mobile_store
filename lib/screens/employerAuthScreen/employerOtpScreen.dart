import 'dart:async';
import 'package:ali_mobile_store/bloc/userAuthBloc/userAuthBloc.dart';
import 'package:ali_mobile_store/bloc/userAuthBloc/userAuthEvent.dart';
import 'package:ali_mobile_store/bloc/userAuthBloc/userAuthState.dart';
import 'package:ali_mobile_store/screens/employerAuthScreen/employerAuthScreen.dart';
import 'package:ali_mobile_store/sharedWidgets/sharedLogo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // important


class EmployerOTPScreen extends StatefulWidget {
  final String phoneNum;
  final String verificationId;


  EmployerOTPScreen({this.phoneNum, this.verificationId});

  @override
  State<EmployerOTPScreen> createState() => _EmployerOTPScreenState();
}

class _EmployerOTPScreenState extends State<EmployerOTPScreen> {
  AppLocalizations al;

  bool showCircularWidget = false;

  Timer _timer;
  String _otp;

  final int _allTimerValue = 120;
  int _seconds = 120;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    al = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: offWhiteColor,
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            sharedLogoWidget(context),
                            SizedBox(height: 24,),
                            Text(al.verifyPhoneNum,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${al.waitingOTP} \n +20 ${widget.phoneNum}',
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 18,
                            ),
                            otpTextFieldWidget(),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          children: [
                            verifyPhoneNumButtonWidget(),
                            SizedBox(height: 16,),
                            resendOtpNumButtonWidget(),
                            changePhoneNumButtonWidget()
                          ],
                        ),
                      )
                    ],
                  ),
                )

              ],
            )
        ),
      ),
    );
  }

  otpTextFieldWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width /2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: PinCodeTextField(
              appContext: context,
              keyboardType: TextInputType.number,
              length: 6,
              animationType: AnimationType.scale,

              pinTheme: PinTheme(
                shape: PinCodeFieldShape.underline,
                fieldHeight: 30,
                fieldWidth: 20,
                activeColor: darkGreenColor,
                inactiveColor: darkGreenColor,
                selectedColor: darkGreenColor,
              ),
              animationDuration: Duration(milliseconds: 300),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              onCompleted: (_otp) {
                this._otp = _otp;
              },
              onChanged: (value) {

              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                return true;
              },
            ),
          ),
        ],
      ),
    );
  }

  verifyPhoneNumButtonWidget(){
    return BlocBuilder<UserAuthBloc, UserAuthState>(
      builder: (context, state) {
        if (state is InvalidEmployerOtpNum){
          BlocProvider.of<UserAuthBloc>(context).add(EmployerCodeSentEvent(phoneNum: widget.phoneNum, verificationId: widget.verificationId));
          showCircularWidget = false;
        }
        return InkWell(
          onTap: (){
            setState(() {
              showCircularWidget = true;
              BlocProvider.of<UserAuthBloc>(context).add(VerifyEmployerOtpNum(context: context,phoneNum: widget.phoneNum, otp: _otp, verificationId:  widget.verificationId));
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              height: 48,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                color: darkGreenColor,
              ),
              child: Center(
                child: (showCircularWidget)? circularProgressWidget() : verifyOtpButtonWidget(),
              ),
            ),
          ),
        );
      }
    );
  }

  verifyOtpButtonWidget(){
    return Text(
      al.verifyPhoneNum,
      style: TextStyle(color: offWhiteColor),
    );
  }

  circularProgressWidget(){
    return SizedBox(
      width: 48,
      height: 36,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: offWhiteColor,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  resendOtpNumButtonWidget(){
    return BlocBuilder<UserAuthBloc, UserAuthState>(
      builder: (context, state) {

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: ListTile(
              enabled: (_seconds == _allTimerValue)? true : false,
              onTap: (){
                startTimer();
                BlocProvider.of<UserAuthBloc>(context).add(RegisterEmployee(context: context, phoneNum: widget.phoneNum));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              dense: true,
              leading: Icon(
                messageIcon,
                color: (_seconds == _allTimerValue)? darkGreenColor : lightGreyColor,
              ),
              trailing: Text(
                  _seconds.toString(),
                  style: TextStyle(color: (_seconds == _allTimerValue)? darkGreenColor : lightGreyColor),
              ),
              title: Align(
                alignment: Alignment(1.2, 0),
                child: Text(
                  al.resendOtp,
                  style: TextStyle(color: (_seconds == _allTimerValue)? darkGreenColor : lightGreyColor,),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  changePhoneNumButtonWidget(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: ListTile(
          onTap: (){
            BlocProvider.of<UserAuthBloc>(context).add(InitialEmployerAuthEvent());
          },
          contentPadding: EdgeInsets.symmetric(horizontal: 0),
          dense: true,
          leading: Icon(
            numberIcon,
            color: darkGreenColor,
          ),
          title: Align(
            alignment: Alignment(1.2, 0),
            child: Text(
              al.changeYourNum,
              style: TextStyle(color: darkGreenColor),
            ),
          ),
        ),
      ),
    );
  }

  startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        setState(() {
          _timer.cancel();
          _seconds = _allTimerValue;
        });
      } else {
        setState(() {
          --_seconds;
        });
      }
    });
  }
}

