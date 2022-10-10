import 'dart:io';
import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class InstallmentsDatabase {
  static InstallmentsDatabase instance;
  static Database _database;

  String tableName = 'installmentsTable';
  String idCol = 'id';
  String installmentIdCol = 'installmentId';
  String clientNameCol = 'clientName';
  String clientNumCol = 'clientNum';
  String clientIdCol = 'clientId';
  String guarantorNameCol = 'guarantorName';
  String guarantorNumCol = 'guarantorNum';
  String guarantorIdCol = 'guarantorId';
  String brandNameCol = "brandName";
  String phoneNameCol = "phoneName";
  String phonePriceCol = "phonePrice";
  String advancedAmountCol = "advancedAmount";
  String installmentPeriodCol = "installmentPeriod";
  String restFromDealCol = "restFromDeal";
  String initialProfitCol = "initialProfit";
  String paidMonthlyDealCol = "paidMonthlyDeal";
  String receivedDateCol = "receivedDate";
  String installmentsDatesCol = "installmentsDates";
  String paymentRecordCol = "paymentRecord";
  String paymentRecordDatesCol = "paymentRecordDates";
  String paidForEachInstallmentCol = "paidForEachInstallment";
  String paymentDatesCol = "paymentDates";
  String restFromInstallmentCol = "restFromInstallment";
  String finalPaidMonthlyCol = "finalPaidMonthly";
  String completeInstallmentCol = "completeInstallment";
  String adjustmentTimeCol = "adjustmentTime";
  String lastInstallmentCol = "lastInstallment";
  String finalProfitCol = "finalProfit";

  InstallmentsDatabase.newInstance();

  factory InstallmentsDatabase() {
    if (instance == null) instance = InstallmentsDatabase.newInstance();
    return instance;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "installments.db";
    var result = await openDatabase(path, version: 1, onCreate: createDatabase);
    return result;
  }

  createDatabase(Database db, int version) async {
    await db.execute('CREATE TABLE $tableName ($idCol INTEGER PRIMARY KEY , $installmentIdCol INTEGER ,'
        '$clientNameCol TEXT, $clientNumCol INTEGER, $clientIdCol INTEGER,'
        '$guarantorNameCol TEXT, $guarantorNumCol INTEGER, $guarantorIdCol INTEGER ,'
        '$brandNameCol TEXT, $phoneNameCol TEXT, '
        '$phonePriceCol INTEGER, $advancedAmountCol INTEGER, $installmentPeriodCol INTEGER, '
        '$restFromDealCol INTEGER, $initialProfitCol INTEGER, $paidMonthlyDealCol TEXT, $receivedDateCol TEXT,'
        '$installmentsDatesCol TEXT, $paymentRecordCol TEXT, $paymentRecordDatesCol TEXT,'
        '$paidForEachInstallmentCol TEXT, $paymentDatesCol TEXT, $restFromInstallmentCol TEXT, $finalPaidMonthlyCol TEXT,'
        '$completeInstallmentCol TEXT, $adjustmentTimeCol TEXT, $lastInstallmentCol TEXT, $finalProfitCol INTEGER)');
  }

  Future<int> insertInstallment(InstallmentsModel model) async {
    Database db = await database;
    var i = db.insert(tableName, model.toMap());
    return i;
  }

  Future<InstallmentsModel> getInstallmentById(int id) async {
    Database db = await database;
    //get list of map
    var result = await db.query(tableName, where: '$idCol = "$id"');
    InstallmentsModel model = (InstallmentsModel.toObject(result[0]));
    return model;
  }

  Future<List<Map<String, dynamic>>> getMapList() async {
    Database db = await database;
    //get list of map
    var result = await db.query(tableName);
    return result;
  }

  Future<List<InstallmentsModel>> getInstallmentsList() async {
    //get list of map
    var result = await getMapList();
    int count = result.length;
    List<InstallmentsModel> list = <InstallmentsModel>[];
    for (int i = 0; i < count; i++) {
      //convert map to object and add it to list of InstallmentsModel
      list.add(InstallmentsModel.toObject(result[i]));
    }
    return list;
  }

  Future<void> updateInstallment(InstallmentsModel model) async {
    Database db = await database;
    await db.update(tableName, model.toMap(), where: '$idCol = ${model.installmentId}');
  }

  Future<void> deleteInstallment(InstallmentsModel model) async{
    Database db = await database;
    await db.delete(tableName, where: '$idCol = ?' ,whereArgs: [model.installmentId]);
  }
}
