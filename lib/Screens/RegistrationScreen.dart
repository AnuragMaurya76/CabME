import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_app/Widgets/ProgressDialog.dart';
import 'package:uber_app/main.dart';

import 'HomeScreen.dart';
import 'LoginScreen.dart';

class RegistrationScreen extends StatelessWidget {
  static final idScreen = "RegistrationScreen";
  final TextEditingController nameTextEditingController = new TextEditingController();
  final TextEditingController emailTextEditingController =
      new TextEditingController();
  final TextEditingController passTextEditingController = new TextEditingController();
  final TextEditingController phoneTextEditingController =
      new TextEditingController();
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
              
              SizedBox(height: 1.0),
              
              Text(
                "Register as a Passenger",
                style: TextStyle(
                  fontFamily: "Brand Bold",
                  fontSize: 24,
                ),
              ),
              
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 1),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email ID',
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 1),
                    TextField(
                      controller: nameTextEditingController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    SizedBox(height: 1),
                    TextField(
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 1),
                    TextField(
                      controller: passTextEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(fontSize: 14),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: TextStyle(fontSize: 14),
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
                        if (!emailTextEditingController.text.contains('@') ||
                            !emailTextEditingController.text.contains('.com')) {
                          Fluttertoast.showToast(msg: 'Incorrect Email');
                        } else if (nameTextEditingController.text.length < 5) {
                          Fluttertoast.showToast(
                              msg:
                                  'Username should be minimun 5 characters long');
                        } else if (phoneTextEditingController.text.isEmpty) {
                          Fluttertoast.showToast(msg: 'Enter phone number');
                        } else if (passTextEditingController.text.length < 6) {
                          Fluttertoast.showToast(
                              msg:
                                  'Password should be minimum 6 characters long');
                        } else {
                          registerUser(context);
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
                        Navigator.pushNamedAndRemoveUntil(
                            context, LoginScreen.idScreen, (route) => false);
                      },
                      child: Text(
                        'Already have an account? Sign in Here',
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
  void registerUser(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) =>
            ProgressDialog(message: 'Registering, Please wait...'));
    try {
      final User? user = (await _firebaseAuth
              .createUserWithEmailAndPassword(
                  email: emailTextEditingController.text,
                  password: passTextEditingController.text)
              .catchError((onError) {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'Error:' + onError.toString());
      }))
          .user;

      Map mapMyData = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };
      userRef.child(user!.uid).set(mapMyData);
      Fluttertoast.showToast(msg: "User Created Sucessfully");
      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreen.idScreen, (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: 'The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}
