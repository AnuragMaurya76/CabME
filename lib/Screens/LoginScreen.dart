import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_app/Screens/HomeScreen.dart';
import 'package:uber_app/Screens/RegistrationScreen.dart';
import 'package:uber_app/Widgets/ProgressDialog.dart';
import 'package:uber_app/main.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailtextEditingController = TextEditingController();
  final TextEditingController passtextEditingController = TextEditingController();
  static final idScreen = "LoginScreen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 45.0),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image(
                  image: AssetImage("images/logo.png"),
                  height: 150,
                  width: 150,
                  alignment: Alignment.center,
                ),
              ),
              SizedBox(
                height: 1.0,
              ),
              Text(
                "Login as a Passenger",
                style: TextStyle(
                  fontFamily: "Brand Bold",
                  fontSize: 24,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 1,
                    ),
                    TextField(
                      controller: emailtextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email ID',
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    TextField(
                      controller: passtextEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        primary: Colors.yellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        if (!emailtextEditingController.text.contains('@') ||
                            !emailtextEditingController.text.contains('.com')) {
                          Fluttertoast.showToast(msg: 'Incorrect Email');
                        } else if (passtextEditingController.text.isEmpty) {
                          Fluttertoast.showToast(msg: 'Enter Password');
                        } else {
                          loginAndAuthenticate(context);
                        }
                      },
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontFamily: "Brand Bold",
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context,
                            RegistrationScreen.idScreen, (route) => false);
                      },
                      child: Text(
                        'Don\'t have an account? Sign Up Here',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<void> loginAndAuthenticate(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) =>
            ProgressDialog(message: 'Authenticating, Please wait...'));
    final User? user = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: emailtextEditingController.text,
                password: passtextEditingController.text)
            .catchError((onError) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Error: ' + onError.toString());
    }))
        .user;
    userRef.child(user!.uid).once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        Fluttertoast.showToast(msg: 'Login Successful');
        Navigator.pushNamedAndRemoveUntil(
            context, HomeScreen.idScreen, (route) => false);
      } else {
        Navigator.pop(context);
        _firebaseAuth.signOut();
        Fluttertoast.showToast(msg: 'No user found for this account');
      }
    });
  }
}