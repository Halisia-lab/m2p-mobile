import 'package:flutter/material.dart';

import '../screens/login.dart';
import '../screens/register_first.dart';

class LoginOrRegister extends StatelessWidget {
  const LoginOrRegister({Key? key}) : super(key: key);

  static const String routeName = '/login-or-register';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "images/logo.png",
              height: 150,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: OutlinedButton(
                    style: Theme.of(context).outlinedButtonTheme.style,
                    onPressed: () {
                      Login.navigateTo(context);
                    },
                    child: Text(
                      "connexion".toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: ElevatedButton(
                    style: Theme.of(context).filledButtonTheme.style,
                    onPressed: () {
                      RegisterFirst.navigateTo(context);
                    },
                    child: Text(
                      "inscription".toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        elevation: 0,
      ),
    );
  }
}
