import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Testimonial {
  final String name;
  final int age;
  final String city;
  final String message;

  Testimonial({
    required this.name,
    required this.age,
    required this.city,
    required this.message,
  });
}

class TestimonialScreen extends StatelessWidget {
  final List<Testimonial> testimonials = [
    Testimonial(
      name: "James",
      age: 32,
      city: "Casablanca",
      message:
      "With the built-in meter, I can track the fare in real time. It really reassures me during my rides!",
    ),
    Testimonial(
      name: "Fatima",
      age: 27,
      city: "Marrakech",
      message:
      "Cette application est géniale ! Le compteur m’aide à éviter les mauvaises surprises sur le prix de ma course.",
    ),
    Testimonial(
      name: "Lucas",
      age: 38,
      city: "Rabat",
      message:
      "Le fait d'avoir un compteur dans l’application est un vrai plus. Je peux vérifier le montant et me sentir en sécurité.",
    ),
    Testimonial(
      name: "Amina",
      age: 24,
      city: "Agadir",
      message:
      "Je suis très contente d’utiliser cette app. Le compteur m’a permis de signaler un taxi qui essayait de me faire payer plus.",
    ),
    Testimonial(
      name: "Chloé",
      age: 29,
      city: "Tanger",
      message:
      "Le compteur intégré change tout ! Je peux prendre un taxi en toute confiance, sachant que je paie le prix juste.",
    ),
    Testimonial(
      name: "Omar",
      age: 22,
      city: "Fès",
      message:
      "Cette application oblige les chauffeurs à utiliser leur propre compteur, ce qui garantit que je paie le tarif juste à chaque fois.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.test,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Hellix',
            fontSize: screenWidth * 0.06, // Responsive font size
          ),
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
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        color: Colors.blue[500],
        child: ListView.builder(
          itemCount: testimonials.length,
          itemBuilder: (context, index) {
            final testimonial = testimonials[index];
            return Card(
              margin: EdgeInsets.symmetric(
                vertical: screenHeight * 0.015,
              ),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.person,
                          color: Colors.blue[600],
                          size: screenWidth * 0.08, // Responsive icon size
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          testimonial.name,
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Hellix',
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.blue[300],
                          size: screenWidth * 0.05,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          testimonial.city,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.blue[600],
                            fontFamily: 'Hellix',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      testimonial.message,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey[800],
                        height: 1.5,
                        fontFamily: 'Hellix',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
