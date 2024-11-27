import 'package:flutter/material.dart';
import '../constant.dart';
import '../controller/trip.dart';
import '../controller/trip_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Trip> trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final loadedTrips = await TripHistoryRepository.getTrips();
    setState(() {
      trips = loadedTrips;
    });
  }
  String _formatElapsedTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "${minutes}m ${remainingSeconds}s";
  }


  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.history,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Hellix',
            fontSize: screenWidth * 0.06, // Responsive font size
          ),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: trips.isEmpty
            ? Center(
          child: Text(
            AppLocalizations.of(context)!.noTripYet,
            style: TextStyle(
              fontSize: screenWidth * 0.045, // Responsive text size
              fontFamily: 'Hellix',
            ),
          ),
        )
            : ListView.builder(
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];

            return Card(
              color: primaryColor,
              margin: EdgeInsets.all(screenWidth * 0.03), // Responsive margin
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Stack(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.history,
                        color: Colors.white,
                        size: screenWidth * 0.08, // Responsive icon size
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.recentTrip,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Hellix',
                          color: Colors.white,
                          fontSize: screenWidth * 0.05, // Responsive text size
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.01),
                        child: Text(
                         // "${AppLocalizations.of(context)!.time}: ${trip.duration.inMinutes} min\n"
                              "${AppLocalizations.of(context)!.time}: ${_formatElapsedTime(trip.elapsedTime)}\n" // Add this
                              "Distance: ${trip.distance.toStringAsFixed(2)} km\n"
                              "${AppLocalizations.of(context)!.price}: ${trip.price.toStringAsFixed(2)} DH",
                          style: TextStyle(
                            fontFamily: 'Hellix',
                            color: Colors.white,
                            fontSize: screenWidth * 0.05, // Responsive text size
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Date at the top-right of the card

                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
