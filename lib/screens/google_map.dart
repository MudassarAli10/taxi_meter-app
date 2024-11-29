import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:taxi_meter_apps/constant.dart';

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
  bool showInitialButton = true;
 // Timer? _timer;
  Timer? _stopwatchTimer;
  int elapsedSeconds = 0;

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
  void _startTimer() {
    // Reset elapsed time
    elapsedSeconds = 0;

    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }
  void _stopTimer() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = null;
  }
  //new
  Future<void> _startMeter() async {
    totalDistance = 0.0;
    totalTime = Duration.zero;
    totalPrice = basePrice;
    // Start the timer
    _startTimer();
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
                basePrice + (totalDistance / 1000) * 10.5; // e.g., 2.5 DH per km
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
    // Stop the timer
    _stopTimer();

    positionStream?.cancel();

    // Store the necessary variables locally to avoid async gap issues
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context);

    setState(() {
      isMeterRunning = false;
    });

    // Create a new trip object
    final newTrip = Trip(
      distance: totalDistance / 1000, // in kilometers
      duration: totalTime,
      price: totalPrice,
      elapsedTime: elapsedSeconds, // Add elapsed time
    );

    // Save to shared preferences
    final trips = await TripHistoryRepository.getTrips();
    trips.insert(0, newTrip); // Add the new trip to the beginning of the list

    // Keep only the last 5 trips
    final updatedTrips = trips.take(5).toList();
    await TripHistoryRepository.saveTrips(updatedTrips);

    // Display Snack bar with results
    scaffoldMessenger.showSnackBar(
      SnackBar(
        backgroundColor: primaryColor,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${localizations!.tripFinish}\n'
                    '${localizations.time}: ${elapsedSeconds ~/ 60} min ${elapsedSeconds % 60} sec\n' // Timer result
                    'Distance: ${(totalDistance / 1000).toStringAsFixed(2)} km\n'
                    '${localizations.price}: ${totalPrice.toStringAsFixed(2)} DH',
                style: const TextStyle(
                  fontFamily: 'Hellix',
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Dismiss the SnackBar when the close button is pressed
                scaffoldMessenger.hideCurrentSnackBar();
                setState(() {
                  // Reset state variables or perform cleanup as needed
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
        duration: const Duration(minutes: 1000),
      ),
    );
  }


  void _showBasePriceDialog() {
    TextEditingController priceController = TextEditingController();
    String? errorMessage; // To store the validation error message

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    cursorColor: Colors.white,
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.payments_outlined,
                        color: Colors.white,
                      ),
                      hintText: AppLocalizations.of(context)!.basePrice,
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Hellix',
                      ),
                      filled: true,
                      fillColor: primaryColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      errorText: errorMessage, // Show validation error
                    ),
                    onChanged: (value) {
                      // Validate the input and update the error message
                      setState(() {
                        if (value.isEmpty || !RegExp(r'^[0-9]*\.?[0-9]*$').hasMatch(value)) {
                          errorMessage = AppLocalizations.of(context)!.errorMessage;
                        } else {
                          errorMessage = null; // Clear error for valid input
                        }
                      });
                    },
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (errorMessage != null || priceController.text.isEmpty) {
                        setState(() {
                          errorMessage = "Please enter a valid price\n (e.g., 1.70, 2.00).";
                        });
                        return; // Prevent closing the dialog if invalid
                      }

                      setState(() {
                        basePrice = double.tryParse(priceController.text) ?? 0.0;
                        totalPrice = basePrice; // Reset totalPrice after base price is set
                      });
                      Navigator.pop(context); // Close the dialog on valid input
                    },
                    child: Text(
                      AppLocalizations.of(context)!.setPrice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Hellix',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
        color: primaryColor,
        width: 5,
      );
    });
  }

  Future<void> _requestPermission() async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isGranted) {
      setState(() {
        isPermissionGranted = true;
      });
    //  _getCurrentLocation(); // Immediately fetch location after permission is granted
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
      log("Error getting location: $e");
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
              style: const TextStyle(color: Colors.white),
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
                  log("Error in autocomplete: $e");
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
                fillColor: primaryColor,

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
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                onPressed: () {
                  String destination = _destinationController.text;
                  if (destination.isNotEmpty) {
                    _getRoute(
                        destination); // Pass the destination text to _getRoute
                  } else {
                    log("Please enter a destination.");
                  }

                  Navigator.pop(context);
                  _showBasePriceDialog();
                },
                child: Text(
                  AppLocalizations.of(context)!.route,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Hellix'),
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
            color: primaryColor,
            width: 5,
          );
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error Fetching Route: $e');
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
    // Get screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define a scaling factor for text and padding
    final scaleFactor = screenWidth / 375; // Base width is 375 (common width for a standard phone)
    final paddingScaleFactor = screenHeight / 812; // Base height is 812 (standard for iPhone X)

    return Scaffold(
      body: Stack(
        children: [
          // Google Map widget
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition:
            CameraPosition(target: _currentPosition, zoom: 13),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: {
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

          // Show initial text button in the center of the screen
          if (showInitialButton)
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(
                    vertical: 16 * paddingScaleFactor,
                    horizontal: 32 * paddingScaleFactor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _getCurrentLocation();
                  setState(() {
                    // Hide initial button and show other actions
                    showInitialButton = false;
                    isPermissionGranted = false;
                  });
                },
                child: Text(
                  AppLocalizations.of(context)!.whereAreYouGoing,
                  style: TextStyle(
                    fontFamily: 'Hellix',
                    fontSize: 17 * scaleFactor,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Show the meter card and floating button only when the initial button is clicked
          if (!showInitialButton) ...[
            if (isMeterRunning)
              Positioned(
                bottom: 16 * paddingScaleFactor,
                left: 16 * paddingScaleFactor,
                right: 16 * paddingScaleFactor,
                child: Card(
                  color: primaryColor,
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16 * paddingScaleFactor),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.time}: ${elapsedSeconds ~/ 60} min ${elapsedSeconds % 60} sec",
                          style: TextStyle(
                            fontFamily: 'Hellix',
                            color: Colors.white,
                            fontSize: 20 * scaleFactor,
                          ),
                        ),
                        Text(
                          "Distance: ${(totalDistance / 1000).toStringAsFixed(2)} km",
                          style: TextStyle(
                            fontFamily: 'Hellix',
                            color: Colors.white,
                            fontSize: 20 * scaleFactor,
                          ),
                        ),
                        Text(
                          "${AppLocalizations.of(context)!.price}: ${totalPrice.toStringAsFixed(2)} DH",
                          style: TextStyle(
                            fontFamily: 'Hellix',
                            color: Colors.white,
                            fontSize: 20 * scaleFactor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),

      // Floating action button logic
      floatingActionButton: !showInitialButton
          ? (isPermissionGranted
          ? FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          _getCurrentLocation();
          setState(() {
            isPermissionGranted = false;
          });
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      )
          : FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: isMeterRunning ? _stopMeter : _startMeter,
        child: Icon(
          isMeterRunning ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
        ),
      ))
          : null, // No floating button initially
    );
  }
}