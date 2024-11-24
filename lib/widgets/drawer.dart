import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taxi_meter_apps/screens/history_screen.dart';
import 'package:taxi_meter_apps/screens/support.dart';
import 'package:taxi_meter_apps/screens/testimonial.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../screens/about_app.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Getting screen width and height for responsiveness
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Drawer(
      child: Container(
        color: Colors.blue[600], // Blue background color
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo Image - Responsive size
                  Image.asset(
                    'assets/logo/meter_logo1.png', // Replace with your logo
                    height: height * 0.2, // Adjust height based on screen height
                  ),
                ],
              ),
            ),
            // About Us - Responsive text size and padding
            ListTile(
              leading: const Icon(CupertinoIcons.info, color: Colors.white),
              title: Text(
                AppLocalizations.of(context)!.aboutus,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Hellix',
                    fontSize: width > 600 ? 18 : 16), // Adjust font size for small devices
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (contex) => const AboutUsScreen()));
              },
            ),
            // Testimonials - Same as above
            ListTile(
              leading: const Icon(CupertinoIcons.bolt, color: Colors.white),
              title: Text(
                AppLocalizations.of(context)!.test,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Hellix',
                    fontSize: width > 600 ? 18 : 16), // Adjust font size
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (contex) => TestimonialScreen()));
              },
            ),
            // History - Same as above
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white),
              title: Text(
                AppLocalizations.of(context)!.history,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Hellix',
                    fontSize: width > 600 ? 18 : 16),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (contex) => const HistoryScreen()));
              },
            ),
            // Support - Same as above
            ListTile(
              leading: const Icon(CupertinoIcons.hand_thumbsup_fill,
                  color: Colors.white),
              title: Text(
                AppLocalizations.of(context)!.support,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Hellix',
                    fontSize: width > 600 ? 18 : 16),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (contex) => const SupportScreen()));
              },
            ),
            // Subscription - Same as above

            // Instagram Link - Adjust the padding based on screen size
            Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                top: 280,
                bottom: height * 0.1, // Position it dynamically based on screen height
              ),
              child: ListTile(
                leading: Image.asset(
                  'assets/icon/instagram.png', // Instagram icon
                  height: 30,
                ),
                title: Text(
                  'Instagram',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width > 600 ? 20 : 18, // Adjust font size for smaller screens
                    fontFamily: 'Hellix',
                  ),
                ),
                onTap: () {
                  const link = 'https://www.instagram.com/lynaro.app/';
                  launchUrl(
                    Uri.parse(link),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
