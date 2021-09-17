import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_app/Assistants/MethodAssistant.dart';
import 'package:uber_app/DataHandler/AppData.dart';
import 'package:uber_app/Screens/LoginScreen.dart';
import 'package:uber_app/Widgets/HistoryItem.dart';
import 'package:uber_app/Widgets/ShowAboutDialog.dart';

class HistoryTabPage extends StatefulWidget {
  @override
  _HistoryTabPageState createState() => _HistoryTabPageState();
}

class _HistoryTabPageState extends State<HistoryTabPage> {
  @override
  void initState() {
    Provider.of<AppData>(context, listen: false).tripHistoryData.clear();
    Provider.of<AppData>(context, listen: false).tripHistoryKeys.clear();
    MethodAssistant.retrieveHistoryInfo(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Refreshing..."),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.black87,
                  ));

                  Provider.of<AppData>(context, listen: false)
                      .tripHistoryData
                      .clear();
                  // Provider.of<AppData>(context, listen: false)
                  //     .tripHistoryKeys
                  //     .clear();
                  MethodAssistant.retrieveHistoryInfo(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_outlined,
                      size: 26.0,
                    ),
                  ],
                ),
              )),
        ],
      ),
      drawer: Container(
        width: 280,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset(
                        "images/user_icon.png",
                        height: 65,
                        width: 65,
                      ),
                      SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Profile Name:',
                            style: TextStyle(
                                fontSize: 16.0, fontFamily: 'Brand-Bold'),
                          ),
                          SizedBox(height: 6.0),
                          Text('Visit Profile'),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.0),
              //Drawer Body controller
              ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  'History',
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.person_outlined,
                ),
                title: Text(
                  'Profile',
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (BuildContext context) => ShowAboutDialog());
                },
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text(
                    'About',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.idScreen, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          padding: EdgeInsets.all(0),
          itemBuilder: (context, index) {
            return HistoryItem(
                history: Provider.of<AppData>(context, listen: false)
                    .tripHistoryData[index]);
          },
          separatorBuilder: (context, index) => Divider(
            color: Colors.black,
          ),
          itemCount: Provider.of<AppData>(context).tripHistoryData.length,
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
        ),
      ),
    );
  }
}
