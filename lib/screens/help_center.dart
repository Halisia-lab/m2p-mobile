import 'package:flutter/material.dart';

class HelpCenter extends StatelessWidget {
  const HelpCenter({Key? key}) : super(key: key);

  static const String routeName = '/help_center';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Centre d\'aide'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            _buildQuestion(
              'Foire aux questions',
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 16.0),
            _buildQuestion(
              'Comment utiliser Map2Place pour trouver une place de '
                  'stationnement ?',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            _buildAnswer(
              'Pour trouver une place de stationnement, ouvrez l\'application '
                  'Map2Place, autorisez l\'accès à votre localisation, puis '
                  'utilisez la fonction de recherche pour trouver les places '
                  'disponibles dans votre zone. Vous pouvez également filtrer '
                  'les résultats par critères tels que la distance, le prix, etc.',
            ),
            SizedBox(height: 16.0),
            _buildQuestion(
              'Est-ce que Map2Place fonctionne dans toutes les villes ?',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            _buildAnswer(
              'Map2Place est actuellement disponible uniquement à Paris, mais '
                  'la disponibilité des places de stationnement peut varier '
                  'en fonction de la localisation. Nous travaillons constamment'
                  ' pour étendre notre couverture et ajouter de nouvelles'
                  ' villes à notre base de données.',
            ),
            SizedBox(height: 16.0),
            _buildQuestion(
              'Comment puis-je signaler un problème ou faire une suggestion ?',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            _buildAnswer(
                'Si vous rencontrez un problème technique ou si vous avez une'
                    ' suggestion à nous faire, veuillez accéder à la section'
                    ' Aide de l\'application ou nous contacter par e-mail à'
                    ' support@map2place.com. Nous serons ravis de vous aider !',
            ),
            SizedBox(height: 16.0),
            _buildQuestion(
              'Est-ce que Map2Place propose des réservations de places de'
                  ' stationnement ?',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            _buildAnswer(
              'Actuellement, Map2Place ne propose pas de fonctionnalité de'
                  ' réservation de places de stationnement. Cependant, vous'
                  ' pouvez utiliser l\'application pour trouver des places'
                  ' disponibles en temps réel et obtenir des informations sur'
                  ' leur disponibilité et leur prix.',
            ),
            SizedBox(height: 16.0),
            _buildQuestion(
              'Comment se désabonner ?',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            _buildAnswer(
              'Le processus de désabonnement pour les abonnements effectués'
                  ' via Google Play Store est géré directement par Google. '
                  'Voici comment vous pouvez vous désabonner :',
            ),
            _buildAnswer(
              '- Sur votre appareil Android, ouvrez l\'application Google '
                  'Play Store.',
            ),
            _buildAnswer(
              '- Appuyez sur le menu hamburger (trois lignes horizontales) '
                  'en haut à gauche de l\'écran.',
            ),
            _buildAnswer(
              '- Sélectionnez "Abonnements".',
            ),
            _buildAnswer(
              '- Trouvez votre abonnement à Map2Place dans la liste et '
                  'appuyez dessus.',
            ),
            _buildAnswer(
              '- Appuyez sur "Annuler l\'abonnement" et suivez les'
                  ' instructions à l\'écran pour confirmer votre désabonnement.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(String question, {double fontSize = 16.0, FontWeight fontWeight = FontWeight.normal}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Text(
        question,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  Widget _buildAnswer(String answer) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        answer,
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
    );
  }
}
