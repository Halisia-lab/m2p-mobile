import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  static const String routeName = '/privacy_policy';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Politique de confidentialité'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Politique de confidentialité de Map2Place',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Informations collectées',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Lorsque vous utilisez l\'application Map2Place, nous collectons '
                  'votre emplacement géographique afin de vous fournir des '
                  'services de recherche de places de stationnement disponibles '
                  'dans votre région.',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Partage d\'informations',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Nous ne partageons pas vos informations personnelles avec des '
                  'tiers sans votre consentement. Cependant, nous pouvons '
                  'partager des données de localisation anonymisées et agrégées '
                  'avec nos partenaires commerciaux dans le but d\'améliorer '
                  'nos services.',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Sécurité des données',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Nous accordons une grande importance à la sécurité de vos '
                  'données. Nous mettons en place des mesures de sécurité '
                  'appropriées pour protéger vos informations personnelles '
                  'contre tout accès, toute divulgation ou toute utilisation '
                  'non autorisée.',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Modifications de la politique de confidentialité',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Nous nous réservons le droit de modifier cette politique de '
                  'confidentialité à tout moment. Toute modification sera '
                  'affichée sur cette page, et les utilisateurs seront informés '
                  'des changements importants par le biais de notifications '
                  'dans l\'application.',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
