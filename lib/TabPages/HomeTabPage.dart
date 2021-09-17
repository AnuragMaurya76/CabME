import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_app/Assistants/GeoFireAssistant.dart';
import 'package:uber_app/Assistants/MethodAssistant.dart';
import 'package:uber_app/DataHandler/AppData.dart';
import 'package:uber_app/Screens/LoginScreen.dart';
import 'package:uber_app/Screens/RatingScreen.dart';
import 'package:uber_app/Screens/SearchScreen.dart';
import 'package:uber_app/Widgets/CollectFareDialog.dart';
import 'package:uber_app/Widgets/DividerWidget.dart';
import 'package:uber_app/Widgets/NoDriverAvailableDialog.dart';
import 'package:uber_app/Widgets/ProgressDialog.dart';
import 'package:uber_app/Widgets/ShowAboutDialog.dart';
import 'package:uber_app/configMap.dart';
import 'package:uber_app/main.dart';
import 'package:uber_app/models/NearbyAvailableDrivers.dart';
import 'package:uber_app/models/TimeAndDistance.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeTabPage extends StatefulWidget {
  static final idScreen = "HomeTabPage";
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage>
    with TickerProviderStateMixin {
  String driverTimeInfo = "Driver is on the way";
  String driverTimeLeft = "Time Left: 0 mins";
  double bottomPaddinfOfMap = 0;
  double searchContainerHeight = 300;
  double rideDetailContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double driverDetailsContainerHeight = 0;
  TimeAndDistance tripTimeAndDistance = TimeAndDistance();
  final GlobalKey<ScaffoldState> scaffoldGlobalKey =
      new GlobalKey<ScaffoldState>();
  final List<LatLng> pLineCoordinates = [];
  final Set<Polyline> polyLineSet = {};
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;
  late Position currentPosition;
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  bool rideSet = false;
  late BitmapDescriptor nearbyIcon;
  String state = 'normal';
  bool isRequestingPositionDetails = false;
  late StreamSubscription rideStreamSubscription;

  @override
  void initState() {
    MethodAssistant.getCurrentOnlineUserInfo(context);
    super.initState();
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentPosition = position;

    Geolocator.getPositionStream().listen((Position position) async {
      currentPosition = position;
      LatLng latLng = LatLng(position.latitude, position.longitude);
      if (mounted) {
        CameraPosition cameraPosition =
            new CameraPosition(target: latLng, zoom: 14);
        newGoogleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        MethodAssistant.searchCoordinateAddress(position, context);
      }
    });

    initGeoFire();
  }

  void saveRideRequest() {
    rideRequestReference =
        FirebaseDatabase.instance.reference().child("Ride Request").push();
    var pickUp = Provider.of<AppData>(context, listen: false).pickupLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocation = {
      'Latitude': pickUp.latitude.toString(),
      'Longitude': pickUp.longitude.toString(),
    };

    Map dropOffLocation = {
      'Latitude': dropOff.latitude.toString(),
      'Longitude': dropOff.longitude.toString(),
    };

    Map rideInfoMap = {
      "driver_id": "waiting",
      "payment_mode": "cash",
      "pickup": pickUpLocation,
      "dropOff": dropOffLocation,
      "created_at": DateTime.now().toString(),
      "rider_name": currentOnlineUser.name,
      "rider_phone": currentOnlineUser.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
    };

    rideRequestReference.set(rideInfoMap);
    rideStreamSubscription = rideRequestReference.onValue.listen((event) async {
      if (event.snapshot.value == null) {
        return;
      }
      if (event.snapshot.value['Status'] != null) {
        statusRide = event.snapshot.value["Status"].toString();
        if (event.snapshot.value['driver_location'] != null) {
          LatLng driverCurrentLocation = LatLng(
            double.parse(
                event.snapshot.value['driver_location']['latitude'].toString()),
            double.parse(event.snapshot.value['driver_location']['longitude']
                .toString()),
          );
          if (statusRide == 'accepted') {
            updateRideTimeToPickupLocation(driverCurrentLocation);
          } else if (statusRide == 'onRide') {
            updateRideTimeToDropOffLocation(driverCurrentLocation);
          } else if (statusRide == 'arrived') {
            setState(() {
              driverTimeInfo = 'Driver has Arrived';
              driverTimeLeft = "";
            });
          } else if (statusRide == 'ended') {
            if (event.snapshot.value['fare'] != null) {
              int fare = int.parse(event.snapshot.value['fare'].toString());

              var res = await showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      CollectFareDialog(amount: fare, paymentMethod: 'Cash'));

              String driverId = '';
              if (res == 'close') {
                if (event.snapshot.value['driver_id'] != null) {
                  driverId = event.snapshot.value['driver_id'];
                }
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RatingScreen(driverId: driverId)));

                rideRequestReference.onDisconnect();
                rideStreamSubscription.cancel();
                resetApp();
              }
            }
          }
        }
        if (statusRide == 'accepted') {
          Map<String, String> details = {
            "car_details": event.snapshot.value["car_details"].toString(),
            "driver_phone": event.snapshot.value["driver_phone"].toString(),
            "driver_name": event.snapshot.value["driver_name"].toString(),
          };
          driverDetails.addEntries(details.entries);
          displayDriverDetailsCotainer();
        }
      }
    });
  }

  void deleteGeoFireMarker() {
    setState(() {
      markersSet
          .removeWhere((element) => element.markerId.value.contains('drivers'));
    });
  }

  void updateRideTimeToPickupLocation(LatLng driverCurrentLocation) {
    rideRequestReference.child('time').onValue.listen((event) async {
      String time = await event.snapshot.value;
      setState(() {
        driverTimeInfo = "Driver is on the way.";
        driverTimeLeft = "Time Left: ${time.toString()} mins";
      });
    });
    isRequestingPositionDetails = false;
  }

  void updateRideTimeToDropOffLocation(LatLng driverCurrentLocation) {
    rideRequestReference.child('time').onValue.listen((event) async {
      String time = await event.snapshot.value;
      setState(() {
        driverTimeInfo = "Trip to destination.";
        driverTimeLeft = "Time Left: ${time.toString()} mins";
      });
    });
  }

  void cancelRideRequest() {
    rideRequestReference.remove();
    setState(() {
      state = 'normal';
    });
  }

  void resetApp() {
    setState(() {
      rideDetailContainerHeight = 0;
      searchContainerHeight = 300;
      requestRideContainerHeight = 0;
      driverDetailsContainerHeight = 0;
      pLineCoordinates.clear();
      circlesSet.clear();
      markersSet.clear();
      polyLineSet.clear();
      rideSet = false;
      statusRide = '';
      driverDetails.clear();
      driverTimeInfo = 'Driver is on the way';
      driverTimeLeft = "Time left: 0 mins";
      title = 'Rate your experience';
    });
    locatePosition();
  }

  void displayRequestRideContainer() {
    setState(() {
      rideDetailContainerHeight = 0;
      requestRideContainerHeight = 300;
      rideSet = false;
    });
    saveRideRequest();
  }

  void displayDriverDetailsCotainer() {
    setState(() {
      rideDetailContainerHeight = 0;
      requestRideContainerHeight = 0;
      rideSet = false;
      driverDetailsContainerHeight = 300;
      Geofire.stopListener();
      markersSet.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      key: scaffoldGlobalKey,
      appBar: AppBar(
        title: Text('CabME'),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Refreshing Driver Location..."),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.black87,
                  ));
                  initGeoFire();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_outlined,
                      size: 26.0,
                    ),
                  ],
                ),
              )),
        ],
      ),

      //Drawer
      drawer: Container(
        width: 280,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset(
                        "images/user_icon.png",
                        height: 65,
                        width: 65,
                      ),
                      SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Profile Name:',
                            style: TextStyle(
                                fontSize: 16.0, fontFamily: 'Brand-Bold'),
                          ),
                          SizedBox(height: 6.0),
                          Text('Visit Profile'),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.0),
              //Drawer Body controller
              ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  'History',
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.person_outlined,
                ),
                title: Text(
                  'Profile',
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (BuildContext context) => ShowAboutDialog());
                },
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text(
                    'About',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.idScreen, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          //Google Map View
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddinfOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: HomeTabPage._kGooglePlex,
            myLocationButtonEnabled: true,
            polylines: polyLineSet,
            markers: markersSet,
            circles: circlesSet,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              bottomPaddinfOfMap = 300;
              newGoogleMapController = controller;
              _controllerGoogleMap.complete(controller);
              locatePosition();
            },
          ),

          //Hamburger Button
          rideSet
              ? Positioned(
                  bottom: 340,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      resetApp();
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Text(
                          "Reset Ride",
                          style:
                              TextStyle(fontSize: 14, fontFamily: "Brand-bold"),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 6.0,
                              offset: Offset(0.7, 0.7),
                              spreadRadius: 0.5,
                            )
                          ]),
                    ),
                  ),
                )
              : Container(),

          // Search Container
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              height: searchContainerHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0),
                ),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                      color: Colors.black)
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Your Current Location',
                      style: TextStyle(
                          fontSize: 14.0, fontFamily: 'Brand-Regular'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 6.0),
                    Text(
                      Provider.of<AppData>(context, listen: true)
                          .pickupLocation
                          .placeName,
                      style:
                          TextStyle(fontSize: 18.0, fontFamily: 'Brand-Bold'),
                    ),
                    SizedBox(height: 40.0),
                    ElevatedButton(
                      onPressed: () async {
                        String result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchScreen()));
                        if (result == 'Check') {
                          getDirection();
                          rideDetailContainerHeight = 300;
                          searchContainerHeight = 0;
                          rideSet = true;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        child: Text(
                          "Book a Cab",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Brand-Regular',
                              fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    SizedBox(height: 24.0),
                    DividerWidget(),
                  ],
                ),
              ),
            ),
          ),

          // Taxi Details container
          Positioned(
            child: Container(
              height: rideDetailContainerHeight,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ]),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 17),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.tealAccent[100],
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Image.asset(
                              "images/taxi.png",
                              height: 70,
                              width: 80,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Car",
                                  style: TextStyle(
                                      fontSize: 18, fontFamily: "Brand-Bold"),
                                ),
                                Text(
                                  "${((tripTimeAndDistance.distance) / 1000).toStringAsFixed(2)} km",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                            Expanded(child: Container()),
                            Text(
                              "Rs. ${MethodAssistant.calculateFares(tripTimeAndDistance).toString()}",
                              style: TextStyle(
                                  fontSize: 18, fontFamily: "Brand-Bold"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.moneyCheckAlt,
                            size: 18,
                            color: Colors.black54,
                          ),
                          SizedBox(
                            width: 16.0,
                          ),
                          Text("Cash"),
                          SizedBox(
                            width: 6.0,
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black54,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              state = 'requesting';
                            });
                            displayRequestRideContainer();
                            searchNearestDriver();
                          },
                          child: Padding(
                            padding: EdgeInsets.all(17),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Request",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Icon(
                                  FontAwesomeIcons.taxi,
                                  color: Colors.white,
                                  size: 26,
                                )
                              ],
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ),
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
          ),

          //Taxi Search Container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: requestRideContainerHeight,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black54,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7))
                  ]),
              child: Column(
                children: [
                  Container(
                    height: 150,
                    child: SizedBox(
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 40,
                          fontFamily: 'Canterbury',
                          color: Colors.black,
                        ),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: [
                            RotateAnimatedText('Requesting the Ride...',
                                textAlign: TextAlign.center),
                            RotateAnimatedText('Finding the ride...',
                                textAlign: TextAlign.center),
                            RotateAnimatedText('Finding a Driver...',
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 300,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          cancelRideRequest();
                          resetApp();
                        });
                      },
                      style: TextButton.styleFrom(primary: Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Cancel the Ride",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Driver Info Container
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black54,
                      blurRadius: 16,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7))
                ],
              ),
              height: driverDetailsContainerHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 6.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          driverTimeInfo,
                          style:
                              TextStyle(fontSize: 20, fontFamily: "Brand-Bold"),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          driverTimeLeft,
                          style:
                              TextStyle(fontSize: 20, fontFamily: "Brand-Bold"),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(height: 22),
                    Divider(
                      color: Colors.grey,
                    ),
                    Text(
                      driverDetails["car_details"].toString(),
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      driverDetails['driver_name'].toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            launch(('tel://${driverDetails['driver_phone']}'));
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 55,
                                width: 55,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(26)),
                                  border:
                                      Border.all(width: 2, color: Colors.grey),
                                ),
                                child: Icon(Icons.call),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text("    Call"),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(26)),
                                border:
                                    Border.all(width: 2, color: Colors.grey),
                              ),
                              child: Icon(Icons.list_outlined),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Details"),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                        Column(
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(26)),
                                border:
                                    Border.all(width: 2, color: Colors.grey),
                              ),
                              child: Icon(Icons.close_rounded),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Cancel Ride"),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getDirection() async {
    var initialPosition =
        Provider.of<AppData>(context, listen: false).pickupLocation;
    var finalPosition =
        Provider.of<AppData>(context, listen: false).dropOffLocation;
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Calculating Fare..."));
    TimeAndDistance tempTimeAndDistance =
        await MethodAssistant.calculateTimeAndDistance(
            LatLng(initialPosition.latitude, initialPosition.longitude),
            LatLng(finalPosition.latitude, finalPosition.longitude),
            context);
    setState(() {
      tripTimeAndDistance = tempTimeAndDistance;
      print("${tripTimeAndDistance.distance} ${tripTimeAndDistance.duration}");
    });
    Navigator.pop(context);
    // pLineCoordinates.clear();
    // LatLng addLatlng;
    // String url =
    //     "https://router.project-osrm.org/route/v1/driving/${initialPosition.longitude},${initialPosition.latitude};${finalPosition.longitude},${finalPosition.latitude}?steps=true";
    // Map<String, dynamic> response = await RequestAssistant.getRequest(url);
    // List<dynamic> steps = response["routes"][0]["legs"][0]["steps"];
    // steps.forEach((steps) {
    //   (steps as Map<String, dynamic>).forEach((key, value) {
    //     if (key == "intersections") {
    //       (value[0] as Map<String, dynamic>).forEach((key, value) {
    //         if (key == "location") {
    //           addLatlng = LatLng(value[1], value[0]);
    //           pLineCoordinates.add(addLatlng);
    //         }
    //       });
    //     }
    //   });
    // });

    // polyLineSet.clear();
    //Navigator.pop(context);
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('PolylineID'),
        width: 4,
        visible: true,
        color: Colors.red,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polyLineSet.add(polyline);
    });
    Marker pickUpLocationMarker = Marker(
        position: LatLng(initialPosition.latitude, initialPosition.longitude),
        markerId: MarkerId("PickUp ID"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
            title: initialPosition.placeName, snippet: "My Location"));
    Marker dropOffLocationMarker = Marker(
        position: LatLng(finalPosition.latitude, finalPosition.longitude),
        markerId: MarkerId("DropOff ID"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
            title: finalPosition.placeName, snippet: "Drop Off Location"));
    setState(() {
      markersSet.add(pickUpLocationMarker);
      markersSet.add(dropOffLocationMarker);
    });
    Circle pickUpLocationCircle = Circle(
        circleId: CircleId("Pickup ID"),
        fillColor: Colors.yellow,
        center: LatLng(initialPosition.latitude, initialPosition.longitude),
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.yellowAccent);
    Circle dropOffLocationCircle = Circle(
        circleId: CircleId("DropOff ID"),
        fillColor: Colors.deepPurple,
        center: LatLng(finalPosition.latitude, finalPosition.longitude),
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.blueAccent);
    setState(() {
      circlesSet.add(pickUpLocationCircle);
      circlesSet.add(dropOffLocationCircle);
    });
  }

  void initGeoFire() {
    Geofire.initialize("AvailableDrivers");

    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 20)!
        .listen((map) {
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map["key"];
            nearbyAvailableDrivers.longitude = map["longitude"];
            nearbyAvailableDrivers.latitude = map["latitude"];
            GeoFireAssistant.nearbyAvailableDriversList
                .add(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeDriverFromList(map["key"]);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map["key"];
            nearbyAvailableDrivers.longitude = map["longitude"];
            nearbyAvailableDrivers.latitude = map["latitude"];
            GeoFireAssistant.updateDriverNearbyLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            updateAvailableDriversOnMap();
            break;
        }
      }
    });
  }

  void updateAvailableDriversOnMap() {
    setState(() {
      markersSet.clear();
    });

    Set<Marker> tmarkers = Set<Marker>();
    for (NearbyAvailableDrivers nearbyAvailableDrivers
        in GeoFireAssistant.nearbyAvailableDriversList) {
      LatLng driverAvailablePosition = LatLng(
          nearbyAvailableDrivers.latitude, nearbyAvailableDrivers.longitude);
      Marker marker = Marker(
          infoWindow: InfoWindow(title: nearbyAvailableDrivers.key),
          markerId: MarkerId("Driver: ${nearbyAvailableDrivers.key}"),
          position: driverAvailablePosition,
          icon: nearbyIcon);
      tmarkers.add(marker);
      setState(() {
        markersSet = tmarkers;
      });
    }
  }

  void createIconMarker() {
    ImageConfiguration imageConfiguration =
        createLocalImageConfiguration(context, size: Size(2, 2));
    BitmapDescriptor.fromAssetImage(
            imageConfiguration, "images/car_android.png")
        .then((value) {
      nearbyIcon = value;
    });
  }

  void searchNearestDriver() {
    if (GeoFireAssistant.nearbyAvailableDriversList.length == 0) {
      cancelRideRequest();
      resetApp();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NoDriverAvailableDialog());
      return;
    }
    var driver = GeoFireAssistant.nearbyAvailableDriversList[0];
    notifyDrivers(driver);
    GeoFireAssistant.nearbyAvailableDriversList.removeAt(0);
  }

  void notifyDrivers(NearbyAvailableDrivers driver) {
    driverRef.child(driver.key).child("NewRide").set(rideRequestReference.key);
    driverRef.child("token").once().then((DataSnapshot dataSnapshot) async {
      if (dataSnapshot.value != null) {
        String token = dataSnapshot.value.toString();
        await MethodAssistant.sendNotificationToDrivers(
            token, context, rideRequestReference.key);
      } else {
        return;
      }
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (state != 'requesting') {
          driverRequestTimeout = 60;
          driverRef.child(driver.key).child("NewRide").set("cancelled");
          driverRef.child(driver.key).child("NewRide").onDisconnect();
          timer.cancel();
        }
        driverRequestTimeout = driverRequestTimeout - 1;
        driverRef.child(driver.key).child('NewRide').onValue.listen((event) {
          if (event.snapshot.value.toString() == 'accepted') {
            driverRequestTimeout = 60;
            driverRef.child(driver.key).child("NewRide").onDisconnect();
            timer.cancel();
          }
        });
        if (driverRequestTimeout == 0) {
          driverRequestTimeout = 60;
          driverRef.child(driver.key).child("NewRide").set("timeout");
          driverRef.child(driver.key).child("NewRide").onDisconnect();
          timer.cancel();
          searchNearestDriver();
        }
      });
    });
  }
}
