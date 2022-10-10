
import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:ali_mobile_store/theme.dart';
import 'package:ali_mobile_store/widgets/InstallmentsListWidget.dart';
import 'package:ali_mobile_store/widgets/sharedLoadingWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../clientPageScreen.dart';
import '../../collection.dart';
import '../../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../firebase_services.dart'; // important


class CompleteInstallmentsScreen extends StatefulWidget {
  const CompleteInstallmentsScreen({Key key}) : super(key: key);

  @override
  _CompleteInstallmentsScreenState createState() => _CompleteInstallmentsScreenState();
}

class _CompleteInstallmentsScreenState extends State<CompleteInstallmentsScreen> {

  final String _completedInstallmentsCol = 'completedInstallments';
  FireStoreServices _fireStoreServices = FireStoreServices();
  bool searchAppBarVisible = false;
  AppLocalizations al;
  bool localizationState;
  List<InstallmentsModel> allInstallmentsList = [];
  Collection collection;
  int firebaseCustomIndex = 0;
  String searchText = '';
  TextEditingController textSearchController = TextEditingController();
  Stream _stream;
  String _collectionName = 'completeInstallments';

  @override
  void initState() {
    super.initState();
    _stream = _fireStoreServices.getCollectionOfSnapshot(_collectionName);
  }

  @override
  Widget build(BuildContext context) {
    collection = Collection(context);
    al = AppLocalizations.of(context);
    localizationState = (al.localeName == 'ar') ? true : false;
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: offWhiteColor,
        body: CustomScrollView(
          slivers: [
            (searchAppBarVisible) ? sliverSearchAppBar() : sliverAppBar(),
            sliverListWidget(),
          ],
        ),
      ),
    );
  }

  streamBuilderWidget(){
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if (snapshot.hasError) return Center(child: Text('something went wrong'));
        if (snapshot.connectionState == ConnectionState.waiting)
          return sharedLoadingWidget(al.loading);
        if (snapshot.data.docs.length == 0)
          return Center(child: ListIsEmptyWidget(al.thereIsNoCompleteInstallments));

        int i = -1;

        return ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          reverse: true,
          padding: EdgeInsets.zero,
          children: snapshot.data.docs.map<Widget>((DocumentSnapshot document) {
            Map<String, dynamic> map = document.data() as Map<String, dynamic>;
            InstallmentsModel model = InstallmentsModel.toObject(map);

            if (searchAppBarVisible){
              if (model.clientName.toLowerCase().contains(searchText.toLowerCase()))
                return itemDesign(model, ++i);

              return Container();

            }

            return itemDesign(model, ++i);
          }).toList(),
        );
      },
    );
  }

  sliverListWidget() {
    return SliverList(
      delegate: SliverChildListDelegate(
          [
            streamBuilderWidget(),
          ]
      ),

    );
  }

  sliverAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      floating: true,
      backgroundColor: offWhiteColor,
      toolbarHeight: barDimen,
      title: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: darkGreenColor),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            al.completeInstallments,

          ),
        ),
      ),
      actions: [
// search icon
        IconButton(
          onPressed: () {
            setState(() {
              searchAppBarVisible = true;
            });
          },
          icon: Icon(
            searchIcon,
            color: darkGreenColor,
            size: 28,
          ),
        ),
      ],
      bottom: TabBar(
        labelPadding: EdgeInsets.zero,
        indicatorColor: transparentColor,
        tabs: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                ),
// clients
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      al.clients,
                    ),
                  ),
                ),
// installment date and time
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: installmentDateTimeWidthDimen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        al.da,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  sliverSearchAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: offWhiteColor,
      toolbarHeight: barDimen,
      actions: [
        // arrow back icon
        IconButton(
          onPressed: () {
            setState(() {
              searchAppBarVisible = false;
            });
          },
          icon: Icon(
            rightArrowIcon,
            color: darkGreenColor,
          ),
        ),
// search text form field
        Expanded(
          flex: 1,
          child: Visibility(
            visible: true,
            child: TextFormField(
              controller: textSearchController,
              autofocus: true,
              onChanged: (q) {
                setState(() {
                  searchText = q;
                });
              },
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightGreenColor)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: darkGreenColor),
                ),
              ),
            ),
          ),
        ),
// close icon
        IconButton(
          onPressed: () {
            setState(() {
              searchText = '';
              textSearchController.text = searchText;
            });
          },
          icon: Icon(
            closeIcon,
            color: darkGreenColor,
          ),
        ),
      ],
        bottom: TabBar(
          labelPadding: EdgeInsets.zero,
          indicatorColor: transparentColor,
          tabs: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
// clients
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Text(
                        al.clients,
                      ),
                    ),
                  ),
// installment date and time
                  SizedBox(
                    width: installmentDateTimeWidthDimen,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          al.da,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
    );
  }

  itemDesign(InstallmentsModel model, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ClientPageScreen(
                        installmentId: model.installmentId,
                        installmentNum: model.installmentNum,
                        fireStoreCollectionName: _completedInstallmentsCol,
                      )));
            },
            child: Container(
              height: installmentItemHeightDimen,
              decoration: BoxDecoration(
                color: lightGreenColor,
                borderRadius: BorderRadius.all(Radius.circular(fourDimen)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Expanded(
                        flex: 1,
                        child: Row(
// installment number
                          children: [
                            // installment number
                            Container(
                              decoration: BoxDecoration(
                                color: darkGreenColor,
                                borderRadius: BorderRadius.all(Radius.circular(2)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 4,
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minWidth: 12,
                                      maxHeight: 24
                                    ),
                                    child: Center(
                                      child: Text(
                                        collection.convertNumbers(index + 1).toString(),
                                        style: numTheme(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                ],
                              ),
                            ),
// brand and phone name
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    collection
                                        .convertNumbers(model.clientName)
                                        .toString(),
                                    style: Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              '${model.brandName} ${model.phoneName}',
                              style: Theme.of(context).textTheme.bodyText1,
                            )

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 4,
          ),
        ],
      ),
    );
  }

}
