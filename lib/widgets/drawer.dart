import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                  // Optional logo image can be added here
                  Image.asset(
                    'assets/logo/meter_logo1.png', // Replace with your logo
                    height: 200,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.info, color: Colors.white),
              title:
                   Text(AppLocalizations.of(context)!.aboutus, style:const TextStyle(color: Colors.white,fontFamily: 'Hellix',fontSize: 18)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (contex) => const AboutUsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.bolt, color: Colors.white),
              title:  Text(AppLocalizations.of(context)!.test,
                  style:const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (contex) => TestimonialScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white),
              title:  Text(AppLocalizations.of(context)!.history,
                  style: const TextStyle(color: Colors.white,fontFamily: 'Hellix',fontSize: 18)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.hand_thumbsup_fill,
                  color: Colors.white),
              title:
                   Text(AppLocalizations.of(context)!.support, style: const TextStyle(color: Colors.white,fontFamily: 'Hellix',fontSize: 18)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (contex) => const SupportScreen()));
              },
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0,
                  bottom: 16.0,
                  top: 300), // Position at bottom-left
              child: ListTile(
                leading: Image.asset(
                  'assets/icon/instagram.png', // Replace with your logo
                  height: 30,
                ), // Instagram icon
                title: const Text('Instagram',
                    style: TextStyle(color: Colors.white, fontSize: 20,fontFamily: 'Hellix')),
                onTap: () {
                  const link = 'https://www.instagram.com/lynaro.app/';
                  launchUrl(
                    Uri.parse(link),
                    mode: LaunchMode.externalApplication,
                  );
                }, // Open Instagram on tap
              ),
            ),
          ],
        ),
      ),
    );
  }
}
