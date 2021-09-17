import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uber_app/configMap.dart';
import 'package:uber_app/main.dart';

class PushNotificationService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future initialize() async {
    await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> getToken() async {
    String? token = await firebaseMessaging.getToken();
    print(token);
    driverRef.child(currentOnlineUser.id).child("token").set(token);
    firebaseMessaging.subscribeToTopic("allDrivers");
    firebaseMessaging.subscribeToTopic("allUsers");
  }
}
