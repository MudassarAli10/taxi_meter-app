import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constant.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // FAQ items
    final List<FAQItem> faqItems = [
      FAQItem(
        question: AppLocalizations.of(context)!.whatIsLynaro,
        answer: AppLocalizations.of(context)!.whatIsLynaroAnswer,
      ),
      FAQItem(
        question: AppLocalizations.of(context)!.howDoesTheLynaro,
        answer: AppLocalizations.of(context)!.howDoesTheLynaroAnswer,
      ),
      FAQItem(
        question: AppLocalizations.of(context)!.whatIsTheBaseMeterPrice,
        answer: AppLocalizations.of(context)!.whatIsTheBaseMeterPriceAnswer,
      ),
      FAQItem(
        question: AppLocalizations.of(context)!.whatHappensUsingLynaro,
        answer: AppLocalizations.of(context)!.whatHappensUsingLynaroAnswer,
      ),
      FAQItem(
        question: AppLocalizations.of(context)!.isLynaroAvailableInAllCities,
        answer: AppLocalizations.of(context)!.isLynaroAvailableInAllCitiesAnswer,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'FAQ',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Hellix',
            fontSize: screenWidth * 0.06, // Responsive font size
          ),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
            size: screenWidth * 0.06, // Responsive icon size
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
          itemCount: faqItems.length,
          itemBuilder: (context, index) {
            return FAQTile(
              question: faqItems[index].question,
              answer: faqItems[index].answer,
            );
          },
        ),
      ),
    );
  }
}

class FAQTile extends StatefulWidget {
  final String question;
  final String answer;

  const FAQTile({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  _FAQTileState createState() => _FAQTileState();
}

class _FAQTileState extends State<FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02), // Responsive spacing
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03), // Responsive corner radius
        ),
        color: _isExpanded ? primaryColor : Colors.white,
        elevation: 4,
        child: Column(
          children: [
            ListTile(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              leading: Icon(
                _isExpanded
                    ? CupertinoIcons.chevron_down
                    : CupertinoIcons.chevron_right,
                color: _isExpanded ? Colors.white : primaryColor,
                size: screenWidth * 0.06, // Responsive icon size
              ),
              title: Text(
                widget.question,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045, // Responsive font size
                  fontFamily: 'Hellix',
                  color: _isExpanded ? Colors.white : primaryColor,
                ),
              ),
              trailing: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: _isExpanded ? Colors.white : primaryColor,
                size: screenWidth * 0.06, // Responsive icon size
              ),
            ),
            if (_isExpanded)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, // Responsive padding
                  vertical: screenWidth * 0.03,
                ),
                child: Text(
                  widget.answer,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // Responsive font size
                    color: Colors.white,
                    height: 1.5,
                    fontFamily: 'Hellix',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
