import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_meter_apps/controller/language_change_controller.dart';
import 'package:taxi_meter_apps/screens/google_map.dart';
import 'package:taxi_meter_apps/widgets/drawer.dart';

enum Language { english, french }

class HomeScreen extends StatelessWidget {
  // Define a GlobalKey for the Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey, // Assign the key to Scaffold
      appBar: AppBar(
        backgroundColor: const Color(0xff1d366f),
        centerTitle: true,
        title:  Text(
          'Lynaro',
          style: TextStyle(color: Colors.white, fontFamily: 'Hellix',  fontSize: screenWidth * 0.07,),
        ),
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.line_horizontal_3,
            size: 32,
            color: Colors.white,
          ),
          onPressed: () {
            // Use the key to open the drawer
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          Consumer<LanguageChangeController>(
              builder: (context, provider, child) {
            return PopupMenuButton(
                color: Colors.white,
                icon: const Icon(
                  CupertinoIcons.globe, // Use the globe icon
                  color: Colors.white,
                  size: 25,
                ),
                onSelected: (Language item) {
                  if (Language.english.name == item.name) {
                    provider.changeLanguage(const Locale('en'));
                  } else {
                    provider.changeLanguage(const Locale('fr'));
                  }
                },
                itemBuilder: (BuildContext contex) =>
                    <PopupMenuEntry<Language>>[
                      PopupMenuItem(
                        value: Language.english,
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icon/usa.png', // Path to English flag image
                              width: 24,
                              height: 16,
                            ),
                            const SizedBox(width: 10),
                            const Text('English'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: Language.french,
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icon/france.png', // Path to French flag image
                              width: 24,
                              height: 16,
                            ),
                            const SizedBox(width: 10),
                            const Text('French'),
                          ],
                        ),
                      ),
                    ]);
          })
        ],
      ),
      drawer: const DrawerWidget(),
      body: const GoogleMapActivity(),
    );
  }
}
