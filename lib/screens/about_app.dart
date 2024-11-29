import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taxi_meter_apps/constant.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.aboutus,
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              Text(
                AppLocalizations.of(context)!.story,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Hellix',
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Text(
                  AppLocalizations.of(context)!.ourStory,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    height: 1.5,
                    color: Colors.white,
                    fontFamily: 'Hellix',
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                AppLocalizations.of(context)!.mission,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Hellix',
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Text(
                  AppLocalizations.of(context)!.ourMission,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    height: 1.5,
                    color: Colors.white,
                    fontFamily: 'Hellix',
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Divider(color: Colors.grey[400]),
              SizedBox(height: screenHeight * 0.02),
              Text(
                AppLocalizations.of(context)!.use,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Hellix',
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Text(
                  AppLocalizations.of(context)!.useto,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    height: 1.5,
                    color: Colors.white,
                    fontFamily: 'Hellix',
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
