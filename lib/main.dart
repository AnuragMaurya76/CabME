import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_app/DataHandler/AppData.dart';
import 'package:uber_app/Screens/HomeScreen.dart';
import 'package:uber_app/Screens/LoginScreen.dart';
import 'Screens/RegistrationScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference userRef =
    FirebaseDatabase.instance.reference().child('Users');
DatabaseReference driverRef =
    FirebaseDatabase.instance.reference().child('Drivers');
DatabaseReference rideRequestReference =
        FirebaseDatabase.instance.reference().child("Ride Request");
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'CabME',
        theme: ThemeData(
          fontFamily: "Brand-Regular",
          primarySwatch: Colors.blue,
        ),
        
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? LoginScreen.idScreen
            : HomeScreen.idScreen,
        routes: {
          RegistrationScreen.idScreen: (context) => RegistrationScreen(),
          
          HomeScreen.idScreen: (context) => HomeScreen(),
          LoginScreen.idScreen: (context) => LoginScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
