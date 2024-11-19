import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class GoogleMapActivity extends StatefulWidget {
  const GoogleMapActivity({super.key});

  @override
  State<GoogleMapActivity> createState() => _GoogleMapActivityState();
}

class _GoogleMapActivityState extends State<GoogleMapActivity> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(37.4223, -122.0848);
  LatLng _currentPosition = const LatLng(37.3861, -122.0839);
  LatLng? destinationLatLng;  // Declare destinationLatLng here

  bool isPermissionGranted = false;
  final TextEditingController _destinationController = TextEditingController();

  List<LatLng> polylineCoordinates = [];
  late Polyline polyline;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      await Permission.location.request();
    }

    if (await Permission.location.isGranted) {
      setState(() {
        isPermissionGranted = true;
      });
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      LatLng newPosition = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = newPosition;

        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 15),
        ));

        _showLocationInputDialog();
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _showLocationInputDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              cursorColor: Colors.white,
              controller: _destinationController,
              onTap: () async {
                try {
                  Prediction? prediction = await PlacesAutocomplete.show(
                    context: context,
                    apiKey: 'AIzaSyBZPNNxjrwEruh44L0o5oAMHQMuaiz-N_4', // Use your actual API key
                    components: [const Component(Component.country, 'pk')],
                    language: 'en',
                  );

                  if (prediction != null) {
                    _destinationController.text = prediction.description!;
                    _getRoute(prediction.description!);
                  }
                } catch (e) {
                  print("Error in autocomplete: $e");
                }
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  CupertinoIcons.location,
                  color: Colors.white,
                ),
                hintText: "Enter your destination",
                filled: true,
                fillColor: Colors.blue[600],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String destination = _destinationController.text;
                if (destination.isNotEmpty) {
                  _getRoute(destination); // Pass the destination text to _getRoute
                } else {
                  print("Please enter a destination.");
                }

                Navigator.pop(context);
              },

              child: const Text('Search Place'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getRoute(String destination) async {
    try {
      final geocodeUrl =
          "https://maps.googleapis.com/maps/api/geocode/json?address=$destination&key=AIzaSyBZPNNxjrwEruh44L0o5oAMHQMuaiz-N_4"; // Use your actual API key
      final geocodeResponse = await http.get(Uri.parse(geocodeUrl));
      final geocodeData = json.decode(geocodeResponse.body);
      destinationLatLng = LatLng(
        geocodeData["results"][0]["geometry"]["location"]["lat"],
        geocodeData["results"][0]["geometry"]["location"]["lng"],
      );

      final directionsUrl =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition.latitude},${_currentPosition.longitude}&destination=${destinationLatLng!.latitude},${destinationLatLng!.longitude}&key=AIzaSyBZPNNxjrwEruh44L0o5oAMHQMuaiz-N_4"; // Use your actual API key
      final response = await http.get(Uri.parse(directionsUrl));
      final data = json.decode(response.body);

      if (data["routes"].isNotEmpty) {
        final points = data["routes"][0]["overview_polyline"]["points"];
        final decodedPoints = _decodePolyline(points);

        setState(() {
          polylineCoordinates = decodedPoints;
          polyline = Polyline(
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          );
        });
      }
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 13),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: _currentPosition,
              ),
              if (destinationLatLng != null)
                Marker(
                  markerId: const MarkerId('destination'),
                  position: destinationLatLng!,
                  infoWindow: const InfoWindow(title: "Destination"),
                ),
            },
            polylines: {
              if (polylineCoordinates.isNotEmpty) polyline,
            },
          ),
        ],
      ),
      floatingActionButton: isPermissionGranted
          ? FloatingActionButton(
        backgroundColor: Colors.blue[400],
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location, color: Colors.white),
      )
          : null,
    );
  }
}
