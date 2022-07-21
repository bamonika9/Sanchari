import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sanchari/Providers/qrCodeProvider.dart';
import 'package:sanchari/UI/busDetails.dart';
import 'package:scan/scan.dart';

// class Qrcode extends StatefulWidget {
//   Qrcode({Key? key}) : super(key: key);

//   @override
//   State<Qrcode> createState() => _QrcodeState();
// }

// class _QrcodeState extends State<Qrcode> {
//   ScanController controller = ScanController();
//   String qrcode = 'Unknown';

//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context);
//     return Container(
//       width: 250, // custom wrap size
//       height: 250,
//       child: ScanView(
//         controller: controller,

// // custom scan area, if set to 1.0, will scan full area
//         scanAreaScale: .7,
//         scanLineColor: Colors.green.shade400,
//         onCapture: (data) {
//           // context.read<QrcodeProvider>().changeContent(data);

//           print(data);
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => BusDetails()),
//           );
//           // do something
//         },
//       ),
//     );
//   }
// }

// ignore: must_be_immutable
class Qrcode extends StatelessWidget {
  ScanController controller = ScanController();
  String qrcode = 'Unknown';
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Container(
      width: 250, // custom wrap size
      height: 250,
      child: ScanView(
        controller: controller,

// custom scan area, if set to 1.0, will scan full area
        scanAreaScale: .7,
        scanLineColor: Colors.green.shade400,
        onCapture: (data) {
          QrcodeProvider().changeContent(data);
          print(data);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BusDetails()),
          );
          // do something
        },
      ),
    );
  }
}
