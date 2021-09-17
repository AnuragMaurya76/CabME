import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../configMap.dart';
import '../main.dart';

class RatingScreen extends StatefulWidget {
  final String driverId;
  RatingScreen({required this.driverId});

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Dialog(
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
              Text(
                "Rate the Driver",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Brand-Bold',
                    color: Colors.black54),
              ),
              SizedBox(
                height: 22,
              ),
              Divider(
                color: Colors.black,
              ),
              RatingBar.builder(
                initialRating: rating,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.blueAccent,
                ),
                onRatingUpdate: (value) {
                  rating = value;
                  if (value <= 2) {
                    setState(() {
                      title = "Awful Experience";
                    });
                  } else if (value <= 3.5) {
                    setState(() {
                      title = "Neutral Experience";
                    });
                  } else if (value <= 5) {
                    setState(() {
                      title = "Awesome Experience";
                    });
                  }
                },
              ),
              SizedBox(
                height: 22,
              ),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Brand-Regular',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    if (rating == 0) {
                      Fluttertoast.showToast(msg: "Please Rate");
                    } else {
                      driverRef
                          .child(widget.driverId)
                          .child('ratings')
                          .once()
                          .then((value) {
                        if (value.value != null) {
                          double oldRating =
                              double.parse(value.value.toString());
                          double newRating = (oldRating + rating) / 2;
                          driverRef
                              .child(widget.driverId)
                              .child('ratings')
                              .set(newRating.toStringAsFixed(1));
                        } else {
                          driverRef
                              .child(widget.driverId)
                              .child('ratings')
                              .set(rating.toStringAsFixed(1));
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(17),
                    child: Row(
                      children: [
                        Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
