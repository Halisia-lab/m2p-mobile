import 'package:flutter/material.dart';
import 'package:m2p/services/user.dart';

import '../common/user_interface_dialog.utils.dart';
import '../main.dart';
import 'login_or_register.dart';

class Parameters extends StatefulWidget {
  const Parameters({Key? key}) : super(key: key);

  static const String routeName = '/parameters';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  State<Parameters> createState() => _ParametersState();
}

class _ParametersState extends State<Parameters> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: const Icon(
              Icons.person_outline,
              color: Colors.red,
            ),
            title: const Text(
              'Supprimer mon compte',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Suppression du compte'),
                content: const SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Vous êtes sur le point de supprimer votre compte.'),
                      Text('Voulez vous vraiment supprimer votre compte ?'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => {
                      deleteAccount(),
                      Navigator.pop(context),
                    },
                    child: const Text('Oui'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  Future deleteAccount() async {
    try {
      var token = await storage.read(key: "token");
      await UserService.deleteUser(token!);
      await storage.delete(key: "token");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegister()),
        (route) => false,
      );
    } catch (err) {
      UserInterfaceDialog.displayAlertDialog(
          context,
          "Nous n'avons pas réussi a supprimer votre compte.",
          "Veuillez réessayer plus tard.");
    }
  }
}
