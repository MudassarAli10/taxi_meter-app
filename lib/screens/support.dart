import 'package:flutter/material.dart';
import 'package:taxi_meter_apps/constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.support,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Hellix',
            fontSize: screenWidth * 0.06, // Responsive font size
          ),
        ),
        backgroundColor:primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Container(
          width: screenWidth * 0.9, // Responsive width
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.05), // Responsive border radius
          ),
          padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.014), // Responsive padding
                child: Text(
                  AppLocalizations.of(context)!.supportDes,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, // Responsive font size
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Hellix',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // Responsive spacing
              ElevatedButton(
                onPressed: () {
                  // Launch email app
                  launchUrl(
                    Uri(scheme: 'mailto', path: 'contact.lynaro@gmail.com'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03), // Responsive radius
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015, // Responsive button padding
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.supportEmail,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, // Responsive font size
                    color: Colors.white,
                    fontFamily: 'Hellix',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
