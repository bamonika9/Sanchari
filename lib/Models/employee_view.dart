class EmployeeView {
  String? uid;
  String? email;
  String? fullname;
  String? employeeId;

  EmployeeView();
  // receiving data from server
  EmployeeView.fromSnapshot(snapshot)
      : uid = snapshot.data['uid'],
        email = snapshot.data['Email'],
        fullname = snapshot.data['Fullname'],
        employeeId = snapshot.data['employeeId'];
}
