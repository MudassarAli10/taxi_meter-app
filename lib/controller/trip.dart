
class Trip {
  final double distance; // in kilometers
  final Duration duration;
  final double price;

  Trip({required this.distance, required this.duration, required this.price});

  // Convert Trip object to JSON
  Map<String, dynamic> toJson() => {
    'distance': distance,
    'duration': duration.inSeconds,
    'price': price,
  };

  // Create Trip object from JSON
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      distance: json['distance'],
      duration: Duration(seconds: json['duration']),
      price: json['price'],
    );
  }
}
