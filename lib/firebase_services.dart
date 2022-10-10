import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FireStoreServices{

  final String uid;
  FireStoreServices({this.uid});

  CollectionReference employeesCollection = FirebaseFirestore.instance.collection('employees');
  CollectionReference clientsCollection = FirebaseFirestore.instance.collection('clients');
  CollectionReference completeInstallmentsCollection = FirebaseFirestore.instance.collection('completeInstallments');
  CollectionReference nextInstallmentNumCollection = FirebaseFirestore.instance.collection('nextInstallmentNum');
  CollectionReference currentYearCollection = FirebaseFirestore.instance.collection('currentYear');

  Future setClient(InstallmentsModel model) async{
    await clientsCollection.doc(model.installmentId).set(model.toMap()).then((value) async{
      await setCurrentYear();
      await setNexInstallmentNum();
    });
  }

  getClient(String installmentId, String collectionName){
    if (collectionName == 'clients')
      return clientsCollection.where('installmentId', isEqualTo: installmentId).snapshots();

    return completeInstallmentsCollection.where('installmentId', isEqualTo: installmentId).snapshots();
  }

  deleteClient(InstallmentsModel model) async{
    await clientsCollection.doc(model.installmentId).delete();
  }

  setCompleteInstallment(InstallmentsModel model){
    completeInstallmentsCollection.doc(model.installmentId).set(model.toMap());
  }

  setNexInstallmentNum() async{
    int nextNum = await getNextInstallmentNum();
    Map<String, int> map = {'num': (nextNum +1)};
    nextInstallmentNumCollection.doc('num').set(map);
  }

  Future<int> getNextInstallmentNum() async{
    DocumentSnapshot documentSnapshot = await nextInstallmentNumCollection.doc('num').get();
    if (documentSnapshot.data() == null)
      return 1;

    Map<String, dynamic> map = documentSnapshot.data();
    int nextInstallmentNum = map['num'];

    int currentYear = await getCurrentYear();
    if(currentYear != DateTime.now().year){
      return 1;
    }
    return nextInstallmentNum;
  }

  setCurrentYear(){
    Map<String, int> map = {'year' : DateTime.now().year};
    currentYearCollection.doc('year').set(map);
  }

  Future getCurrentYear() async{
    DocumentSnapshot documentSnapshot = await currentYearCollection.doc('year').get();
    if (documentSnapshot.data() == null)
      return DateTime.now().year;

    Map<String, dynamic> map = documentSnapshot.data();
    int currentYear = map['year'];

    if(currentYear != DateTime.now().year){
      return DateTime.now().year;
    }

    return currentYear;
  }

  getCollectionOfSnapshot(String collectionName){
    Stream stream = FirebaseFirestore.instance.collection(collectionName).snapshots();
    return stream;
  }

  setEmployee(BuildContext context, String name, String phoneNum) async{
    await employeesCollection.doc(uid).set({
      'name': name,
      'phoneNum': phoneNum,
    });
  }

}