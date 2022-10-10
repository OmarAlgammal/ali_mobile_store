import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:equatable/equatable.dart';

abstract class InstallmentsEvent extends Equatable{}

class LoadInstallments extends InstallmentsEvent{

  @override
  List<Object> get props => throw UnimplementedError();
}

class LoadOneInstallment extends InstallmentsEvent{
  final String installmentId;

  LoadOneInstallment({this.installmentId});

  @override
  List<Object> get props => throw UnimplementedError();

}

class UpdateOneInstallment extends InstallmentsEvent{
  final InstallmentsModel oneInstallment;

  UpdateOneInstallment({this.oneInstallment});

  @override
  List<Object> get props => throw UnimplementedError();
}

class UpdateInstallments extends InstallmentsEvent{

  final List<InstallmentsModel> allInstallments;

  UpdateInstallments({this.allInstallments});
  @override
  List<Object> get props => [allInstallments];

}

class ErrorEvent extends InstallmentsEvent{
  @override
  List<Object> get props => throw UnimplementedError();
}

