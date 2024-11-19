import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.blue,

      appBar: AppBar(
        title:  Text(
          AppLocalizations.of(context)!.aboutus,
          style: const TextStyle(color: Colors.white,fontFamily: 'Hellix'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center(
            //   child: Image.asset(
            //     'assets/lynaro_logo.png', // Make sure to add your app logo here
            //     height: 100,
            //   ),
            // ),
            const SizedBox(height: 20),
             Text(
              AppLocalizations.of(context)!.story,
              style:const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                  fontFamily: 'Hellix'
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Text(
                AppLocalizations.of(context)!.ourStory
                ,style: const TextStyle(fontSize: 16, height: 1.5,color: Colors.white,fontFamily: 'Hellix'),
              ),
            ),
            const SizedBox(height: 20),
             Text(
              AppLocalizations.of(context)!.mission,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                  fontFamily: 'Hellix'
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Text(
                AppLocalizations.of(context)!.ourMission
                ,style: const TextStyle(fontSize: 16, height: 1.5,color: Colors.white,fontFamily: 'Hellix'),
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[400]),
            const SizedBox(height: 20),
             Text(
               AppLocalizations.of(context)!.use,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                  fontFamily: 'Hellix'
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Text(
                AppLocalizations.of(context)!.useto,
                style: const TextStyle(fontSize: 16, height: 1.5,color: Colors.white,fontFamily: 'Hellix'),
              ),
            ),
            const SizedBox(height: 40),

          ],
        ),
      ),
    );
  }}