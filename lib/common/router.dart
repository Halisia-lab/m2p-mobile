import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/user_dto.dart';
import '../screens/edit_password.dart';
import '../screens/edit_profile.dart';
import '../screens/edit_vehicule.dart';
import '../screens/help.dart';
import '../screens/help_center.dart';
import '../screens/help_report.dart';
import '../screens/badge.dart';
import '../screens/history.dart';
import '../screens/home.dart';
import '../screens/login.dart';
import '../screens/login_or_register.dart';
import '../screens/parameters.dart';
import '../screens/password_reset.dart';
import '../screens/premium.dart';
import '../screens/privacy_policy.dart';
import '../screens/profile.dart';
import '../screens/ranking.dart';
import '../screens/register_first.dart';
import '../screens/register_second.dart';
import '../screens/screen_not_found.dart';
import '../screens/shop.dart';
import '../screens/splash.dart';

class MyRouter {
  static Map<String, Widget Function(BuildContext context)> routes() {
    return {
      '/': (context) => const SplashScreen(),
      Login.routeName: (context) => const Login(),
      LoginOrRegister.routeName: (context) => const LoginOrRegister(),
      RegisterFirst.routeName: (context) => const RegisterFirst(),
      Home.routeName: (context) => const Home(),
      History.routeName: (context) => const History(),
      Ranking.routeName: (context) => const Ranking(),
      Premium.routeName: (context) => const Premium(),
      Parameters.routeName: (context) => const Parameters(),
      Help.routeName: (context) => const Help(),
      HelpReport.routeName: (context) => const HelpReport(),
      HelpCenter.routeName: (context) => const HelpCenter(),
      PrivacyPolicy.routeName: (context) => const PrivacyPolicy(),
      EditPassword.routeName: (context) => const EditPassword(),
      Badges.routeName: (context) => const Badges(),
      PasswordReset.routeName: (context) => const PasswordReset(),
    };
  }

  static MaterialPageRoute getRouter(RouteSettings settings) {
    Widget screen = const ScreenNotFound();

    switch (settings.name) {
      case Profile.routeName:
        final args = settings.arguments;
        if (args is User) {
          screen = Profile(
            user: args,
          );
        }
        break;
      case EditProfile.routeName:
        final args = settings.arguments;
        if (args is User) {
          screen = EditProfile(
            user: args,
          );
        }
        break;
      case RegisterSecond.routeName:
        final args = settings.arguments;
        if (args is UserDto) {
          screen = RegisterSecond(
            user: args,
          );
        }
        break;
      case EditVehicule.routeName:
        final args = settings.arguments;
        if (args is int) {
          screen = EditVehicule(
            vehicleId: args,
          );
        }
        break;
      case Shop.routeName:
        final args = settings.arguments;
        if (args is int) {
          screen = Shop(
            userScore: args,
          );
        }
        break;
    }
    return MaterialPageRoute(builder: (context) => screen);
  }
}
