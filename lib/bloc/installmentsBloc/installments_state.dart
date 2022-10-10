import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:equatable/equatable.dart';

abstract class InstallmentsState extends Equatable {}

class InstallmentsLoading extends InstallmentsState{
  @override
  List<Object> get props => throw UnimplementedError();
}

class InstallmentsLoaded extends InstallmentsState{
  final  allInstallments;


  InstallmentsLoaded({this.allInstallments});

  @override
  List<Object> get props => [allInstallments];

}

class OneInstallmentLoaded extends InstallmentsState{
  final InstallmentsModel oneInstallment;

  OneInstallmentLoaded(this.oneInstallment);

  @override
  List<Object> get props => [oneInstallment];
}

class Error extends InstallmentsState{
  @override
  List<Object> get props => throw UnimplementedError();

}