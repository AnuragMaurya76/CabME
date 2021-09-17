import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../configMap.dart';
import '../main.dart';

class CollectFareDialog extends StatelessWidget {
  final String paymentMethod;
  final int amount;
  CollectFareDialog({required this.amount, required this.paymentMethod});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        margin: EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 22,
            ),
            Text("Trip Fare"),
            SizedBox(
              height: 22,
            ),
            Divider(
              color: Colors.black,
            ),
            Text(
              "Rs. $amount",
              style: TextStyle(fontSize: 55, fontFamily: "Brand-Bold"),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Total trip amount charged to the Passenger",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'close');
                  userRef.child(currentOnlineUser.id).child('history').child(rideRequestReference.key).set(true);
                  
                    saveEarnings(amount);
                },
                child: Padding(
                    padding: EdgeInsets.all(17),
                    child: Row(
                      children: [
                        Text(
                          "Pay Cash",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Icon(
                          Icons.attach_money_outlined,
                          color: Colors.white,
                          size: 26,
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                  ),
                ),
              ),
            
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  void saveEarnings(int fareamount) {
    driverRef.child(firebaseUser.uid).child("earnings").once().then(
      (DataSnapshot dataSnapshot) {
        if (dataSnapshot.value != null) {
          int oldEarnings = int.parse(dataSnapshot.value.toString());
          int newEarnings = oldEarnings + fareamount;
          driverRef
              .child(firebaseUser.uid)
              .child("earnings")
              .set(newEarnings.toString());
        } else {
          driverRef
              .child(firebaseUser.uid)
              .child("earnings")
              .set(fareamount.toString());
        }
      },
    );
  }
}
