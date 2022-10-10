
class EmployeeModel{
  String _name;
  String _mobileNum;
  String _deviceId;
  bool _accepted;

  EmployeeModel(this._name, this._mobileNum, this._deviceId, this._accepted);

  EmployeeModel.toObject(Map<String, dynamic> map){
    this._name = map['name'];
    this._mobileNum = map['mobileNum'];
    this._deviceId = map['deviceId'];
    this._accepted = map['accepted'];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = Map<String, dynamic>();

    map['name'] = name;
    map['mobileNum'] = mobileNum;
    map['deviceId'] = deviceId;
    map['accepted'] = accepted;

    return map;
  }

  String get name => _name;

  String get mobileNum => _mobileNum;

  String get deviceId => _deviceId;

  bool get accepted => _accepted;
}