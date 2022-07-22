import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sanchari/UI/Admin/addBus.dart';
import 'package:sanchari/UI/GoogleMap/googleMapScreen.dart';
import 'package:sanchari/constants.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _busNumberController = TextEditingController();
  List<dynamic> _buses = [];
  late GeoPoint gpoint;

  void getBusdetails() {
    print(_busNumberController.text);
    FirebaseFirestore.instance
        .collection("BusLocationDetails")
        .where("BusNumber", isEqualTo: _busNumberController.text)
        .snapshots()
        .listen((value) {
      print(value.size);
      setState(() {
        _buses = List.from(value.docs.map((doc) => doc.data()));
      });
      print(_buses);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? kLightSecondaryColor
            : kDarkPrimaryColor,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
              padding: EdgeInsets.all(15.0),
              child: Card(
                child: TextField(
                  controller: _busNumberController,
                  autofocus: false,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                      hintText: "Bus Number",
                      hintStyle: const TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 18),
                      filled: true,
                      fillColor:
                          Theme.of(context).brightness == Brightness.light
                              ? kLightPrimaryColor
                              : kDarkSecondaryColor,
                      border: InputBorder.none),
                ),
                elevation: 5,
              )),
          ElevatedButton(
              onPressed: () {
                getBusdetails();
              },
              child: Text("Search Bus")),
          Expanded(
            child: Card(
                elevation: 8,
                margin: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
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
                          Icons.history,
                          size: 30.0,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Recent",
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Divider(
                          color: Colors.black,
                          height: 20,
                        )),
                    Expanded(
                      child: ListView.builder(
                          itemCount: _buses.length,
                          itemBuilder: (context, index) {
                            gpoint =
                                _buses[index]['BusLiveLocation']['geopoint'];
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(7))),
                              child: ListTile(
                                leading: Container(
                                  height: double.infinity,
                                  child: Icon(
                                    Icons.directions_bus_rounded,
                                    size: 40.0,
                                  ),
                                ),
                                title: Text("${_buses.first["BusNumber"]}"),
                                subtitle: Text(
                                    "${_buses.first["BusStops"][0].split(",")[0]} - " +
                                        "${_buses.first["BusStops"].last.split(",")[0]}"),
                                trailing: Wrap(
                                  spacing: 12, // space between two icons
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    GoogleMapScreen(
                                                      locLat: gpoint.latitude,
                                                      locLong: gpoint.longitude,
                                                    )));
                                      },
                                      child: Icon(
                                        Icons.directions,
                                        color: Colors.blue,
                                        size: 35,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        // code to add bookmark to firebase
                                        bool flag = false;
                                        FirebaseFirestore.instance
                                            .collection("BookmarksUser")
                                            .where("UserId",
                                                isNotEqualTo: FirebaseAuth
                                                    .instance.currentUser?.uid)
                                            .where("UserId",
                                                isEqualTo:
                                                    _buses.first['BusNumber'])
                                            .get()
                                            .then((value) => {
                                                  if (value.docs
                                                      .map((e) => e.data())
                                                      .map((e) => {
                                                            if (e['BusNumber'] ==
                                                                _buses.first[
                                                                    "BusNumber"])
                                                              {flag = true}
                                                          })
                                                      .isEmpty)
                                                    {
                                                      if (flag != true)
                                                        {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "BookmarkUser")
                                                              .doc()
                                                              .set({
                                                            "BusNumber": _buses
                                                                    .first[
                                                                "BusNumber"],
                                                            "UserId":
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    ?.uid,
                                                            "startAndEnd":
                                                                "${_buses.first["BusStops"][0].split(",")[0]} - " +
                                                                    "${_buses.first["BusStops"].last.split(",")[0]}"
                                                          })
                                                        }
                                                    }
                                                });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Bookmark added Successfully!")));
                                      },
                                      child: Icon(
                                        Icons.bookmark_add_outlined,
                                        color: Colors.blue,
                                        size: 35,
                                      ),
                                    ), // icon-1
                                  ],
                                ),
                              ),
                              elevation: 10,
                              margin: EdgeInsets.fromLTRB(20, 8, 20, 8),
                            );
                          }),
                    )
                  ],
                )),
          )
        ]));
  }
}
