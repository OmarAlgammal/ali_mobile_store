
class InstallmentsModel {
  String _installmentId;
  int _installmentNum;
  String _clientName;
  int _clientNum;
  int _clientId;
  String _guarantorName;
  int _guarantorNum;
  int _guarantorId;
  String _brandName;
  String _phoneName;
  int _phonePrice;
  int _advancedAmount;
  int _installmentPeriod;
  int _restFromDeal;
  int _initialProfit;
  List<int> _paidMonthlyDeal = <int>[];
  DateTime _receivedDate;

  List<DateTime> _installmentsDates = <DateTime>[];
  List<int> _paymentRecord = <int>[];
  List<DateTime> _paymentRecordDates = <DateTime>[];
  List<int> _paidForEachInstallment = <int>[];
  List<DateTime> _paymentDates = <DateTime>[];
  List<int> _restFromInstallment = <int>[];
  List<int> _finalPaidMonthly = <int>[];
  List<bool> _completeInstallment = <bool>[];
  DateTime _adjustmentTime;
  List<bool> _lastInstallment;
  int _finalProfit;
  int _additionalProfit;
  int _loseFromProfit;
  int _loseFromOriginalPhonePrice;
  bool _finished;
  int _wasBiggestPriceToPayWhenFinished;

  InstallmentsModel(
      this._installmentId,
      this._installmentNum,
      this._clientName,
      this._clientNum,
      this._clientId,
      this._guarantorName,
      this._guarantorNum,
      this._guarantorId,
      this._brandName,
      this._phoneName,
      this._phonePrice,
      this._advancedAmount,
      this._installmentPeriod,
      this._restFromDeal,
      this._initialProfit,
      this._paidMonthlyDeal,
      this._receivedDate,

      this._installmentsDates,
      this._paymentRecord,//
      this._paymentRecordDates,//
      this._paidForEachInstallment,
      this._paymentDates,//
      this._restFromInstallment,// *
      this._finalPaidMonthly,//
      this._completeInstallment,
      this._adjustmentTime,
      this._lastInstallment,
      this._finalProfit,
      this._additionalProfit,
      this._loseFromProfit,
      this._loseFromOriginalPhonePrice,
      this._finished,
      this._wasBiggestPriceToPayWhenFinished
      );

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['installmentId'] = installmentId;
    map['installmentNum'] = installmentNum;
    map['clientName'] = clientName;
    map['clientNum'] = clientNum;
    map['clientId'] = clientId;
    map['guarantorName'] = guarantorName;
    map['guarantorNum'] = guarantorNum;
    map['guarantorId'] = guarantorId;
    map['brandName'] = brandName;
    map['phoneName'] = phoneName;
    map['phonePrice'] = phonePrice;
    map['advancedAmount'] = advancedAmount;
    map['installmentPeriod'] = installmentPeriod;
    map['restFromDeal'] = restFromDeal;
    map['initialProfit'] = initialProfit;
    map['paidMonthlyDeal'] = paidMonthlyDeal.toString();
    map['receivedDate'] = receivedDate.toString();
    map['installmentsDates'] = installmentsDates.toString();
    map['paymentRecord'] = paymentRecord.toString();
    map['paymentRecordDates'] = paymentRecordDates.toString();
    map['paidForEachInstallment'] = paidForEachInstallment.toString();
    map['paymentDates'] = paymentDates.toString();
    map['restFromInstallment'] = restFromInstallment.toString();
    map['finalPaidMonthly'] = finalPaidMonthly.toString();
    map['completeInstallment'] = completeInstallment.toString();
    map['adjustmentTime'] = adjustmentTime.toString();
    map['lastInstallment'] = lastInstallment.toString();
    map['finalProfit'] = finalProfit;
    map['additionalProfit'] = additionalProfit;
    map['loseFromProfit'] = loseFromProfit;
    map['loseFromOriginalPhonePrice'] = loseFromOriginalPhonePrice;
    map['finished'] = _finished.toString();
    map['wasBiggestPriceToPayWhenFinished'] = wasBiggestPriceToPayWhenFinished;
    return map;
  }

  InstallmentsModel.toObject(Map<String, dynamic> map) {
    this._installmentId = map['installmentId'];
    this._installmentNum = map['installmentNum'];
    this._clientName = map['clientName'];
    this._clientNum = map['clientNum'];
    this._clientId = map['clientId'];
    this._guarantorName = map['guarantorName'];
    this._guarantorNum = map['guarantorNum'];
    this._guarantorId = map['guarantorId'];
    this._brandName = map['brandName'];
    this._phoneName = map['phoneName'];
    this._phonePrice = map['phonePrice'];
    this._advancedAmount = map['advancedAmount'];
    this._installmentPeriod = map['installmentPeriod'];
    this._restFromDeal = map['restFromDeal'];
    this._initialProfit = map['initialProfit'];
    this._paidMonthlyDeal = toListOfNum(map, 'paidMonthlyDeal');
    this._receivedDate = toDate(map, 'receivedDate');
    this._installmentsDates = toListOfDates(map, 'installmentsDates');
    this._paymentRecord = toListOfNum(map, 'paymentRecord');
    this._paymentRecordDates = toListOfDates(map, 'paymentRecordDates');
    this._paidForEachInstallment = toListOfNum(map, 'paidForEachInstallment');
    this._paymentDates = toListOfDates(map, 'paymentDates');
    this._restFromInstallment = toListOfNum(map, 'restFromInstallment');
    this._finalPaidMonthly = toListOfNum(map, 'finalPaidMonthly');
    this._completeInstallment = toListOfBoolean(map, 'completeInstallment');
    this._adjustmentTime =toDate(map, 'adjustmentTime');
    this._lastInstallment =toListOfBoolean(map, 'lastInstallment');
    this._finalProfit = map['finalProfit'];
    this._additionalProfit = map['additionalProfit'];
    this._loseFromProfit = map['loseFromProfit'];
    this._loseFromOriginalPhonePrice = map['loseFromOriginalPhonePrice'];
    this._finished = toBool(map, 'finished');
    this._wasBiggestPriceToPayWhenFinished = map['wasBiggestPriceToPayWhenFinished'];
  }

  bool toBool(Map<String, dynamic> map, String tableName){
    String boolToString = map[tableName].toString();
    if (boolToString.contains('t'))
      return true;
    return false;
  }

  List<int> toListOfNum(Map<String, dynamic> map, String tableName) {
    List<int> list = <int>[];
    //convert list to string
    String listToString = map[tableName].toString();
    //remove first and last symbol in string which is [,]
    listToString = listToString.substring(1, listToString.length - 1);
    //split listToString from ', ' to remove space after , symbol
    List<String> stringToList = listToString.split(', ');
    for (int i = 0; i < stringToList.length; i++) {
      //convert elements to int and add it to list
      try{
        list.add(int.parse(stringToList[i]));
      }catch(e){
        list.add(null);
      }
    }
    return list;
  }

  DateTime toDate(Map<String, dynamic> map, String tableName) {
    String dateToString = map[tableName].toString();
    DateTime dateTime = DateTime.parse(dateToString);
    return dateTime;
  }

  //this method for to fields in table
  //for installmentDates and paymentDates
  List<DateTime> toListOfDates(Map<String, dynamic> map, String tableName){
    List<DateTime> list = <DateTime>[];
    //convert list to string
    String listToString = map[tableName].toString();
    //remove first and last symbol in string which is [,]
    listToString = listToString.substring(1, listToString.length - 1);
    //split listToString from ', ' to remove space after , symbol
    List<String> stringToList = listToString.split(', ');
    for (int i = 0; i < stringToList.length; i++) {
      //convert elements to date and add it to list
      try{
        list.add(DateTime.parse(stringToList[i]));
      }catch(e){
        list.add(null);
      }
    }
    return list;
  }

  List<bool> toListOfBoolean(Map<String, dynamic> map, String tableName){
    List<bool> list = <bool>[];
    //convert list to string
    String listToString = map[tableName].toString();
    //remove first and last symbol in string which is [,]
    listToString = listToString.substring(1, listToString.length - 1);
    //split listToString from ', ' to remove space after , symbol
    List<String> stringToList = listToString.split(', ');
    for (int i = 0; i < stringToList.length; i++) {
      //check if the element number i contains of t = true or not
      if(stringToList[i].contains('t')){
        list.add(true);
      }else{
        list.add(false);
      }
    }
    return list;
  }

  String get installmentId => _installmentId;
  set installmentId(String id) {
    this.installmentId = id;
  }

  int get installmentNum => _installmentNum;
  set installmentNum(int id) {
    this.installmentNum = id;
  }

  String get clientName => _clientName;
  set clientName(String name) {
    this._clientName = name;
  }

  int get clientNum => _clientNum;
  set clientNum(int num) {
    this._clientNum = num;
  }

  int get clientId => _clientId;
  set clientId(int id) {
    this._clientId = id;
  }

  String get guarantorName => _guarantorName;
  set guarantorName(String name) {
    this._guarantorName = name;
  }

  int get guarantorNum => _guarantorNum;
  set guarantorNum(int num) {
    this._guarantorNum = num;
  }

  int get guarantorId => _guarantorId;
  set guarantorId(int id) {
    this._guarantorId = id;
  }

  String get brandName => _brandName;
  set brandName(String brandName) {
    this._brandName = brandName;
  }

  String get phoneName => _phoneName;
  set phoneName(String name) {
    this._phoneName = name;
  }

  int get phonePrice => _phonePrice;
  set phonePrice(int num) {
    this._phonePrice = num;
  }

  int get advancedAmount => _advancedAmount;
  set advancedAmount(int num) {
    this._advancedAmount = num;
  }

  int get installmentPeriod => _installmentPeriod;
  set installmentPeriod(int num) {
    this._installmentPeriod = num;
  }

  int get restFromDeal => _restFromDeal;
  set restFromDeal(int num) {
    this._restFromDeal = num;
  }

  int get initialProfit => _initialProfit;
  set initialProfit(int num) {
    this._initialProfit = num;
  }

  List<int> get paidMonthlyDeal => _paidMonthlyDeal;
  set paidMonthlyDeal(List<int> list) {
    this._paidMonthlyDeal = list;
  }

  DateTime get receivedDate => _receivedDate;
  set receivedDate(DateTime date) {
    this._receivedDate = date;
  }

  List<DateTime> get installmentsDates => _installmentsDates;
  set installmentsDates(List<DateTime> date) {
    this._installmentsDates = date;
  }

  List<DateTime> get paymentDates => _paymentDates;
  set paymentDates(List<DateTime> date) {
    this._paymentDates = date;
  }

  List<int> get finalPaidMonthly => _finalPaidMonthly;
  set finalPaidMonthly(List<int> price) {
    this._finalPaidMonthly = price;
  }

  List<int> get paymentRecord => _paymentRecord;
  set paymentRecord(List<int> price) {
    this._paymentRecord = price;
  }

  List<DateTime> get paymentRecordDates => _paymentRecordDates;
  set paymentRecordDates(List<DateTime> date) {
    this._paymentRecordDates = date;
  }

  List<int> get paidForEachInstallment => _paidForEachInstallment;
  set paidForEachInstallment(List<int> price) {
    this._paidForEachInstallment = price;
  }

  List<int> get restFromInstallment => _restFromInstallment;
  set restFromInstallment(List<int> price) {
    this._restFromInstallment = price;
  }

  List<bool> get completeInstallment => _completeInstallment;
  set completeInstallment(List<bool> state) {
    this._completeInstallment = state;
  }

  List<bool> get lastInstallment => _lastInstallment;
  set lastInstallment(List<bool> list) {
    this._lastInstallment = list;
  }

  int get finalProfit => _finalProfit;
  set finalProfit(int num) {
    this._finalProfit = num;
  }

  int get additionalProfit => _additionalProfit;
  set additionalProfit(int num) {
    this._additionalProfit = num;
  }

  int get loseFromProfit => _loseFromProfit;
  set loseFromProfit(int num) {
    this._loseFromProfit = num;
  }

  int get loseFromOriginalPhonePrice => _loseFromOriginalPhonePrice;
  set loseFromOriginalPhonePrice(int num) {
    this._loseFromOriginalPhonePrice = num;
  }

  DateTime get adjustmentTime => _adjustmentTime;
  set adjustmentTime(DateTime time){
    this._adjustmentTime = time;
  }

  bool get finished => _finished;
  set finished(bool state){
    this._finished = state;
  }

  int get wasBiggestPriceToPayWhenFinished => _wasBiggestPriceToPayWhenFinished;
  set wasBiggestPriceToPayWhenFinished(int num) {
    this._wasBiggestPriceToPayWhenFinished = num;
  }
}
