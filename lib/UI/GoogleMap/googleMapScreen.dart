import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sanchari/constants.dart';

class GoogleMapScreen extends StatefulWidget {
  final double locLat;
  final double locLong;
  const GoogleMapScreen({Key? key, required this.locLat, required this.locLong})
      : super(key: key);

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late BitmapDescriptor customIcon;
  late GoogleMapController mapController;
  late BitmapDescriptor sourceMarker, destinationMarker, userMarker, busMarker;
  late Uint8List markerIcon;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Uint8List? markerImage;
  List<String> images = [
    "assets/bus-stop.png",
    "assets/destination.png",
    "assets/souce.png",
    "assets/user.png"
  ];

  static const LatLng _sourceLocation = LatLng(13.0097956, 76.1196002);
  static const LatLng _destinationLocation = LatLng(12.9839, 76.2181);
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  void getCurrentLocation() {
    Location location = Location();
    location.getLocation().then((location) {
      currentLocation = location;
    });

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      setState(() {
        currentLocation = newLoc;
      });
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        PointLatLng(_sourceLocation.latitude, _sourceLocation.longitude),
        PointLatLng(
            _destinationLocation.latitude, _destinationLocation.longitude));

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) =>
          polylineCoordinates.add(LatLng(point.latitude, point.longitude)));

      setState(() {});
    }
  }

  void setCustomMarker() async {
    sourceMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "assets/source.png");
    destinationMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "assets/destination.png");
    userMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "assets/user.png");
    busMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "assets/bus-stop.png");
    setState(() {});
  }

// make sure to initialize before map loading

  // getIcons() async {
  //   BitmapIcon = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(size: Size(16, 16)), 'assets/user.png');
  //   var icon = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(devicePixelRatio: 2.2, size: ui.Size(16, 16)),
  //       "assets/bus-stop.png");
  //   setState(() {
  //     this.icon = icon;
  //   });
  // }

  @override
  void initState() {
    getCurrentLocation();
    getPolyPoints();
    // getIcons();
    setCustomMarker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? Center(child: Text("Loading"))
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 11),
              polylines: {
                Polyline(
                    polylineId: PolylineId("route"),
                    points: polylineCoordinates,
                    color: Colors.blue,
                    width: 6),
              },
              markers: {
                Marker(
                    markerId: MarkerId("Source"),
                    position: _sourceLocation,
                    // icon: sourceMarker,
                    infoWindow: InfoWindow(
                        title: "Source Location", snippet: "starting point")),
                Marker(
                    markerId: MarkerId("CurrentLocation"),
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    // icon: userMarker,
                    infoWindow: InfoWindow(
                        title: "Live Location",
                        snippet: "Updated few seconds ago")),
                Marker(
                    markerId: MarkerId("BusLiveLocation"),
                    position: LatLng(widget.locLat, widget.locLong),
                    icon: busMarker,
                    infoWindow: InfoWindow(
                        title: "Bus Live Location",
                        snippet: "Updated 10 min ago")),
                Marker(
                    markerId: MarkerId("Destination"),
                    position: _destinationLocation,
                    // icon: destinationMarker,
                    infoWindow: InfoWindow(
                        title: "Destination Location",
                        snippet: "Ending point")),
              },
            ),
    );
  }
}
