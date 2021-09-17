import 'package:uber_app/TabPages/HistoryTabPage.dart';
import 'package:uber_app/TabPages/ProfileTabPage.dart';
import 'package:uber_app/TabPages/HomeTabPage.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static final idScreen = "HomeScreen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int selectedIndex = 0;
  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
      tabController.index = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
    index: selectedIndex,
    children: <Widget> [
       HomeTabPage(), 
       HistoryTabPage(), 
       ProfileTabPage(),
     ],
  ),
          
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemSelected,
      ),
    );
  }
}