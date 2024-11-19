
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title:  Text(
          AppLocalizations.of(context)!.support,
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
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  AppLocalizations.of(context)!.supportDes,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                      fontFamily: 'Hellix'
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add your submit action her
                  launchUrl(
                    Uri(scheme: 'mailto' , path: 'contact.lynaro@gmail.com'),
                    mode: LaunchMode.externalApplication
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:  Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    AppLocalizations.of(context)!.supportEmail,
                    style: TextStyle(fontSize: 18, color: Colors.white,fontFamily: 'Hellix'),
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
