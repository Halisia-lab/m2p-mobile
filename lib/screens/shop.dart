import 'package:flutter/material.dart';

class Shop extends StatelessWidget {
  final int userScore;
  const Shop({super.key, required this.userScore});

  static const String routeName = '/shop';

  static void navigateTo(BuildContext context, int userScore) {
    Navigator.of(context).pushNamed(routeName, arguments: userScore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: RichText(
                text: TextSpan(
                  text: '$userScore ',
                  style: TextStyle(fontSize: 20.0),
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'La boutique n\'est pas encore disponible.',
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 10.0),
            Text(
              'A très vite pour utilisez vos Mappiz.',
              style: TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
