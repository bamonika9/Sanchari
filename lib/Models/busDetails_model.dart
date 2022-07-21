import 'package:location/location.dart';

class BusDetail {
  bool? isActive;
  String? busNumber;
  LocationData? busLiveLocation;
  // LatLng busLiveLocation;
  List<String>? busStops;

  BusDetail({
    this.isActive,
    this.busNumber,
    this.busStops,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isActive'] = isActive;
    data['busNumber'] = busNumber;
    data['busLiveLocation'] = busLiveLocation;
    data['busStops'] = busStops;
    return data;
  }
}
