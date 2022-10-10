
import 'package:flutter/cupertino.dart';

class EndInstallmentMessageModel{
  final bool _displayed;
  final String _message;
  final IconData _icon;
  final Color _iconColor;
  final Color _backgroundColor;

  EndInstallmentMessageModel(
      this._displayed, this._message, this._icon, this._iconColor, this._backgroundColor);

  Color get backgroundColor => _backgroundColor;

  Color get iconColor => _iconColor;

  IconData get icon => _icon;

  String get message => _message;

  bool get displayed => _displayed;
}