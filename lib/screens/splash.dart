import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';

import 'login_or_register.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static const String routeName = '/splash';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSplashScreen.withScreenFunction(
        splash: 'images/logo.png',
        screenFunction: () async {
          return LoginOrRegister();
        },
        splashTransition: SplashTransition.scaleTransition,
        splashIconSize: 150,
      ),
    );
  }
}
