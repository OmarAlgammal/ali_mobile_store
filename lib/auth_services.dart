import 'package:ali_mobile_store/sharedPreference.dart';
import 'package:ali_mobile_store/sharedWidgets/sharedSnackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'screens/homeScreen.dart'; // important

class AuthServices extends ChangeNotifier{

  AppLocalizations al;
  String vi;
  String uid;

  verifyPhoneNum(BuildContext context, String phoneNum) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
        phoneNumber: '+20$phoneNum',
        verificationCompleted: (PhoneAuthCredential credential) async{
          await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          });
        },
        verificationFailed: (FirebaseException exception){
          sharedSnackBar(context, al.invalidOTP);
        },
        codeSent: (String verificationId, int resendToken){
          vi = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId){

        },
      timeout: Duration(seconds: 30)
    );
  }
  
   Future verifyOtp(context, String otp, String name) async{
     PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: vi, smsCode: otp);
     try{
       UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
       String uid = userCredential.user.uid;
       SharedPreferenceModel sharedPreferenceModel = SharedPreferenceModel();
       sharedPreferenceModel.saveEmployeeSignInData(uid, name);
       Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
     }catch(e){
       al = AppLocalizations.of(context);
       sharedSnackBar(context, al.invalidOTP);
     }
  }

}