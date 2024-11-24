import 'dart:async';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../controller/trip.dart';
import '../controller/trip_repository.dart';

class GoogleMapActivity extends StatefulWidget {
  const GoogleMapActivity({super.key});

  @override
  State<GoogleMapActivity> createState() => _GoogleMapActivityState();
}

class _GoogleMapActivityState extends State<GoogleMapActivity> {
  late GoogleMapController mapController;

  // final LatLng _center = const LatLng(37.4223, -122.0848);
  LatLng _currentPosition = const LatLng(37.3861, -122.0839);
  LatLng? destinationLatLng; // Declare destinationLatLng here

  bool isPermissionGranted = false;
  final TextEditingController _destinationController = TextEditingController();

  List<LatLng> polylineCoordinates = [];
  late Polyline polyline;

  bool isLoading = false;
  bool isMeterRunning = false;
  bool showLocationFloatingButton = true; // Flag to control button visibility

  double totalDistance = 0.0; // Total distance in meters
  double basePrice = 0.0; // Base price set by user
  double totalPrice = 0.0; // Total calculated price
  Duration totalTime = Duration.zero; // Total trip duration

  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  //new
  Future<void> _startMeter() async {
    totalDistance = 0.0;
    totalTime = Duration.zero;
    totalPrice = basePrice;

    Position? lastPosition;

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      ),
    ).listen((Position position) {
      if (lastPosition != null) {
        double distance = Geolocator.distanceBetween(
          lastPosition!.latitude,
          lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        // Update distance and calculate price only if the car is moving
        if (position.speed > 0) {
          setState(() {
            totalDistance += distance;
            totalPrice =
                basePrice + (totalDistance / 1000) * 2.5; // e.g., 2.5 DH per km
            totalTime +=
                const Duration(seconds: 5); // Assuming updates every 5 seconds
          });
        }

        // Update the polyline
        _updatePolyline(position);
      }

      lastPosition = position;

      // Update the map camera
      mapController.animateCamera(CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ));
    });

    setState(() {
      isMeterRunning = true;
    });
  }

  void _stopMeter() async {
    positionStream?.cancel();
    setState(() {
      isMeterRunning = false;
    });

    // Create a new trip object
    final newTrip = Trip(
      distance: totalDistance / 1000, // in kilometers
      duration: totalTime,
      price: totalPrice,
    );

    // Save to shared preferences
    final trips = await TripHistoryRepository.getTrips();
    trips.insert(0, newTrip); // Add the new trip to the beginning of the list

    // Keep only the last 5 trips
    final updatedTrips = trips.take(5).toList();
    await TripHistoryRepository.saveTrips(updatedTrips);

    // Display Snackbar with results
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.blue[500],
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // Ensures content is spaced out
        children: [
          Expanded(
            child: Text(
              '${AppLocalizations.of(context)!.tripFinish}\n'
                  '${AppLocalizations.of(context)!.time}: ${totalTime
                  .inMinutes} min\n'
                  'Distance: ${(totalDistance / 1000).toStringAsFixed(2)} km\n'
                  '${AppLocalizations.of(context)!.price}: ${totalPrice
                  .toStringAsFixed(2)} DH',
              style: const TextStyle(
                  fontFamily: 'Hellix', color: Colors.white, fontSize: 20),
            ),
          ),
          TextButton(
            onPressed: () {
              // Dismiss the SnackBar when the close button is pressed
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              setState(() {
                // Hide the "Go to Live Location" button and show the "Play" button
                isPermissionGranted = true;
                polylineCoordinates.clear();
              });
            },
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      duration: const Duration(minutes: 25), // SnackBar won't auto-dismiss
    ));
  }
    void _showBasePriceDialog() {
    TextEditingController priceController = TextEditingController();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          // title: const Text("Set Base Price"),
          content: TextField(
            cursorColor: Colors.white,
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                CupertinoIcons.money_euro,
                color: Colors.white,
              ),
              hintText: AppLocalizations.of(context)!.basePrice,
              hintStyle:
                  const TextStyle(color: Colors.white, fontFamily: 'Hellix'),
              filled: true,
              fillColor: Colors.blue[600],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                onPressed: () {
                  setState(() {
                    basePrice = double.tryParse(priceController.text) ?? 0.0;
                    // Ensure the UI updates after setting the price
                    totalPrice =
                        basePrice; // Reset totalPrice after base price is set
                  });
                  Navigator.pop(context);
                },
                child:  Text(
                  AppLocalizations.of(context)!.setPrice,
                  style:const TextStyle(color: Colors.white, fontFamily: 'Hellix'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updatePolyline(Position position) {
    if (polylineCoordinates.isEmpty) return;

    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    // Remove the coordinates the user has passed
    while (polylineCoordinates.isNotEmpty) {
      double distance = Geolocator.distanceBetween(
        currentLatLng.latitude,
        currentLatLng.longitude,
        polylineCoordinates.first.latitude,
        polylineCoordinates.first.longitude,
      );

      if (distance < 10) {
        // If the first point is within 10 meters, remove it
        polylineCoordinates.removeAt(0);
      } else {
        break;
      }
    }

    setState(() {
      polyline = Polyline(
        polylineId: const PolylineId("route"),
        points: polylineCoordinates,
        color: Colors.blue,
        width: 5,
      );
    });
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
      barrierDismissible: false,
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
                    apiKey: 'AIzaSyBZPNNxjrwEruh44L0o5oAMHQMuaiz-N_4',
                    // Use your actual API key
                    components: [const Component(Component.country, 'ma')],
                    language: 'fr',
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
                hintText: AppLocalizations.of(context)!.destination,
                hintStyle:
                    const TextStyle(color: Colors.white, fontFamily: 'Hellix'),
                filled: true,
                fillColor: Colors.blue[600],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                onPressed: () {
                  String destination = _destinationController.text;
                  if (destination.isNotEmpty) {
                    _getRoute(
                        destination); // Pass the destination text to _getRoute
                  } else {
                    print("Please enter a destination.");
                  }

                  Navigator.pop(context);
                  _showBasePriceDialog();
                },
                child:  Text(
                  AppLocalizations.of(context)!.route,
                  style:const TextStyle(color: Colors.white, fontFamily: 'Hellix'),
                ),
              ),
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
            initialCameraPosition:
                CameraPosition(target: _currentPosition, zoom: 13),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: {
              // Marker(
              //   markerId: const MarkerId('currentLocation'),
              //   position: _currentPosition,
              // ),
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
          if (isMeterRunning)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.blue[600],
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${AppLocalizations.of(context)!.time}: ${totalTime.inMinutes} min", style: const TextStyle(
                          fontFamily: 'Hellix',
                          color: Colors.white,
                          fontSize: 20)),
                      Text(
                          "Distance: ${(totalDistance / 1000).toStringAsFixed(2)} km", style: const TextStyle(
                          fontFamily: 'Hellix',
                          color: Colors.white,
                          fontSize: 20)),
                      Text(
                        "${AppLocalizations.of(context)!.price}: ${totalPrice.toStringAsFixed(2)} DH",
                        style: const TextStyle(
                            fontFamily: 'Hellix',
                            color: Colors.white,
                            fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: isPermissionGranted
          ? FloatingActionButton(
              backgroundColor: Colors.blue[400],
              onPressed: () {
                _getCurrentLocation();
                setState(() {
                  // Hide the "Go to Live Location" button and show the "Play" button
                  isPermissionGranted = false;
                });
              },
              child: const Icon(Icons.my_location, color: Colors.white),
            )
          : FloatingActionButton(
        backgroundColor: Colors.blue[400],
              onPressed: isMeterRunning ? _stopMeter : _startMeter,
              child: Icon(isMeterRunning ? Icons.stop : Icons.play_arrow ,color: Colors.white,),
            ),
    );
  }
}
