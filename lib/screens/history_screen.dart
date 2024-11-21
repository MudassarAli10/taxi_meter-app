import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          AppLocalizations.of(context)!.history,
          style:const TextStyle(color: Colors.white,fontFamily: 'Hellix'),
        ),
        backgroundColor: Colors.blue.shade600,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

      ),
      body: trips.isEmpty
          ?  Center(
        child: Text(AppLocalizations.of(context)!.noTripYet),
      )
          : ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Card(
            color: Colors.blue[500],
            margin: const EdgeInsets.all(8),
            child: ListTile(

              leading: const Icon(Icons.history, color: Colors.white,),
              title:  Text(
                AppLocalizations.of(context)!.recentTrip,
                style:  const TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Hellix', color: Colors.white,fontSize: 22),
              ),
              subtitle: Text(
                    "${AppLocalizations.of(context)!.time}: ${trip.duration.inMinutes} min\n"
                "Distance: ${trip.distance.toStringAsFixed(2)} km\n"
                    "${AppLocalizations.of(context)!.price}: ${trip.price.toStringAsFixed(2)} DH",style: const TextStyle(fontFamily: 'Hellix', color: Colors.white, fontSize: 20),
              ),
            ),
          );
        },
      ),
    );
  }
}
