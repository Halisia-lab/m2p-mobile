import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

class LocationDisabled extends StatelessWidget {
  static const String routeName = '/missing-location';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const LocationDisabled({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Localisation requise",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(
                height: 50,
              ),
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: Image.asset(
                      "images/lost-icon.jpeg",
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                "Map 2 Place a besoin de votre position précise pour vous donner des instructions détaillées. ",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Veuillez configurer votre appareil.",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  OutlinedButton(
                    style: Theme.of(context).filledButtonTheme.style,
                    onPressed: () {
                      //  setState(() {});
                      AppSettings.openLocationSettings();
                    },
                    child: Text(
                      "Paramètres",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
