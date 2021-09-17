import 'package:firebase_database/firebase_database.dart';

class AllUsers{
  String id='';
  String email=''; 
  String name='';
  String phone='';
  AllUsers({this.email='',this.id='',this.name='',this.phone=''});
  AllUsers.fromSnapShot(DataSnapshot dataSnapshot){
    id = dataSnapshot.key.toString();
    email = dataSnapshot.value["email"];
    name = dataSnapshot.value["name"];
    phone = dataSnapshot.value["phone"];
  }
}