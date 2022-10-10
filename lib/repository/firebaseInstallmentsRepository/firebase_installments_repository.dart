

import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseInstallmentsRepository {

  CollectionReference clientsCollection = FirebaseFirestore.instance.collection('clients');
  CollectionReference completeInstallmentsCollection = FirebaseFirestore.instance.collection('completeInstallments');

  Stream<List<InstallmentsModel>> getAllInstallments() async*{
    yield* clientsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((installment) => InstallmentsModel.toObject(installment.data())).toList();
    });
  }

  // get this installment from clients collection or from complete installme
  Stream<List<InstallmentsModel>> getOneInstallment(String installmentId) async*{

    try{
      yield* clientsCollection.where('installmentId', isEqualTo: installmentId).snapshots().map((event) {
        return event.docs.map((oneInstallment) => InstallmentsModel.toObject(oneInstallment.data()));
      });
    }catch(e){
      yield* completeInstallmentsCollection.where('installmentId', isEqualTo: installmentId).snapshots().map((event) {
        return event.docs.map((oneInstallment) => InstallmentsModel.toObject(oneInstallment.data()));
      });
    }


  }

}