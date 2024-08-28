import 'package:flutter/material.dart';

import '../common/user_interface_dialog.utils.dart';
import '../main.dart';
import '../screens/help.dart';
import '../screens/history.dart';
import '../screens/login_or_register.dart';
import '../screens/parameters.dart';
import '../screens/premium.dart';
import '../screens/profile.dart';
import '../screens/ranking.dart';
import '../screens/shop.dart';
import '../services/user.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    return buildFutureBuilderDrawerMenu();
  }

  FutureBuilder buildFutureBuilderDrawerMenu() {
    return FutureBuilder(
      future: _getUser(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasData) {
              final data = snapshot.data;
              if (data == null) {
                return Center(
                  child: Text(
                    'Nous n\'avons pas pu récupéré vos données 😵‍💫',
                  ),
                );
              }
              return buildDrawerMenu(snapshot.data);
            }
            return Text('${snapshot.error}');
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Container buildDrawerMenu(data) {
    return Container(
      width: MediaQuery.of(context).size.width * 5 / 6,
      child: Drawer(
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      data.avatar
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.firstname + ' ' + data.lastname,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        data.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 24.0,
                            color: const Color.fromARGB(255, 255, 180, 59),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Niveau : " + data.level.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 255, 180, 59)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),

Divider(),
            SizedBox(
              height: 20,
            ),
            
            ListTile(
              leading: Icon(Icons.alarm),
              title: Text("Historique"),
              onTap: () => History.navigateTo(context),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profil"),
              onTap: () => Profile.navigateTo(context, data),
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text("Classement"),
              onTap: () => Ranking.navigateTo(context),
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text("Boutique"),
              onTap: () => Shop.navigateTo(context, data.points)
            ),
            ListTile(
              leading: Icon(Icons.wallet),
              title: Text("Version Premium"),
              onTap: () => Premium.navigateTo(context),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Paramètres"),
              onTap: () => Parameters.navigateTo(context),
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text("Aide"),
              onTap: () => Help.navigateTo(context),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
            ),
            Divider(),
            ListTile(
              trailing: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: Text(
                "Se déconnecter",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => disconnect(),
            ),
          ],
        ),
      ),
    );
  }

  Future _getUser() async {
    try {
      var token = await storage.read(key: "token");
      return await UserService.getUser(token!);
    } catch (err) {
      UserInterfaceDialog.displayAlertDialog(
          context,
          "Nous n'avons pas pu charger vos données. Veuillez réessayer plus tard.",
          "Vérifiez votre connexion internet.");
    }
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
