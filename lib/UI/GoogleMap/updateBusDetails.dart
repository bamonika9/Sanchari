import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_place/google_place.dart';
import 'package:location/location.dart' as Loc;
import 'package:sanchari/Models/busDetails_model.dart';
import 'package:sanchari/UI/Home/qrCode.dart';
import 'package:sanchari/constants.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

class UpdateBusDetails extends StatefulWidget {
  const UpdateBusDetails({Key? key}) : super(key: key);

  @override
  State<UpdateBusDetails> createState() => _UpdateBusDetailsState();
}

class _UpdateBusDetailsState extends State<UpdateBusDetails> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  BusDetail busDetail = BusDetail();
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  late GooglePlace googlePlace;
  final geo = Geoflutterfire();

  Loc.LocationData? currentLocation;

  void getCurrentLocation() async {
    Loc.Location location = Loc.Location();

    location.getLocation().then((location) {
      currentLocation = location;
    });

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      setState(() {
        currentLocation = newLoc;
      });
      GeoFirePoint myLocation = geo.point(
          latitude: currentLocation!.latitude!,
          longitude: currentLocation!.longitude!);
      if (busDetail.busNumber != null) {
        FirebaseFirestore.instance
            .collection("BusLocationDetails")
            .where("BusNumber", isEqualTo: busDetail.busNumber)
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((documentSnapshot) {
            documentSnapshot.reference.update({
              "BusLiveLocation": myLocation.data,
            });
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final geo = Geoflutterfire();
    this._controllers.add(TextEditingController());
    getCurrentLocation();

    String apiKey = 'AIzaSyCslHZgsw_rDgdBsRSz2JSqHkMldK0p9Ig';
    googlePlace = GooglePlace(apiKey);

    this._focusNodes.add(FocusNode());
    busDetail.busStops = new List<String>.empty(growable: true);
    busDetail.isActive = false;
    busDetail.busStops!.add("");
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? kLightSecondaryColor
          : kDarkPrimaryColor,
      appBar: AppBar(
        title: Text('Track Bus'),
        backgroundColor: const Color(0xffE3002C),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Container(
            width: screenWidth * 0.7,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                // Respond to button press
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Qrcode()),
                );
              },
              label: Text("Scan With QR Code"),
              icon: Icon(Icons.qr_code_scanner_sharp, size: 18),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Current Bus Status",
                style: TextStyle(
                    color: Color.fromARGB(136, 46, 38, 63),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              Switch(
                value: busDetail.isActive!,
                onChanged: (value) {
                  setState(() {
                    busDetail.isActive = value;
                  });
                },
                activeTrackColor: Colors.green,
                activeColor: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 25),
          _uiWidget(),
        ],
      ),
    );
  }

  Widget _uiWidget() {
    return new Form(
        key: globalKey,
        child: Expanded(
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFormField(
                        cursorColor: Colors.red,
                        // controller: busEditingController,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter Bus Number";
                          }
                          return null;
                        },
                        onSaved: (onSavedVal) {
                          this.busDetail.busNumber = onSavedVal;
                        },
                        initialValue: busDetail.busNumber ?? "",
                        // onChanged: (value) {
                        //   busEditingController.text = value;

                        //   print(busEditingController.text);
                        // },
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16),
                        decoration: InputDecoration(
                          labelText: "Bus Number",
                          labelStyle: TextStyle(
                              color: kAccentColor,
                              fontWeight: FontWeight.normal),
                          isDense: true,
                          prefixIcon: Padding(
                            padding:
                                EdgeInsets.only(left: 10, right: 3, bottom: 3),
                            child: Icon(
                              Icons.directions_bus_rounded,
                              size: 25,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black26
                                  : Colors.white24,
                            ),
                          ),
                          hintText: "Enter Bus Number",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: "OpenSans",
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black26
                                    : Colors.white24,
                          ),
                          border: OutlineInputBorder(),
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 0, minHeight: 0),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                BorderSide(color: Colors.red, width: 2.0),
                          ),
                        ),
                      ),
                      _stopsContainer(),
                      Center(
                        child: FormHelper.submitButton("Update", () async {
                          getCurrentLocation();
                          print(currentLocation!.latitude);
                          GeoFirePoint myLocation = geo.point(
                              latitude: currentLocation!.latitude!,
                              longitude: currentLocation!.longitude!);
                          if (validateAndSave()) {
                            print(busDetail.toJson());
                            if (globalKey.currentState!.validate()) {
                              String message;

                              try {
                                final collection = FirebaseFirestore.instance
                                    .collection("BusLocationDetails");
                                collection
                                    .where("BusNumber",
                                        isEqualTo: busDetail.busNumber)
                                    .get()
                                    .then((value) => {
                                          if (value.size > 0 &&
                                              busDetail.busNumber != null)
                                            {
                                              collection
                                                  .where("BusNumber",
                                                      isEqualTo:
                                                          busDetail.busNumber)
                                                  .get()
                                                  .then((querySnapshot) {
                                                querySnapshot.docs.forEach(
                                                    (documentSnapshot) {
                                                  documentSnapshot.reference
                                                      .update({
                                                    "BusNumber":
                                                        busDetail.busNumber,
                                                    "BusStatus":
                                                        busDetail.isActive,
                                                    "BusLiveLocation":
                                                        myLocation.data,
                                                    "BusStops":
                                                        busDetail.busStops
                                                  });
                                                });
                                              })
                                            }
                                          else
                                            {
                                              collection.doc().set({
                                                "BusNumber":
                                                    busDetail.busNumber,
                                                "BusStatus": busDetail.isActive,
                                                "BusLiveLocation":
                                                    myLocation.data,
                                                "BusStops": busDetail.busStops
                                              })
                                            }
                                        });

                                message = "Bus Location Updated Successfully!";
                              } catch (error) {
                                message = "Error while updating  Bus Location!";
                                print(error);
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)));
                              // Navigator.pop(context);
                            }
                          }
                        }),
                      ),
                    ])),
          ),
        ));
  }

  Widget _stopsContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ListView.separated(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemBuilder: (context, index) {
              return Column(
                children: [stopsUI(index)],
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: busDetail.busStops!.length),
      ],
    );
  }

  Widget stopsUI(index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Row(
        children: [
          Flexible(
            child: TypeAheadFormField(
              suggestionsCallback: (pattern) async {
                if (pattern.length > 0) {
                  var result = await googlePlace.autocomplete.get(pattern);
                  if (result != null && result.predictions != null && mounted) {
                    if (result.predictions!.length == 0) {
                      return Iterable<String>.empty();
                    }
                    List<String> locations = [];
                    for (var element in result.predictions!) {
                      locations.add(element.description!);
                    }
                    return locations;
                  }
                  return Iterable<String>.empty();
                }

                return Iterable<String>.empty();
              },
              getImmediateSuggestions: true,
              hideSuggestionsOnKeyboardHide: false,
              hideOnEmpty: false,
              noItemsFoundBuilder: (context) => Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("No Location found!"),
              ),
              itemBuilder: (BuildContext context, String itemData) => ListTile(
                title: Text(itemData),
              ),
              onSuggestionSelected: (String val) {
                this._controllers[index].text = val;
                this.busDetail.busStops![index] = val;
              },
              onSaved: (value) {
                this.busDetail.busStops![index] = value!;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return "Stop ${index + 1} can't be empty";
                }
                return null;
              },
              textFieldConfiguration: TextFieldConfiguration(
                  controller: this._controllers[index],
                  textInputAction: TextInputAction.done,
                  focusNode: _focusNodes[index],
                  cursorColor: Colors.red,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: "Bus Stops",
                    labelStyle: TextStyle(
                        color: kAccentColor, fontWeight: FontWeight.normal),
                    isDense: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 10, right: 3, bottom: 3),
                      child: Icon(
                        Icons.location_on,
                        size: 25,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black26
                            : Colors.white24,
                      ),
                    ),
                    hintText: "Add New Stop",
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: "OpenSans",
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black26
                          : Colors.white24,
                    ),
                    border: OutlineInputBorder(),
                    prefixIconConstraints:
                        BoxConstraints(minWidth: 0, minHeight: 0),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.red, width: 2.0),
                    ),
                  )),
            ),
          ),
          Visibility(
            child: SizedBox(
              width: 35,
              child: IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Colors.green,
                ),
                onPressed: () {
                  addStopsControl();
                },
              ),
            ),
            visible: index == busDetail.busStops!.length - 1,
          ),
          Visibility(
            child: SizedBox(
              width: 35,
              child: IconButton(
                icon: Icon(
                  Icons.remove_circle,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  removeStopsControl(index);
                },
              ),
            ),
            visible: index > 0,
          ),
        ],
      ),
    );
  }

  void addStopsControl() {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    setState(() {
      _controllers.add(controller);
      _focusNodes.add(focusNode);
      busDetail.busStops!.add("");
    });
  }

  void removeStopsControl(index) {
    setState(() {
      if (busDetail.busStops!.length > 1) {
        busDetail.busStops!.removeAt(index);
        _focusNodes.removeAt(index);
        _controllers.removeAt(index);
      }
    });
  }

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
