import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_meter_apps/controller/trip.dart';

class TripHistoryRepository {
  static const _keyTripHistory = "trip_history";

  // Save trip history to SharedPreferences
  static Future<void> saveTrips(List<Trip> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final tripsJson = trips.map((trip) => trip.toJson()).toList();
    prefs.setString(_keyTripHistory, jsonEncode(tripsJson));
  }

  // Retrieve trip history from SharedPreferences
  static Future<List<Trip>> getTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripsString = prefs.getString(_keyTripHistory);
    if (tripsString == null) return [];
    final tripsJson = jsonDecode(tripsString) as List;
    return tripsJson.map((json) => Trip.fromJson(json)).toList();
  }
}
