
import 'package:ali_mobile_store/bloc/installmentsBloc/installments_event.dart';
import 'package:ali_mobile_store/bloc/installmentsBloc/installments_state.dart';
import 'package:ali_mobile_store/repository/firebaseInstallmentsRepository/firebase_installments_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InstallmentsBloc extends Bloc<InstallmentsEvent, InstallmentsState>{

  FirebaseInstallmentsRepository _firebaseInstallmentsRepository;

  InstallmentsBloc({FirebaseInstallmentsRepository firebaseInstallmentsRepository})
      : _firebaseInstallmentsRepository = firebaseInstallmentsRepository,
        super(InstallmentsLoading()){

    on<LoadInstallments>(_onLoadInstallments);
    on<LoadOneInstallment>(_onLoadOneInstallments);
    on<UpdateInstallments>(_onUpdateInstallments);
    on<UpdateOneInstallment>(_onUpdateOneInstallment);
    on<ErrorEvent>(_onErrorEvent);
  }


  void _onLoadInstallments(LoadInstallments loadInstallments, Emitter<InstallmentsState> emit){
    try{
      _firebaseInstallmentsRepository.getAllInstallments().listen((allInstallments) {
        add (UpdateInstallments(allInstallments: allInstallments));
      });
    }catch(e){
      emit(Error());
    }
  }

  void _onLoadOneInstallments(LoadOneInstallment loadOneInstallment, Emitter<InstallmentsState> emit){
    _firebaseInstallmentsRepository.getOneInstallment(loadOneInstallment.installmentId).listen((oneInstallment) {
      add(UpdateOneInstallment(oneInstallment: oneInstallment.first));
    });
  }

  void _onUpdateInstallments(UpdateInstallments event, Emitter<InstallmentsState> emit){
    emit(InstallmentsLoaded(allInstallments: event.allInstallments));
  }

  void _onUpdateOneInstallment(UpdateOneInstallment updateOneInstallment, Emitter<InstallmentsState> emit){
    emit(OneInstallmentLoaded(updateOneInstallment.oneInstallment));
  }

  void _onErrorEvent(ErrorEvent event, Emitter<InstallmentsState> emit){
    print('error event');
  }


}