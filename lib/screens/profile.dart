import 'package:flutter/material.dart';

import '../components/profile_card.dart';
import '../main.dart';
import '../models/user.dart';
import 'badge.dart';
import 'edit_password.dart';
import 'edit_profile.dart';
import 'edit_vehicule.dart';
import 'login_or_register.dart';
import 'parameters.dart';
import 'premium.dart';

class Profile extends StatefulWidget {
  final User user;

  const Profile({Key? key, required this.user}) : super(key: key);

  static const String routeName = '/profile';

  static void navigateTo(BuildContext context, User user) {
    Navigator.of(context).pushNamed(routeName, arguments: user);
  }

  static void popNavigateTo(BuildContext context, User user) {
    Navigator.pop(context);
    Navigator.of(context).popAndPushNamed(routeName, arguments: user);
  }

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileCard(
              user: widget.user,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .25,
            ),
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(15),
              children: [
                buildPremiumButton(),
                ElevatedButton(
                  onPressed: () => Badges.navigateTo(context),
                  child: const Text('Mes badges'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(width: 1, color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => EditProfile.navigateTo(context, widget.user),
                  child: const Text('Modifier mon profil'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(width: 1, color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () =>
                      EditVehicule.navigateTo(context, widget.user.vehicleId),
                  child: const Text('Modifier mon véhicule'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(width: 1, color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => EditPassword.navigateTo(context),
                  child: const Text('Modifier mon mot de passe'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(width: 1, color: Colors.grey.shade700),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .05,
                ),
                ElevatedButton(
                  onPressed: () => Parameters.navigateTo(context),
                  child: const Text('Paramètres'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(width: 1, color: Colors.grey.shade700),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .05,
                ),
                ElevatedButton(
                  onPressed: disconnect,
                  child: const Text(
                    'Déconnexion',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(width: 1, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPremiumButton() {
    if (widget.user.role != 'premim') {
      return ElevatedButton(
        onPressed: () => Premium.navigateTo(context),
        child: const Text(
          'Devenir Premium',
          style: TextStyle(color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow.shade700,
          minimumSize: const Size(double.infinity, 50),
          side: BorderSide(width: 1, color: Colors.grey.shade700),
        ),
      );
    }
    return Container();
  }

  Future disconnect() async {
    await storage.delete(key: "token");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginOrRegister()),
      (route) => false,
    );
  }
}
