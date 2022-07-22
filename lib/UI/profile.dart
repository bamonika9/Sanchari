import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:sanchari/Models/user_model.dart';
import 'package:sanchari/Providers/darkTheme_provider.dart';
import 'package:sanchari/UI/Admin/adminDashboard.dart';
import 'package:sanchari/UI/Auth/Login.dart';
import 'package:sanchari/UI/GoogleMap/updateBusDetails.dart';
import 'package:sanchari/UI/busDetails.dart';
import 'package:sanchari/constants.dart';
import 'package:sanchari/UI/contactUs.dart';
import 'package:sanchari/UI/editProfile.dart';
import 'package:sanchari/UI/feedback.dart';
import 'package:sanchari/UI/Auth/passwordReset.dart';

import 'package:share/share.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user = FirebaseAuth.instance.currentUser;

  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("Users")
        .doc(user?.uid)
        .get()
        .then((value) {
      print(value);

      print("fetching");
      setState(() {});
    });
  }

  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    var profileInfo = Expanded(
      child: Column(
        children: [
          Container(
            height: kSpacingUnit.w * 10,
            width: kSpacingUnit.w * 10,
            margin: EdgeInsets.only(top: kSpacingUnit.w * 3),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: kSpacingUnit.w * 5,
                  backgroundImage: NetworkImage(
                      "https://drive.google.com/uc?id=1YkIrSlu7_sApI4lAqzai9LOozh5KThQO&export=download"),
                ),
              ],
            ),
          ),
          SizedBox(height: kSpacingUnit.w * 1.5),
          Text(
            'Monika B A',
            style: kTitleTextStyle,
          ),
          SizedBox(height: kSpacingUnit.w * 0.5),
          Text(
            'monu2001@gmail.com',
            style: TextStyle(
                fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.3),
                fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
    return Scaffold(
        body: Column(
      children: [
        SizedBox(
          height: kSpacingUnit.w * 4,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: kSpacingUnit.w * 3),
            GestureDetector(
              onTap: () => {
                Navigator.pop(context),
              },
              child: Icon(LineAwesomeIcons.arrow_left,
                  size: ScreenUtil().setSp(kSpacingUnit.w * 3)),
            ),
            profileInfo,
            GestureDetector(
              onTap: () => {context.read<DarkTheme>().changeTheme()},
              child: Icon(
                  context.watch<DarkTheme>().isLightMode
                      ? LineAwesomeIcons.moon
                      : LineAwesomeIcons.sun,
                  size: ScreenUtil().setSp(kSpacingUnit.w * 3)),
            ),
            SizedBox(
              width: kSpacingUnit.w * 3,
            ),
          ],
        ),
        Expanded(
            child: ListView(
          children: [
            Visibility(
              visible: true,
              child: GestureDetector(
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminDashboard()),
                  )
                },
                child: ProfileListItem(
                    icon: LineAwesomeIcons.eye, text: 'View Admin'),
              ),
            ),
            Visibility(
              visible: true,
              child: GestureDetector(
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UpdateBusDetails()),
                  )
                },
                child: ProfileListItem(
                    icon: LineAwesomeIcons.sync_icon,
                    text: 'Update Bus Status'),
              ),
            ),
            // GestureDetector(
            //   onTap: () => {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => EditProfile()),
            //     )
            //   },
            //   child: ProfileListItem(
            //     icon: LineAwesomeIcons.edit,
            //     text: 'Edit Profile',
            //   ),
            // ),
            GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PasswordReset()),
                )
              },
              child: ProfileListItem(
                icon: LineAwesomeIcons.lock,
                text: 'Password Reset',
              ),
            ),
            GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedBack()),
                )
              },
              child: ProfileListItem(
                icon: LineAwesomeIcons.question_circle,
                text: 'Feedback',
              ),
            ),
            GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactUs()),
                )
              },
              child: ProfileListItem(
                icon: LineAwesomeIcons.phone,
                text: 'Contact Us',
              ),
            ),
            GestureDetector(
              onTap: () => {
                Share.share(
                    'Hey! Check out this new app Sanchari https://github.com/Sanchari4us/Sanchari',
                    subject: 'Sanchari app'),
              },
              child: ProfileListItem(
                icon: LineAwesomeIcons.user_plus,
                text: 'Invite a Friend',
              ),
            ),
            GestureDetector(
              onTap: () => {
                FirebaseAuth.instance.signOut(),
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Login()),
                    (Route<dynamic> route) => false)
              },
              child: ProfileListItem(
                icon: LineAwesomeIcons.alternate_sign_out,
                text: 'Logout',
                hasNavigation: false,
              ),
            ),
          ],
        ))
      ],
    ));
  }
}

class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool hasNavigation;

  const ProfileListItem({
    key,
    required this.icon,
    required this.text,
    this.hasNavigation = true,
  }) : super(key: key);

  // const ProfileListItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kSpacingUnit.w * 5.5,
      margin: EdgeInsets.symmetric(
        horizontal: kSpacingUnit.w * 4,
      ).copyWith(
        bottom: kSpacingUnit.w * 2,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: kSpacingUnit.w * 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kSpacingUnit.w * 3),
        color: Theme.of(context).backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 1.0,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(
            this.icon,
            size: kSpacingUnit.w * 2.5,
          ),
          SizedBox(width: kSpacingUnit.w * 1.5),
          Text(
            this.text,
            style: kTitleTextStyle.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          if (this.hasNavigation)
            Icon(
              LineAwesomeIcons.angle_right,
              size: kSpacingUnit.w * 2.5,
            ),
        ],
      ),
    );
  }
}
