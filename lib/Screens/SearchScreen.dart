import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_app/Assistants/RequestAssistant.dart';
import 'package:uber_app/DataHandler/AppData.dart';
import 'package:uber_app/Widgets/DividerWidget.dart';
import 'package:uber_app/Widgets/ProgressDialog.dart';
import 'package:uber_app/models/Address.dart';
import 'package:uber_app/models/placePrediction.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<PlacePrediction> placePredictionList = [];
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickupLocation.placeName;
    pickUpTextEditingController.text = placeAddress;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Search Screen'),
      ),
      body: Column(
        children: [
          Container(
            child: Padding(
              padding:
                  EdgeInsets.all(25),
              child: Column(
                children: [
                  SizedBox(
                    height: 5.0,
                  ),
                  Stack(
                    children: [
                      Icon(Icons.arrow_back),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Set drop off',
                            style: TextStyle(
                                fontSize: 18, fontFamily: 'Brand-Bold'),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Image.asset(
                        'images/pickicon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: TextField(
                              controller: pickUpTextEditingController,
                              decoration: InputDecoration(
                                hintText: 'Pickup Location',
                                fillColor: Colors.white,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  left: 11,
                                  top: 8,
                                  bottom: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Image.asset(
                        'images/desticon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: TextField(
                              onChanged: (value) {
                                findPlace(value);
                              },
                              controller: dropOffTextEditingController,
                              decoration: InputDecoration(
                                hintText: 'Where to?',
                                fillColor: Colors.white,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  left: 11,
                                  top: 8,
                                  bottom: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            height: 200,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 6.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              )
            ]),
          ),
          
          (placePredictionList.length > 0)
              ? Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return PredictionTile(
                        placePrediction: placePredictionList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        DividerWidget(),
                    itemCount: placePredictionList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Future<void> findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteURL =
          "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/suggest?text=$placeName&f=pjson&countyrCode=IN";

      var result = await RequestAssistant.getRequest(autoCompleteURL);
      if (result == "Failed, No Response!!") {
        return;
      } else {
        var predictions = result["suggestions"];
        var placeList = (predictions as List)
            .map((e) => PlacePrediction.fromjson(e))
            .toList();
          
        setState(() {
          placePredictionList = placeList;
        });
        
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePrediction placePrediction;
  PredictionTile({Key? key, required this.placePrediction}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlaceAddressDetails(placePrediction.magicKey, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Icon(Icons.add_location_alt_sharp),
                SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.0),
                      Text(
                        placePrediction.placeAddress,
                        style: TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeID, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Updating Drop Off Location...."));
    String placeDetailsURL =
        "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?magicKey=$placeID&f=pjson";
    var result = await RequestAssistant.getRequest(placeDetailsURL);
    Navigator.pop(context);
    if (result == "Failed, No Response!!") {
      print("FAILED");
      return;
    } else {
      Address address = Address();
      address.placeName = result["candidates"][0]["address"];
      address.latitude = result["candidates"][0]["location"]["y"];
      address.longitude = result["candidates"][0]["location"]["x"];
      Provider.of<AppData>(context, listen: false).updatedropOffAddress(address);
      Navigator.pop(context, "Check");
    }
  }
}
