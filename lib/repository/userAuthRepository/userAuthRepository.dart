import 'dart:io' show Platform;
import 'package:ali_mobile_store/Models/employeeModel.dart';
import 'package:ali_mobile_store/bloc/userAuthBloc/userAuthBloc.dart';
import 'package:ali_mobile_store/bloc/userAuthBloc/userAuthEvent.dart';
import 'package:ali_mobile_store/sharedWidgets/sharedSnackBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart'; // important


class UserAuthRepository {

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  CollectionReference employers = FirebaseFirestore.instance.collection('employers');
  CollectionReference employees = FirebaseFirestore.instance.collection('employees');

  verifyEmployerPassword(String password) async{
   QuerySnapshot<Object> query = await employers.where('password', isEqualTo: password).get();

   // return true if the password is in fire store
   if (query.size > 0)
     return true;
   else
     return false;
  }

  Future isAuthenticated() async{
    final currentUser =  _firebaseAuth.currentUser;

    print('current user is ${currentUser != null}');
    // if there is no user authenticated;
      if (currentUser != null){
      print('current phone num is ${currentUser.phoneNumber}');
      DocumentSnapshot employeeDocumentSnapshot = await employees.doc(currentUser.phoneNumber).get();
      Map<String, dynamic> employeeMap = employeeDocumentSnapshot.data();
      print('employee map  is ${employeeMap != null}');
      // if the user is one of employees
      if (employeeMap != null){
        bool isAccepted = employeeMap['accepted'];
        if (isAccepted)
          return [true, true];

        return [true, false];
      }

      // if the user authenticated is employer
      return true;
    }


    // if there is no user authenticated
    return false;

  }

  Future registerEmployee(BuildContext context, String phoneNum) async{
    AppLocalizations al = AppLocalizations.of(context);
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: '+20$phoneNum',
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async{
        await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        BlocProvider.of<UserAuthBloc>(context).add(WaitingApprovalEvent());
      },
      verificationFailed: (FirebaseAuthException firebaseAuthException){
        sharedSnackBar(context, al.invalidPhoneNum);

        BlocProvider.of<UserAuthBloc>(context).add(InValidEmployeePhoneNumEvent());
      },
      codeSent: (String verificationId, int resendCode){
        BlocProvider.of<UserAuthBloc>(context).add(EmployeeCodeSentEvent(phoneNum: phoneNum, verificationId: verificationId));
      },
      codeAutoRetrievalTimeout: (String verificationId){
        sharedSnackBar(context, al.error);
      },
      timeout: Duration(seconds: 120),
      forceResendingToken: 30
    );
  }

  Future registerEmployer(BuildContext context, String phoneNum) async{
    AppLocalizations al = AppLocalizations.of(context);
    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: '+20$phoneNum',
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async{
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
          BlocProvider.of<UserAuthBloc>(context).add(EmployerAuthenticatedEvent());
        },
        verificationFailed: (FirebaseAuthException firebaseAuthException){
          sharedSnackBar(context, al.invalidPhoneNum);

          BlocProvider.of<UserAuthBloc>(context).add(InValidEmployerPhoneNumEvent());
        },
        codeSent: (String verificationId, int resendCode){
          BlocProvider.of<UserAuthBloc>(context).add(EmployerCodeSentEvent(phoneNum: phoneNum, verificationId: verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId){
          sharedSnackBar(context, al.error);
        },
        timeout: Duration(seconds: 120),
        forceResendingToken: 30
    );
  }

  Future verifyEmployeeOtpNum(BuildContext context, String phoneNum, String otp, String verificationId) async{
    AppLocalizations al = AppLocalizations.of(context);

    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otp);
    try{
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      String uid = userCredential.user.uid;
      await saveEmployeeData(phoneNum);
      return uid;
    }catch(e){
      sharedSnackBar(context, al.invalidOTP);
      return null;
    }
  }

  Future verifyEmployerOtpNum(BuildContext context, String phoneNum, String otp, String verificationId) async{
    AppLocalizations al = AppLocalizations.of(context);

    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otp);
    try{
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      String uid = userCredential.user.uid;
      return uid;
    }catch(e){
      al = AppLocalizations.of(context);
      sharedSnackBar(context, al.invalidOTP);
      return null;
    }
  }


  Future saveEmployeeData(String mobileNum) async{
    Map<String, dynamic> map = {'name': '', 'mobileNum': '+20$mobileNum', 'accepted': false};
    await employees.doc('+20$mobileNum').set(map);
  }

  getUserId(){
    _firebaseAuth.currentUser.uid;
  }
}
