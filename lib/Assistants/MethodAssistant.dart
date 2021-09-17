import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uber_app/Assistants/RequestAssistant.dart';
import 'package:uber_app/DataHandler/AppData.dart';
import 'package:uber_app/configMap.dart';
import 'package:uber_app/main.dart';
import 'package:uber_app/models/Address.dart';
import 'package:uber_app/models/AllUsers.dart';
import 'package:uber_app/models/History.dart';
import 'package:uber_app/models/TimeAndDistance.dart';
import 'package:http/http.dart' as http;

class MethodAssistant {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String url =
        "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?f=pjson&featureTypes=&location=${position.longitude},${position.latitude}";
    var response = await RequestAssistant.getRequest(url);
    if (response != 'Failed, No Response!!') {
      placeAddress = response["address"]["LongLabel"];
      Address userPickupAddress = new Address();
      userPickupAddress.longitude = position.longitude;
      userPickupAddress.latitude = position.latitude;
      userPickupAddress.placeName = placeAddress;
      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(userPickupAddress);
    }
    return placeAddress;
  }

  static Future<TimeAndDistance> calculateTimeAndDistance(
      LatLng initialPosition, LatLng finalPosition, context) async {
    String url =
        "https://router.project-osrm.org/route/v1/driving/${initialPosition.longitude},${initialPosition.latitude};${finalPosition.longitude},${finalPosition.latitude}?steps=true";
    Map<String, dynamic> response = await RequestAssistant.getRequest(url);
    TimeAndDistance timeAndDistance = TimeAndDistance(
        distance: double.parse(response["routes"][0]["distance"].toString()),
        duration: double.parse(response["routes"][0]["duration"].toString()));
    return timeAndDistance;
  }

  static int calculateFares(TimeAndDistance timeAndDistance) {
    double timeTraveledFare = (timeAndDistance.duration / 60);
    double distanceTravelFare = (timeAndDistance.distance / 1000) * 6;
    double totalFare = timeTraveledFare + distanceTravelFare;
    return totalFare.truncate();
  }

  static Future<void> getCurrentOnlineUserInfo(context) async {
    firebaseUser = FirebaseAuth.instance.currentUser!;
    String userId = firebaseUser.uid;
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("Users").child(userId);
    reference.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        currentOnlineUser = AllUsers.fromSnapShot(dataSnapshot);
      }
    });
  }

  static sendNotificationToDrivers(
      String token, context, String rideRequestId) async {
    Address destination =
        Provider.of<AppData>(context,listen: false).dropOffLocation;
    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverToken,
    };
    Map notificationMap = {
      'body': "Destination: ${destination.placeName}",
      'title': 'New Ride Request',
    };
    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "ride_request_id": rideRequestId,
    };
    Map sendNotificationMap = {
      'notification': notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to': token,
    };
    print("token: $token");
    await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: headerMap,
        body: json.encode(sendNotificationMap));
  }

  static void retrieveHistoryInfo(context) {
    
    userRef
        .child(firebaseUser.uid)
        .child('history')
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic> keys = dataSnapshot.value;
        int tripCounter = keys.length;
        Provider.of<AppData>(context, listen: false)
            .updateTripCounter(tripCounter);
        List<String> tripHistoryKey = [];
        keys.forEach((key, value) {
          tripHistoryKey.add(key);
        });
        Provider.of<AppData>(context, listen: false)
            .updateTripKeys(tripHistoryKey);
        obtainTripHistoryDetails(context);
        
      }
    });
  }

  static void obtainTripHistoryDetails(context) {
    List<String> keys =
        Provider.of<AppData>(context, listen: false).tripHistoryKeys;
    for (String key in keys) {
      FirebaseDatabase.instance.reference().child("Ride Request").child(key).once().then((DataSnapshot dataSnapshot) {
        if (dataSnapshot.value != null) {
          Provider.of<AppData>(context, listen: false)
              .updateTripHistoryData(History.fromSnapshot(dataSnapshot));
        }
      });
    }
  }
  static String formatTripDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate =
        "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";
    return formattedDate;
  }
}
