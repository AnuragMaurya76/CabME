import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:uber_app/Screens/LoginScreen.dart';
import 'package:uber_app/main.dart';

import '../configMap.dart';

class ProfileTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3366FF),
            Color(0xFF00CCFF),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentOnlineUser.name,
              style: TextStyle(
                fontSize: 65,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Brand-Bold',
              ),
            ),
            Text(
              "Passenger",
              style: TextStyle(
                fontSize: 20,
                color: Colors.blueGrey[200],
                letterSpacing: 2.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'Brand-Regular',
              ),
            ),
            SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            InfoCard(
                icon: Icons.phone,
                onpressed: () {},
                text: currentOnlineUser.phone),
            InfoCard(
                icon: Icons.email_outlined,
                onpressed: () {},
                text: currentOnlineUser.email),
            SizedBox(
              height: 50,
            ),
            GestureDetector(
              onTap: () {
                Geofire.removeLocation(firebaseUser.uid);
                rideRequestReference.onDisconnect();
                userRef.onDisconnect();
                driverRef.onDisconnect();
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.idScreen, (route) => false);
              },
              child: Card(
                color: Colors.black,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 115),
                child: ListTile(
                    trailing: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Sign Out',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: "Brand-Bold"),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function onpressed;
  InfoCard({required this.icon, required this.onpressed, required this.text});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpressed(),
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.black87,
          ),
          title: Text(
            text,
            style: TextStyle(
                color: Colors.black87, fontSize: 16, fontFamily: 'Brand-Bold'),
          ),
        ),
      ),
    );
  }
}
