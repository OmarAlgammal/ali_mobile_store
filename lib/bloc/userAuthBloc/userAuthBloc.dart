
import 'package:ali_mobile_store/bloc/userAuthBloc/userAuthEvent.dart';
import 'package:ali_mobile_store/bloc/userAuthBloc/userAuthState.dart';
import 'package:ali_mobile_store/repository/userAuthRepository/userAuthRepository.dart';
import 'package:ali_mobile_store/screens/employeeAuthScreens/employeeAuthScreen.dart';
import 'package:ali_mobile_store/sharedWidgets/sharedSnackBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserAuthBloc extends Bloc<UserAuthEvent, UserAuthState>{

  UserAuthRepository userAuthRepository;

  UserAuthBloc({this.userAuthRepository}) : super(LoadingState()){

    on<AppStartedEvent>(_onAppStarted);

    on<InitialEmployeeAuthEvent>(_onInitialEmployeeAuth);
    on<RegisterEmployee>(_onRegisterEmployee);

    on<VerifyEmployeeOtpNumEvent>(_onVerifyEmployeeOtpNum);
    on<WaitingApprovalEvent>(_onWaitingApproval);
    on<InValidEmployeePhoneNumEvent>(_onInValidEmployeePhoneNum);
    on<EmployeeCodeSentEvent>(_onEmployeeCodeSent);
    on<EmployeeAuthenticatedEvent>(_onEmployeeAuthenticated);

    on<InitialEmployerPasswordEvent>(_onInitialEmployerPassword);
    on<InitialEmployerAuthEvent>(_onInitialEmployerAuth);
    on<VerifyEmployerPassword>(_onVerifyEmployerPassword);
    on<RegisterEmployer>(_onRegisterEmployer);
    on<VerifyEmployerOtpNum>(_onVerifyEmployerOtp);
    on<EmployerAuthenticatedEvent>(_onEmployerAuthenticatedEvent);
    on<InValidEmployerPhoneNumEvent>(_onInvalidEmployerPhoneNumber);
    on<EmployerCodeSentEvent>(_onEmployerCodeSent);

  }

  void _onAppStarted(AppStartedEvent event, Emitter<UserAuthState> emit) async{
    var result = await userAuthRepository.isAuthenticated();

     if (result is bool ){
       // here return only because by default it's return initial employee state
       if (result)
         return emit(EmployeeAuthenticated());

       return emit(InitialEmployeeAuthState());

     }

    bool isSignedIn = result[0];
    bool isAccepted = result[1];

    print('is signed in $isSignedIn and $isAccepted');
    if (isSignedIn && isAccepted)
      return emit(EmployeeAuthenticated());

    return emit(WaitingApprovalState());
  }

  _onInitialEmployeeAuth(InitialEmployeeAuthEvent event, Emitter<UserAuthState> emit){
    return emit(InitialEmployeeAuthState());
  }

  Future _onRegisterEmployee(RegisterEmployee event, Emitter<UserAuthState> emit) async{
    await userAuthRepository.registerEmployee(event.context, event.phoneNum);
  }

  _onVerifyEmployeeOtpNum(VerifyEmployeeOtpNumEvent event, Emitter<UserAuthState> emit) async{
    final result = await userAuthRepository.verifyEmployeeOtpNum(event.context, event.phoneNum, event.otp, event.verificationId);

    if (result is String)
      return emit(WaitingApprovalState());

    return emit(InvalidEmployeeOtpNum(phoneNum: event.phoneNum, verificationId: event.verificationId));
  }

  _onWaitingApproval(WaitingApprovalEvent event, Emitter<UserAuthState> emit){
    return emit(WaitingApprovalState());
  }

  _onInValidEmployeePhoneNum(InValidEmployeePhoneNumEvent event, Emitter<UserAuthState> emit){
    return emit(InvalidEmployeePhoneNum());
  }

  _onEmployeeCodeSent(EmployeeCodeSentEvent event, Emitter<UserAuthState> emit){
    return emit(EmployeeCodeSent(phoneNum: event.phoneNum, verificationId: event.verificationId));
  }

  _onEmployeeAuthenticated(EmployeeAuthenticatedEvent event, Emitter<UserAuthState> emit){
    return emit(EmployeeAuthenticated());
  }



  _onInitialEmployerPassword(InitialEmployerPasswordEvent event, Emitter<UserAuthState> emit){
    return emit(InitialEmployerPasswordState());
  }

  _onInitialEmployerAuth(InitialEmployerAuthEvent event, Emitter<UserAuthState> emit){
    return emit(InitialEmployerAuthState());
  }

  _onVerifyEmployerPassword(VerifyEmployerPassword event, Emitter<UserAuthState> emit) async{
    bool passwordState = await userAuthRepository.verifyEmployerPassword(event.password);
    if (passwordState)
      return emit(CorrectEmployerPassword());

    AppLocalizations al = AppLocalizations.of(event.context);
    sharedSnackBar(event.context, al.wrongPassword);
    return emit(WrongEmployerPassword());
  }

  Future _onRegisterEmployer(RegisterEmployer event, Emitter<UserAuthState> emit) async{
    await userAuthRepository.registerEmployer(event.context, event.phoneNum);
  }

  _onVerifyEmployerOtp(VerifyEmployerOtpNum event, Emitter<UserAuthState> emit) async{
    final result = await userAuthRepository.verifyEmployerOtpNum(event.context, event.phoneNum, event.otp, event.verificationId);

    if (result is String)
      return emit(EmployerAuthenticated());

    return emit(InvalidEmployerOtpNum(phoneNum: event.phoneNum, verificationId: event.verificationId));
  }

  _onEmployerAuthenticatedEvent(EmployerAuthenticatedEvent event, Emitter<UserAuthState> emit){
    return emit(EmployerAuthenticated());
  }

  _onInvalidEmployerPhoneNumber(InValidEmployerPhoneNumEvent event, Emitter<UserAuthState> emit){
    return emit(InvalidEmployerPhoneNum());
  }

  _onEmployerCodeSent(EmployerCodeSentEvent event, Emitter<UserAuthState> emit){
    return emit(EmployerCodeSent(phoneNum: event.phoneNum, verificationId: event.verificationId));
  }

}