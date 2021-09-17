import 'package:flutter/cupertino.dart';
import 'package:uber_app/models/Address.dart';
import 'package:uber_app/models/History.dart';
import 'package:uber_app/models/TimeAndDistance.dart';

class AppData extends ChangeNotifier{
  Address pickupLocation = Address();
  Address dropOffLocation = Address();
   String earnings = "0";
  int tripCounter = 0;
  List <String> tripHistoryKeys = [];
  List <History> tripHistoryData = [];
  
  void updateEarnings(String updatedEarnings) {
    earnings = updatedEarnings;
    notifyListeners();
  }
  
  void updateTripCounter(int localTripCounter) {
    tripCounter = localTripCounter;
    notifyListeners();
  }

  void updateTripKeys(List<String> newKey) {
    tripHistoryKeys =newKey;
    notifyListeners();
  }
  
  void updateTripHistoryData(History eachHistory) {
    tripHistoryData.add(eachHistory);
    notifyListeners();
  }
  TimeAndDistance timeAndDistance = TimeAndDistance();
  void updatePickupAddress(Address pickUpAddress){
    pickupLocation = pickUpAddress;
    notifyListeners();
  }
  void updatedropOffAddress(Address dropOffAddress){
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }
  void setDuration(TimeAndDistance timeAndDistancein){
    timeAndDistance = timeAndDistancein;
    notifyListeners();
  }
}