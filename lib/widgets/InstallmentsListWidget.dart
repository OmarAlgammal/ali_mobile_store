import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

// ignore: must_be_immutable
class ListIsEmptyWidget extends StatelessWidget {
  String _state;

  ListIsEmptyWidget(this._state);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height / 1.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          itemStyle(context),
          SizedBox(
            height: 8,
          ),
          Text(
            _state,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  listViewWidget() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 3,
      itemBuilder: (context, index) {
        return itemStyle(context);
      },
    );
  }

  itemStyle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4, right: 24, left: 24),
      child: Container(
        height: barDimen,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(fourDimen)),
            color: offWhiteColor),
        child: Row(
          children: [
            SizedBox(
              width: 8,
            ),
//checkbox
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                height: 18,
                width: 18,
                color: darkGreenColor,
              ),
            ),
            SizedBox(
              width: 8,
            ),

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
                          SizedBox(
                            width: 8,
                          ),

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
    );
  }
}
