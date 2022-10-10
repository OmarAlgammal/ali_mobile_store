
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // important

// ignore: must_be_immutable
class NoInstallmentsInDayWidget extends StatelessWidget {
  final int numOfShow;
  AppLocalizations al;

  NoInstallmentsInDayWidget(this.numOfShow);

  @override
  Widget build(BuildContext context) {
    al = AppLocalizations.of(context);
    return Container(
      color: offWhiteColor,
      // divide on 1.3 to make this widget in center of display
      height: MediaQuery.of(context).size.height/1.4,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Container(
                height: barDimen,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(fourDimen)),
                    color: offWhiteColor),
                child: Row(
                  children: [
                    getDistance(0, 8),
//checkbox
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        height: 18,
                        width: 18,
                        color: darkGreenColor,
                      ),
                    ),
                    getDistance(0, 8),

//client name
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0, left: 4),
                          child: Text('____________'),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(right: 4, left: 4),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
//installment price
                                  Text('____'),
                                  getDistance(0, 8),

// pound word
                                  Text('_____'),
                                ],
                              ),
                            ],
                          ),
//installment date
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('_______'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            getDistance(8, 0),
            Text(getNameOfTheTime(),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkGreenColor),)

          ],
        ),
      ),
    );
  }

  getNameOfTheTime(){
    if (numOfShow == 0)
      return al.noInstallmentsToday;
    else if (numOfShow == 1)
      return al.noInstallmentsTomorrow;
    else if (numOfShow == 2)
      return al.noMissedInstallments;

    return al.noInstallmentsInThisDate;
  }


  getDistance(double height, double width){
    return SizedBox(
      height: height,
      width: width,
    );
  }
}
