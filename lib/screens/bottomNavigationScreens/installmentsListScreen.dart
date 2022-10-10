import 'dart:async';
import 'dart:io';
import 'package:ali_mobile_store/bloc/installmentsBloc/installments_bloc.dart';
import 'package:ali_mobile_store/bloc/installmentsBloc/installments_event.dart';
import 'package:ali_mobile_store/bloc/installmentsBloc/installments_state.dart';
import 'package:ali_mobile_store/screens/clientPageScreen.dart';
import 'package:ali_mobile_store/collection.dart';
import 'package:ali_mobile_store/dataBase/installmentDataModel.dart';
import 'package:ali_mobile_store/firebase_services.dart';
import 'package:ali_mobile_store/repository/firebaseInstallmentsRepository/firebase_installments_repository.dart';
import 'package:ali_mobile_store/theme.dart';
import 'package:ali_mobile_store/widgets/InstallmentsListWidget.dart';
import 'package:ali_mobile_store/widgets/sharedLoadingWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // important

// ignore: must_be_immutable
class InstallmentsListScreen extends StatefulWidget {
  @override
  _InstallmentsListScreenState createState() => _InstallmentsListScreenState();
}

class _InstallmentsListScreenState extends State<InstallmentsListScreen> {
  FireStoreServices _fireStoreServices = FireStoreServices();
  Collection collection;

  List<InstallmentsModel> allInstallments = [];
  List<InstallmentsModel> filteredInstallments = [];

  var firebaseReference;
  static var al;
  bool localizationState;
  bool isSearching = false;
  //String _searchText = '';
  TextEditingController textSearchController = TextEditingController();
  int firebaseCustomIndex = 0;
  String _fireStoreCollectionName = 'clients';
  Stream _stream;

  @override
  void initState() {
    super.initState();
    _stream = _fireStoreServices.getCollectionOfSnapshot(_fireStoreCollectionName);
  }

  @override
  Widget build(BuildContext context) {
    collection = Collection(context);
    al = AppLocalizations.of(context);
    localizationState = (al.localeName == 'ar') ? true : false;
    return DefaultTabController(
      length: 1,
      child: BlocProvider(
        create: (context) => InstallmentsBloc(firebaseInstallmentsRepository: FirebaseInstallmentsRepository())
          ..add(LoadInstallments()),
        child: Scaffold(
            backgroundColor: offWhiteColor,
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  (isSearching) ? sliverSearchAppBar() : sliverAppBar(),
                  sliverListWidgetWithBloc()
                  //sliverListWidget(),
                ],
              ),
            ),
            floatingActionButton: floatButton(),
            floatingActionButtonLocation: (al.localeName == 'ar')
                ? FloatingActionButtonLocation.miniEndFloat
                : FloatingActionButtonLocation.miniStartFloat),
      ),
    );
  }

  sliverListWidgetWithBloc() {
    return SliverList(
      delegate: SliverChildListDelegate([
        BlocBuilder<InstallmentsBloc, InstallmentsState>(
            builder: (context, state){
              if (state is InstallmentsLoaded)
                allInstallments = state.allInstallments;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  reverse: true,
                  itemCount: (isSearching)? filteredInstallments.length : allInstallments.length,
                    itemBuilder: (context, index){

                    if (isSearching)
                      return itemDesign(filteredInstallments[index], index);

                  return itemDesign(allInstallments[index], index);
                });

            }
        ),
      ]),
    );
  }

  List<InstallmentsModel> filteredList(String searchText){
    filteredInstallments = allInstallments.where((element) {
      return element.clientName.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return filteredInstallments;
  }

  sliverAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      stretch: true,
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
            al.installmentsList,
          ),
        ),
      ),
      actions: [
// search icon
        IconButton(
          onPressed: () {
            setState(() {
              isSearching = true;
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
// installment state text
                SizedBox(
                  width: installmentStateWidthDimen,
                  child: Center(
                    child: Text(
                      al.state,
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
              isSearching = false;
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
              onChanged: (_searchText) {
                setState(() {
                  print('_search text is${_searchText}and it is ${_searchText!=null}and filtered list length is ${filteredInstallments.length}');
                  filteredList(_searchText);
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
              textSearchController.clear();
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
// installment state text
                SizedBox(
                  width: installmentStateWidthDimen,
                  child: Center(
                    child: Text(
                      al.state,
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

  determineInstallmentDate(InstallmentsModel model) {
    int getIndex = collection.determineIndexForInstallmentShouldPaid(model);
    return model.installmentsDates[getIndex];
  }

  determineInstallmentPrice(InstallmentsModel model) {
    int getIndex = collection.determineIndexForInstallmentShouldPaid(model);
    return model.finalPaidMonthly[getIndex];
  }

  itemDesign(InstallmentsModel model, int index) {
    int monthIndex = collection.determineIndexForInstallmentShouldPaid(model);
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ClientPageScreen(
                      installmentId: model.installmentId,
                  installmentNum: model.installmentNum,
                  fireStoreCollectionName: _fireStoreCollectionName,
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                constraints:
                                    BoxConstraints(minWidth: 12, maxHeight: 24),
// client number
                                child: Center(
                                  child: Text(
                                    collection
                                        .convertNumbers(index + 1)
                                        .toString(),
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
// client name
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                        ),
                      ],
                    ),
                  ),
                ),
// installment state
                Container(
                  width: installmentStateWidthDimen,
                  height: installmentStateHeightDimen,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                    border: Border.all(
                      color: collection
                          .determineInstallmentState(model)
                          .borderColor,
                    ),
                    color:
                        collection.determineInstallmentState(model).fillColor,
                  ),
                  child: Center(
                    child: Text(
                      collection.determineInstallmentState(model).state,
                      style: TextStyle(
                          color: collection
                              .determineInstallmentState(model)
                              .borderColor,
                          fontSize: 14),
                    ),
                  ),
                ),

                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: installmentDateTimeWidthDimen),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
// date text
                      Text(
                        collection.dateFormat(determineInstallmentDate(model)),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
// paid monthly text
                          Text(
                            collection.convertNumbers(model.paidMonthlyDeal[monthIndex]).toString(),
                            style: boldPaidMonthlyTheme(collection, model, monthIndex),
                          ),
                          SizedBox(
                            width: 4,
                          ),
// final paid monthly
                          Visibility(
                            visible: collection.determineFinalPaidVisibility(model, monthIndex),
                            child: Text(
                              collection.convertNumbers(
                                  model.finalPaidMonthly[monthIndex]).toString(),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
// pound word
                          Text(
                            al.pound,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  floatButton() {
    return FloatingActionButton(
      backgroundColor: darkGreenColor,
      child: Icon(
        addIcon,
        color: offWhiteColor,
        size: addIconDimen,
      ),
      onPressed: () {
        Navigator.pushNamed(context, 'installmentDataScreen');
      },
    );
  }


}
