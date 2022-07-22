import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:sanchari/UI/GoogleMap/googleMapScreen.dart';
import 'package:sanchari/constants.dart';

class LocationSearch extends StatefulWidget {
  const LocationSearch({Key? key}) : super(key: key);

  @override
  State<LocationSearch> createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  final _startSearchFieldController = TextEditingController();
  final _endSearchFeildController = TextEditingController();

  DetailsResult? startPosition;
  DetailsResult? endPosition;

  late FocusNode startFocusNode;
  late FocusNode endFocusNode;
  List<dynamic> _buses = [];
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  late GeoPoint gpoint;
  bool _searched = true;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    String apiKey = 'AIzaSyCslHZgsw_rDgdBsRSz2JSqHkMldK0p9Ig';
    googlePlace = GooglePlace(apiKey);

    startFocusNode = FocusNode();
    endFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();

    startFocusNode.dispose();
    endFocusNode.dispose();
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      print(result.predictions!.first.description);
      setState(() {
        predictions = result.predictions!;
        print(predictions);
      });
    } else {
      print("Something went wrong with places Api!");
    }
  }

  void searchFunc() {
    setState(() {
      _searched = !_searched;
    });
    print(_startSearchFieldController.text);
    print(_endSearchFeildController.text);
    FirebaseFirestore.instance
        .collection("BusLocationDetails")
        .where("BusStops", arrayContainsAny: [
          _startSearchFieldController.text,
          _endSearchFeildController.text
        ])
        .get()
        .then((value) => {
              _buses = List.from(value.docs.map((doc) => doc.data())),
              gpoint = _buses[0]['BusLiveLocation']['geopoint'],
              print(gpoint.latitude)
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? kLightSecondaryColor
          : kDarkPrimaryColor,
      appBar: AppBar(
        title: Text("Search Bus"),
        backgroundColor: const Color(0xffE3002C),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
        child: Column(
          children: [
            Container(
              height: 55,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60),
                ),
                child: TextField(
                    controller: _startSearchFieldController,
                    autofocus: true,
                    focusNode: startFocusNode,
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                        hintText: "Choose start location",
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                        contentPadding: EdgeInsets.fromLTRB(20, 30, 0, 0),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.light
                                ? kLightPrimaryColor
                                : kDarkSecondaryColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        suffixIcon: _startSearchFieldController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    predictions = [];
                                    _startSearchFieldController.clear();
                                  });
                                },
                                icon: Icon(
                                  Icons.clear_outlined,
                                ))
                            : null),
                    onChanged: (value) {
                      setState(() {
                        _searched = true;
                      });
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(Duration(milliseconds: 1000), () {
                        if (value.isNotEmpty) {
                          autoCompleteSearch(value);
                        } else {
                          setState(() {
                            predictions = [];
                            startPosition = null;
                          });
                        }
                      });
                    }),
                color: Colors.white,
                elevation: 5,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 55,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60),
                ),
                child: TextField(
                    controller: _endSearchFeildController,
                    autofocus: false,
                    // enabled: _startSearchFieldController.text.isNotEmpty &&
                    //     startPosition != null,
                    focusNode: endFocusNode,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        hintText: "Choose destination",
                        contentPadding: EdgeInsets.fromLTRB(20, 30, 0, 0),
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.light
                                ? kLightPrimaryColor
                                : kDarkSecondaryColor,
                        suffixIcon: _endSearchFeildController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    predictions = [];
                                    _endSearchFeildController.clear();
                                  });
                                },
                                icon: Icon(Icons.clear_outlined))
                            : null),
                    onChanged: (value) {
                      setState(() {
                        _searched = true;
                      });
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(Duration(milliseconds: 1000), () {
                        if (value.isNotEmpty) {
                          autoCompleteSearch(value);
                        } else {
                          setState(() {
                            predictions = [];
                            endPosition = null;
                          });
                        }
                      });
                    }),
                color: Colors.white,
                elevation: 5,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  if (startPosition != null && endPosition != null) {
                    print("navigation");
                    searchFunc();
                    // code to search bus based on start and end location
                  }
                },
                child: Text("Search Bus")),
            Visibility(
              visible: _searched,
              child: Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: predictions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                            child: Icon(
                          Icons.pin_drop,
                          color: Colors.white,
                        )),
                        title: Text(
                          predictions[index].description.toString(),
                        ),
                        onTap: () async {
                          final placeId = predictions[index].placeId!;
                          final placeLoc =
                              predictions[index].description.toString();
                              
                          final details =
                              await googlePlace.details.get(placeId);

                          if (details != null &&
                              details.result != null &&
                              mounted) {
                            if (startFocusNode.hasFocus) {
                              setState(() {
                                startPosition = details.result;
                                print("predthing cordinates");
                                print(details.result!.geometry);
                                _startSearchFieldController.text = placeLoc;
                                predictions = [];
                              });
                              print("place" + placeLoc);
                            } else {
                              setState(() {
                                endPosition = details.result;
                                _endSearchFeildController.text = placeLoc;
                                predictions = [];
                              });
                            }

                            if (startPosition != null && endPosition != null) {
                              print("navigation");

                              // code to search bus based on start and end location
                            }
                          }
                        },
                      );
                    }),
              ),
            ),
            Visibility(
                visible: !_searched,
                child: Expanded(
                  child: Card(
                      elevation: 10,
                      margin: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(35),
                              topRight: Radius.circular(35))),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 20),
                              Icon(
                                Icons.search,
                                size: 25.0,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Results",
                                style: TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                          Container(
                              margin: const EdgeInsets.only(
                                  left: 15.0, right: 15.0),
                              child: Divider(
                                color: Colors.black,
                                height: 20,
                              )),
                          Expanded(
                            child: ListView.builder(
                                itemCount: _buses.length,
                                itemBuilder: (context, index) {
                                  gpoint = _buses[index]['BusLiveLocation']
                                      ['geopoint'];
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(7))),
                                    child: ListTile(
                                      leading: Container(
                                        height: double.infinity,
                                        child: Icon(
                                          Icons.directions_bus_rounded,
                                          size: 40.0,
                                        ),
                                      ),
                                      title:
                                          Text("${_buses[index]["BusNumber"]}"),
                                      subtitle: Text(
                                          "${_buses[index]["BusStops"].first} --->  \n ${_buses[index]["BusStops"].last}"),
                                      trailing: Container(
                                        height: double.infinity,
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        GoogleMapScreen(
                                                          locLat:
                                                              gpoint.latitude,
                                                          locLong:
                                                              gpoint.longitude,
                                                        )));
                                          },
                                          icon: Icon(Icons.directions),
                                          color: Colors.blue,
                                          iconSize: 40.0,
                                        ),
                                      ),
                                    ),
                                    elevation: 10,
                                    margin: EdgeInsets.fromLTRB(20, 8, 20, 8),
                                  );
                                }),
                          )
                        ],
                      )),
                ))
          ],
        ),
      ),
    );
  }
}
/*

 */