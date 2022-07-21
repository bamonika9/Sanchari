// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sanchari/UI/Admin/adminDashboard.dart';
import 'package:sanchari/constants.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<dynamic> _viewnotification = [];
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("Notifications")
        .snapshots()
        .listen((value) {
      print("fetching notifications");
      setState(() {
        _viewnotification = List.from(value.docs.map((doc) => doc.data()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? kLightSecondaryColor
            : kDarkPrimaryColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 25,
            ),
            Text(
              "Notifications",
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: _viewnotification.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: Container(
                          child: Icon(
                            Icons.message,
                            size: 38.0,
                            color: Colors.blue,
                          ),
                        ),
                        title: Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                          child: Text(
                            '${_viewnotification[index]["Title"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 46, 118, 243),
                                fontSize: 18),
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 5.0),
                          child: Text(
                            "${_viewnotification[index]["Message"]}",
                            style: TextStyle(
                                color: Colors.black38,
                                fontStyle: FontStyle.italic,
                                fontSize: 14),
                          ),
                        ),
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AdminDashboard()),
                          )
                        },
                      ),
                      // color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 8),
                    );
                  }),
            )
          ],
        ));
  }
}
