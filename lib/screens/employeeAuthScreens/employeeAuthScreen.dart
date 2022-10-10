import 'package:ali_mobile_store/bloc/userAuthBloc/userAuthBloc.dart';
import 'package:ali_mobile_store/bloc/userAuthBloc/userAuthEvent.dart';
import 'package:ali_mobile_store/bloc/userAuthBloc/userAuthState.dart';
import 'package:ali_mobile_store/collection.dart';
import 'package:ali_mobile_store/sharedWidgets/sharedLogo.dart';
import 'package:ali_mobile_store/sharedWidgets/sharedSnackBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants.dart';
import '../../../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // important


class EmployeeAuthScreen extends StatefulWidget {

  const EmployeeAuthScreen({Key key,}) : super(key: key);

  @override
  _EmployeeAuthScreenState createState() => _EmployeeAuthScreenState();
}

class _EmployeeAuthScreenState extends State<EmployeeAuthScreen> {
  Collection _collection;
  final _numFieldController = TextEditingController();
  AppLocalizations al;
  bool showCircularWidget = false;

  @override
  Widget build(BuildContext context) {

    al = AppLocalizations.of(context);
    _collection = Collection(context);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: ListView(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: sharedLogoWidget(context),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: registerFormWidget(),
                    )
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: registerAsEmployerButtonWidget(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }



  registerFormWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
// register as employee text
        Text(
          al.registerAsEmployee,
          style: TextStyle(
            color: darkGreenColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
              color: lightGreenColor,
              borderRadius: BorderRadius.all(Radius.circular(6))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
// send button
                BlocBuilder<UserAuthBloc, UserAuthState>(
                  builder: (context, state) {
                    if (state is InvalidEmployeePhoneNum){
                      showCircularWidget = false;
                      BlocProvider.of<UserAuthBloc>(context).add(InitialEmployeeAuthEvent());
                    }

                    return GestureDetector (
                      onTap:(){
                        if (!showCircularWidget){
                          if (determineValidityOfNumField()){
                            setState(() {
                              showCircularWidget = true;
                              BlocProvider.of<UserAuthBloc>(context).add(RegisterEmployee(context: context, phoneNum: _numFieldController.text));
                            });
                          }
                        }
                      },
                      child: (showCircularWidget)? circularProgressWidget() : submitButtonWidget(),
                    );
                  }
                ),
// text field for phone num
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextFormField(
                        controller: _numFieldController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10)
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: darkGreenColor),
                          hintText: '${al.enterThePhoneNum}',
                        )),
                  ),
                ),
// country code text
                Text(
                  _collection.convertNumbers('(20+)'),
                  style: TextStyle(fontWeight: FontWeight.bold, color: darkGreenColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  submitButtonWidget(){
    return Container(
      width: 48,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        color: darkGreenColor,
      ),
      child: Center(
        child: Text(
          al.submit,
          style: TextStyle(color: offWhiteColor, fontWeight: FontWeight.bold, ),
        ),
      ),
    );
  }

  circularProgressWidget(){
    return SizedBox(
      width: 48,
      height: 36,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: darkGreenColor,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  determineValidityOfNumField() {
    String numText = _numFieldController.text;
    if (numText.length < 10){
      sharedSnackBar(context, al.enterThePhoneNumCorrectly);
      return false;
    }
    else if (numText.length == 0){
      sharedSnackBar(context, al.youShouldEnterThePhoneNum);
      return false;
    }

    return true;
  }

  registerAsEmployerButtonWidget() {
    return SizedBox(
      height: MediaQuery.of(context).size.height /2.35,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: (){
              BlocProvider.of<UserAuthBloc>(context).add(InitialEmployerPasswordEvent());
            },
            child: Container(
              height: 48,
              width: (MediaQuery.of(context).size.width)/10 * 7,
              decoration: BoxDecoration(
                color: darkGreenColor,
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    al.registerAsEmployer,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: offWhiteColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}


