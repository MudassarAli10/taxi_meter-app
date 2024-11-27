import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  SubscriptionScreenState createState() => SubscriptionScreenState();
}

class SubscriptionScreenState extends State<SubscriptionScreen> {
  String selectedPlan = 'Annual'; // Default selected plan

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to determine screen size
    double screenWidth = MediaQuery.of(context).size.width;
   // double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth * 0.9, // Adjust based on screen size
            padding: EdgeInsets.all(screenWidth * 0.05), // Dynamic padding
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title with dynamic font size
                Text(
                  AppLocalizations.of(context)!.chooseYourPackage,
                  style: TextStyle(
                    fontSize: screenWidth * 0.06, // Adjust font size based on screen width
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Hellix',
                  ),
                ),
                const SizedBox(height: 20),
                // Annual subscription option
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPlan = 'Annual';
                    });
                  },
                  child: SubscriptionOption(
                    title: AppLocalizations.of(context)!.annual,
                    description1: "${AppLocalizations.of(context)!.saveUpto} 50%",
                    description2: AppLocalizations.of(context)!.flexiblePayment,
                    price: "€25.99/an",
                    crossedPrice: "€49.99/an",
                    gradientColors: selectedPlan == 'Annual'
                        ? [const Color(0xff62cff4), const Color(0xff2c67f2)]
                        : [Colors.grey[200]!, Colors.grey[300]!],
                    isSelected: selectedPlan == 'Annual',
                    icon: Icons.payment,
                    icon1: Icons.payments_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                // Monthly subscription option
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPlan = 'Monthly';
                    });
                  },
                  child: SubscriptionOption(
                    title: AppLocalizations.of(context)!.monthly,
                    description1: "${AppLocalizations.of(context)!.saveUpto} 40%",
                    description2: AppLocalizations.of(context)!.flexiblePayment,
                    price: "€2.99/mon",
                    crossedPrice: "€4.99/mon",
                    gradientColors: selectedPlan == 'Monthly'
                        ? [const Color(0xff62cff4), const Color(0xff2c67f2)]
                        : [Colors.grey[200]!, Colors.grey[300]!],
                    isSelected: selectedPlan == 'Monthly',
                    icon: Icons.payment,
                    icon1: Icons.payments_outlined,
                  ),
                ),
                const SizedBox(height: 20),
                // Subscribe button with dynamic width and padding
                ElevatedButton(
                  onPressed: () {
                    // Handle subscription logic
                    log("Selected Plan: $selectedPlan");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[500],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(screenWidth * 0.8, 50), // Dynamic size
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.subscribe,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, // Dynamic font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Hellix',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubscriptionOption extends StatelessWidget {
  final String title;
  final String description1;
  final String description2;
  final String price;
  final String crossedPrice;
  final List<Color> gradientColors;
  final bool isSelected;
  final IconData icon;
  final IconData icon1;

  const SubscriptionOption({
    super.key,
    required this.title,
    required this.description1,
    required this.description2,
    required this.price,
    required this.crossedPrice,
    required this.gradientColors,
    required this.isSelected,
    required this.icon,
    required this.icon1,
  });

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to adjust font size and padding based on screen size
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03), // Dynamic padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Plan Title and Description with dynamic font size
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, // Adjust font size based on screen width
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Hellix',
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description1,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035, // Dynamic font size
                    color: isSelected ? Colors.white : Colors.black,
                    fontFamily: 'Hellix',
                  ),
                ),
                Text(
                  description2,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035, // Dynamic font size
                    color: isSelected ? Colors.white : Colors.black,
                    fontFamily: 'Hellix',
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      icon1,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Plan Price with dynamic font size
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                crossedPrice,
                style: TextStyle(
                  fontSize: screenWidth * 0.035, // Dynamic font size
                  fontFamily: 'Hellix',
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : Colors.black.withOpacity(0.6),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: screenWidth * 0.06, // Dynamic font size
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                  fontFamily: 'Hellix',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
