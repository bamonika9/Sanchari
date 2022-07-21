import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:sanchari/constants.dart';

class ViewEmployees extends StatefulWidget {
  const ViewEmployees({Key? key}) : super(key: key);

  @override
  State<ViewEmployees> createState() => _ViewEmployeesState();
}

class _ViewEmployeesState extends State<ViewEmployees> {
  final List<String> notifications =
      List<String>.generate(10, (i) => "Notification : $i");
  List<dynamic> _viewEmployees = [];
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("User")
        .where("isEmployee", isEqualTo: true)
        .snapshots()
        .listen((value) {
      // this.loggedInUser = UserModel.fromMap(value.data());
      print("fetching");
      setState(() {
        _viewEmployees = List.from(value.docs.map((doc) => doc.data()));
      });
      print(_viewEmployees);
      // print(value);
    });
  }

  void updateEmployees(String uid, String employeeId) {
    FirebaseFirestore.instance.collection("User").doc(uid).update({
      "isEmployee": false
    }).then(
        (value) => {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(employeeId + " Employee ID removed Successfully!")))
            },
        onError: (e) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Something went wrong!"))));
  }

  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Employees Details'),
          backgroundColor: const Color(0xffE3002C),
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 35,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: _viewEmployees.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              "${_viewEmployees[index]['Fullname'][0]}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () {
                              updateEmployees(_viewEmployees[index]['uid'],
                                  _viewEmployees[index]['employeeId']);
                            },
                            child: Icon(
                              Icons.remove_circle_outline,
                            ),
                          ),
                          title: Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                            child: Text(
                              '${_viewEmployees[index]['Fullname']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blue[800]),
                            ),
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 2.0, 2.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${_viewEmployees[index]["Email"]}",
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black54),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "${_viewEmployees[index]["employeeId"]}",
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black45),
                                )
                              ],
                            ),
                          ),
                          onTap: () => {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => const AdminDashboard()),
                            // )
                          },
                        ),
                        // color: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin: EdgeInsets.fromLTRB(20, 10, 20, 8),
                      );
                    }),
              )
            ],
          ),
        ));
  }
}
