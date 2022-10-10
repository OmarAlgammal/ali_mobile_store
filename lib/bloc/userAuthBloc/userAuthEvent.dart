import 'package:ali_mobile_store/bloc/userAuthBloc/userAuthState.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class UserAuthEvent extends Equatable {}

class AppStartedEvent extends UserAuthEvent{
  @override
  List<Object> get props => throw UnimplementedError();

}

class InitialEmployeeAuthEvent extends UserAuthEvent{
  @override
  List<Object> get props => throw UnimplementedError();
}

class RegisterEmployee extends UserAuthEvent {
  final BuildContext context;
  final String phoneNum;

  RegisterEmployee({this.context, this.phoneNum});

  @override
  List<Object> get props => throw UnimplementedError();
}

class VerifyEmployeeOtpNumEvent extends UserAuthEvent {
  final BuildContext context;
  final String  phoneNum;
  final String otp;
  final String verificationId;

  VerifyEmployeeOtpNumEvent({this.context, this.phoneNum, this.otp, this.verificationId});

  @override
  List<Object> get props => throw UnimplementedError();
}

class WaitingApprovalEvent extends UserAuthEvent {
  @override
  List<Object> get props => throw UnimplementedError();
}

class InValidEmployeePhoneNumEvent extends UserAuthEvent {
  @override
  List<Object> get props => throw UnimplementedError();
}

class EmployeeCodeSentEvent extends UserAuthEvent{
  final String phoneNum;
  final String verificationId;

  EmployeeCodeSentEvent({this.phoneNum, this.verificationId});

  @override
  List<Object> get props => throw UnimplementedError();
}

class EmployeeAuthenticatedEvent extends UserAuthEvent {
  @override
  List<Object> get props => throw UnimplementedError();
}



class InitialEmployerPasswordEvent extends UserAuthEvent{
  @override
  List<Object> get props => throw UnimplementedError();
}

class InitialEmployerAuthEvent extends UserAuthEvent{
  @override
  List<Object> get props => throw UnimplementedError();
}

class VerifyEmployerPassword extends UserAuthEvent{
  final BuildContext context;
  final String password;

  VerifyEmployerPassword({this.context, this.password});

  @override
  List<Object> get props => throw UnimplementedError();

}

class RegisterEmployer extends UserAuthEvent {
  final BuildContext context;
  final String phoneNum;

  RegisterEmployer({this.context, this.phoneNum});

  @override
  List<Object> get props => throw UnimplementedError();
}

class VerifyEmployerOtpNum extends UserAuthEvent {
  final BuildContext context;
  final String  phoneNum;
  final String otp;
  final String verificationId;

  VerifyEmployerOtpNum({this.context, this.phoneNum, this.otp, this.verificationId});

  @override
  List<Object> get props => throw UnimplementedError();
}

class EmployerAuthenticatedEvent extends UserAuthEvent {
  @override
  List<Object> get props => throw UnimplementedError();
}

class InValidEmployerPhoneNumEvent extends UserAuthEvent {
  @override
  List<Object> get props => throw UnimplementedError();
}

class EmployerCodeSentEvent extends UserAuthEvent{
  final String phoneNum;
  final String verificationId;

  EmployerCodeSentEvent({this.phoneNum, this.verificationId});

  @override
  List<Object> get props => throw UnimplementedError();
}




// class InitialEmployeeAuthEvent extends UserAuthEvent {
//   @override
//   List<Object> get props => throw UnimplementedError();
// }


// class AuthenticatedEvent extends UserAuthEvent {
//   @override
//   List<Object> get props => throw UnimplementedError();
// }
//
// class CodeSentEvent extends UserAuthEvent {
//   final String verificationId;
//   final String phoneNum;
//   CodeSentEvent({this.phoneNum, this.verificationId});
//   @override
//   List<Object> get props => throw UnimplementedError();
// }
//

//
// class InvalidEmployeePhoneNumEvent extends UserAuthEvent{
//   final BuildContext context;
//   InvalidEmployeePhoneNumEvent({this.context});
//
//   @override
//   List<Object> get props => throw UnimplementedError();
// }
//
// class InvalidEmployerPhoneNumEvent extends UserAuthEvent{
//   final BuildContext context;
//   InvalidEmployerPhoneNumEvent({this.context});
//
//   @override
//   List<Object> get props => throw UnimplementedError();
// }
//
// class IncorrectOtpEvent extends UserAuthEvent{
//   final String phoneNum;
//   final String verificationId;
//
//   IncorrectOtpEvent({this.phoneNum, this.verificationId});
//
//   @override
//   List<Object> get props => throw UnimplementedError();
//
// }
//
// class InitialEmployerAuthEvent extends UserAuthEvent{
//   @override
//   List<Object> get props => throw UnimplementedError();
// }
//
//
//
// class AuthExceptionEvent extends UserAuthEvent {
//   @override
//   List<Object> get props => throw UnimplementedError();
// }
