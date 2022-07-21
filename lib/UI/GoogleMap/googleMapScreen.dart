import 'package:flutter/material.dart';
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
  late GoogleMapController mapController;
  // late BitmapDescriptor mapMarker;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

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

  // void setCustomMarker() async {
  //   mapMarker = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(), "assets/bus.png");
  // }

  @override
  void initState() {
    getCurrentLocation();
    // setCustomMarker();
    getPolyPoints();
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
                    infoWindow: InfoWindow(
                        title: "Source Location", snippet: "starting point")),
                Marker(
                    markerId: MarkerId("CurrentLocation"),
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    infoWindow: InfoWindow(
                        title: "Live Location", snippet: "Updated 10 min ago")),
                Marker(
                    markerId: MarkerId("BusLiveLocation"),
                    position: LatLng(widget.locLat, widget.locLong),
                    infoWindow: InfoWindow(
                        title: "Bus Live Location",
                        snippet: "Updated 10 min ago")),
                Marker(
                    markerId: MarkerId("Destination"),
                    position: _destinationLocation,
                    infoWindow: InfoWindow(
                        title: "Destination Location",
                        snippet: "Ending point")),
              },
            ),
    );
  }
}
