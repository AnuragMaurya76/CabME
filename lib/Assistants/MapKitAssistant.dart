import 'package:maps_toolkit/maps_toolkit.dart';

class MapKitAssistant{
  static double getMarkerRotation(sourceLat,sourceLng,dropLat,dropLng){
    var rotation = SphericalUtil.computeHeading(LatLng(sourceLat,sourceLng), LatLng(dropLat, dropLng));
    return rotation.toDouble();
  }
}