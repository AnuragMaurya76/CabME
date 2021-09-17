import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber_app/models/AllUsers.dart';

String mapKey = "AIzaSyCJSNQ9RaHPnlpiAK_l8ItUaLsPXMmryxY";
String urlForDirection = "https://router.project-osrm.org/route/v1/driving/72.831062,21.170240;72.824520,21.198360?steps=true";
late User firebaseUser;
AllUsers currentOnlineUser = AllUsers();
int driverRequestTimeout = 60;
String statusRide = '';
Map<String,String> driverDetails ={};
double rating=0;
String title ='Rate your experience';
String serverToken = "key=AAAAs3ZPlkY:APA91bGArRlw-W64L9yJAKm8d6qMd3ipWpGcs-RiNWe0aL2T2rMENZ6savOPAfprEpLV-SxOiorKnksijQvn87Eg9FpBQ0aZxl5ZZ3FWgpcF6Eg4gEMklcXjsUmXEEdl_vowm9MhSjDn";