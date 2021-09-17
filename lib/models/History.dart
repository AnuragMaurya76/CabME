import 'package:firebase_database/firebase_database.dart';

class History{
  String paymentMethod = '';
  String createdAt = '';
  String status = '';
  String fares = '';
  String dropOff = '';
  String pickup = '';
  History({this.createdAt='',this.dropOff='',this.fares='',this.paymentMethod='',this.pickup='',this.status=''});
  History.fromSnapshot(DataSnapshot dataSnapshot){
    paymentMethod = dataSnapshot.value['payment_mode'];
    createdAt = dataSnapshot.value['created_at'];
    status =  dataSnapshot.value['Status'];
    fares =  dataSnapshot.value['fare'];
    dropOff =  dataSnapshot.value['dropoff_address'];
    pickup =  dataSnapshot.value['pickup_address'];
  }
}