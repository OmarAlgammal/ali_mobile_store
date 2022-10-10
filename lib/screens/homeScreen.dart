import 'package:ali_mobile_store/dataBase/installmentsDatabase.dart';
import 'package:ali_mobile_store/screens/bottomNavigationScreens/ProductsAndSalesScreen.dart';
import 'package:ali_mobile_store/screens/bottomNavigationScreens/completeInstallments.dart';
import 'package:ali_mobile_store/screens/bottomNavigationScreens/installmentsListScreen.dart';
import 'package:ali_mobile_store/screens/bottomNavigationScreens/storeManagmentScreen.dart';
import 'package:ali_mobile_store/screens/bottomNavigationScreens/todayInstallmentsScreen.dart';
import 'package:flutter/material.dart';
import '../constants.dart'; // important

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _currentIndex = 0;
  var tabs;
  InstallmentsDatabase database = InstallmentsDatabase();
  TodayInstallmentsScreen _todayInstallments;
  InstallmentsListScreen _installmentsList;
  CompleteInstallmentsScreen _completeInstallments;
  ProductsAndSales _productsAndSales;
  StoreManagementScreen _storeManagement;

  @override
  void initState() {
    super.initState();
    _todayInstallments = TodayInstallmentsScreen();
    _installmentsList = InstallmentsListScreen();
    _completeInstallments = CompleteInstallmentsScreen();
    _productsAndSales = ProductsAndSales();
    _storeManagement = StoreManagementScreen();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _todayInstallments,
          _installmentsList,
          _completeInstallments,
          _productsAndSales,
          _storeManagement
        ],
      ),
      bottomNavigationBar: bottomNavigation(),
    );
  }

  bottomNavigation() {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: darkGreenColor,
      unselectedItemColor: lightGreenColor,
      backgroundColor: offWhiteColor,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: onButtonNavSelected,
      items: [
        BottomNavigationBarItem(
          label: '',
          icon: Icon(todayIcon),
        ),
        BottomNavigationBarItem(
          label: '',
          icon: Icon(listIcon),
        ),
        BottomNavigationBarItem(
          label: '',
          icon: Icon(completeIcon),
        ),
        BottomNavigationBarItem(
          label: '',
          icon: Icon(productsAndSalesIcon),
        ),
        BottomNavigationBarItem(
          label: '',
          icon: Icon(storeIcon),
        ),
      ],
    );
  }

  onButtonNavSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
