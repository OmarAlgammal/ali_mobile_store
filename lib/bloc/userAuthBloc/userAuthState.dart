
import 'package:equatable/equatable.dart';

abstract class UserAuthState extends Equatable{}

class LoadingState extends UserAuthState{
  @override
  List<Object> get props => throw UnimplementedError();
}

class InitialEmployeeAuthState extends UserAuthState{
  @override
  List<Object> get props => throw UnimplementedError();
}

class InvalidEmployeePhoneNum extends UserAuthState{
  @override
  List<Object> get props => throw UnimplementedError();
}

class EmployeeCodeSent extends UserAuthState{
  final String phoneNum;
  final String verificationId;

  EmployeeCodeSent({this.phoneNum, this.verificationId});

  @override
  List<Object> get props => throw UnimplementedError();
}

class InvalidEmployeeOtpNum extends UserAuthState{
  final String phoneNum;
  final String verificationId;

  InvalidEmployeeOtpNum({this.phoneNum, this.verificationId});

  @override
  List<Object> get props => throw UnimplementedError();
}

class WaitingApprovalState extends UserAuthState{

  @override
  List<Object> get props => throw UnimplementedError();
}

class EmployeeAuthenticated extends UserAuthState{
  @override
  List<Object> get props => throw UnimplementedError();
}




class InitialEmployerPasswordState extends UserAuthState{
  @override
  List<Object> get props => throw UnimplementedError();
}

class InitialEmployerAuthState extends UserAuthState{
  @override
  List<Object> get props => throw UnimplementedError();
}

class EmployerAuthenticated extends UserAuthState{
  @override
  List<Object> get props => throw UnimplementedError();
}


class CorrectEmployerPassword extends UserAuthState{
  @override
  List<Object> get props => throw UnimplementedError();
}

class WrongEmployerPassword extends UserAuthState{
  @override
  List<Object> get props => throw UnimplementedError();
}


class InvalidEmployerPhoneNum extends UserAuthState{
  @override
  List<Object> get props => throw UnimplementedError();
}

class InvalidEmployerOtpNum extends UserAuthState{
  final String phoneNum;
  final String verificationId;

  InvalidEmployerOtpNum({this.phoneNum, this.verificationId});
  @override
  List<Object> get props => throw UnimplementedError();
}

class EmployerCodeSent extends UserAuthState{
  final String phoneNum;
  final String verificationId;

  EmployerCodeSent({this.phoneNum, this.verificationId});

  @override
  List<Object> get props => throw UnimplementedError();
}




class AuthException extends UserAuthState{
  @override
  List<Object> get props => throw UnimplementedError();
}