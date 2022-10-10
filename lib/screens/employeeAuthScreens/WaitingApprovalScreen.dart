
import 'package:ali_mobile_store/repository/userAuthRepository/userAuthRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class WaitingApprovalScreen extends StatefulWidget {


  @override
  State<WaitingApprovalScreen> createState() => _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends State<WaitingApprovalScreen> {
AppLocalizations al;

UserAuthRepository _userAuthRepository;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userAuthRepository = UserAuthRepository();
  }

  @override
  Widget build(BuildContext context) {
    al = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Text(
            al.waitingForYouToBeAccepted
          ),
        ),
      )
    );
  }
}
