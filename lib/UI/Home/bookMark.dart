import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sanchari/UI/GoogleMap/googleMapScreen.dart';
import 'package:sanchari/UI/GoogleMap/updateBusDetails.dart';
import 'package:sanchari/constants.dart';

class Bookmark extends StatefulWidget {
  const Bookmark({Key? key}) : super(key: key);

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  List<dynamic> _viewBookmarks = [];
  late GeoPoint gpoint;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("BookmarkUser")
        .where("UserId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((value) {
      // this.loggedInUser = UserModel.fromMap(value.data());
      print("fetching");
      setState(() {
        _viewBookmarks = List.from(value.docs.map((doc) => doc.data()));
      });
      print(_viewBookmarks);
      // print(value);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? kLightSecondaryColor
            : kDarkPrimaryColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 25,
            ),
            Center(
              child: Text(
                "Bookmarks",
                style: TextStyle(fontSize: 30),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: _viewBookmarks.length,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7))),
                      child: ListTile(
                        leading: Container(
                          height: double.infinity,
                          child: Icon(
                            Icons.directions_bus_rounded,
                            size: 40.0,
                          ),
                        ),
                        title: Text("${_viewBookmarks[index]["BusNumber"]}"),
                        subtitle:
                            Text("${_viewBookmarks[index]["startAndEnd"]}"),
                        trailing: Wrap(
                          spacing: 12, // space between two icons
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GoogleMapScreen(
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            UpdateBusDetails())));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Bookmark removed Successfully!")));
                              },
                              child: Icon(
                                Icons.bookmark_remove_outlined,
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
        ));
  }
}
