import 'package:uber_app/models/NearbyAvailableDrivers.dart';

class GeoFireAssistant {
  static List<NearbyAvailableDrivers> nearbyAvailableDriversList = [];
  static void removeDriverFromList(String key) {
    int index =
        nearbyAvailableDriversList.indexWhere((element) => element.key == key);
    if (index >= 0) {
      nearbyAvailableDriversList.removeAt(index);
    }
  }

  static void updateDriverNearbyLocation(NearbyAvailableDrivers drivers) {

    int index = nearbyAvailableDriversList
        .indexWhere((element) => element.key == drivers.key);
    if (index >= 0) {
      
    nearbyAvailableDriversList[index].latitude = drivers.latitude;
    nearbyAvailableDriversList[index].longitude = drivers.longitude;
    }
  }
}
