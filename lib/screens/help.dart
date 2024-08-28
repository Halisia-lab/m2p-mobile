import 'package:flutter/material.dart';
import 'package:m2p/screens/help_center.dart';
import 'package:m2p/screens/help_report.dart';
import 'package:m2p/screens/privacy_policy.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Help extends StatelessWidget {
  const Help({Key? key}) : super(key: key);

  static const String routeName = '/help';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    String googlePlayStoreUrl =
        'https://play.google.com/store/apps/details?id=com.esgi.m2p';
    String shareMessage =
        'Découvrez cette superbe application : $googlePlayStoreUrl';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide'),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: const Icon(
              Icons.help_outline,
              color: Colors.black,
            ),
            title: const Text('Centre d\'aide'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              HelpCenter.navigateTo(context);
            },
          ),
          Divider(
            indent: 20,
            endIndent: 20,
            color: Colors.grey.shade500,
          ),
          ListTile(
            leading: const Icon(
              Icons.info_outlined,
              color: Colors.black,
            ),
            title: const Text('Signaler un problème'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              HelpReport.navigateTo(context);
            },
          ),
          Divider(
            indent: 20,
            endIndent: 20,
            color: Colors.grey.shade500,
          ),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: Colors.black,
            ),
            title: const Text('Politique de confidentialité'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              PrivacyPolicy.navigateTo(context);
            },
          ),
          Divider(
            indent: 20,
            endIndent: 20,
            color: Colors.grey.shade500,
          ),
          ListTile(
            leading: const Icon(
              Icons.star_outline,
              color: Colors.black,
            ),
            title: const Text('Noter l\'application'),
            onTap: () {
              launch(googlePlayStoreUrl);
            },
          ),
          Divider(
            indent: 20,
            endIndent: 20,
            color: Colors.grey.shade500,
          ),
          ListTile(
            leading: const Icon(
              Icons.share_outlined,
              color: Colors.black,
            ),
            title: const Text('Partager l\'application'),
            onTap: () {
              Share.share(shareMessage);
            },
          ),
          Divider(
            indent: 20,
            endIndent: 20,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }
}
