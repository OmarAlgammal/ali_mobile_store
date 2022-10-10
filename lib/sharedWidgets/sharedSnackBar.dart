
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

sharedSnackBar(BuildContext context, content){
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: darkRedColor,
        content: Text(content),
      )
  );
}