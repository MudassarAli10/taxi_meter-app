class Trip {
  final double distance; // in kilometers
  final Duration duration;
  final double price;
  final int elapsedTime; // Add elapsedTime in seconds

  Trip({
    required this.distance,
    required this.duration,
    required this.price,
    required this.elapsedTime,
  });

  // Convert Trip object to JSON
  Map<String, dynamic> toJson() => {
    'distance': distance,
    'duration': duration.inSeconds,
    'price': price,
    'elapsedTime': elapsedTime,
  };

  // Create Trip object from JSON
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      distance: json['distance'],
      duration: Duration(seconds: json['duration']),
      price: json['price'],
      elapsedTime: json['elapsedTime'] ?? 0, // Default to 0 if not present
    );
  }
}
