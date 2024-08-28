import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'utils/custom_colors.dart';
import 'common/router.dart';

const storage = FlutterSecureStorage();

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  await dotenv.load(fileName: ".env");
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map 2 Place',
      theme: ThemeData(
        primarySwatch: primaryBlack,
        filledButtonTheme: FilledButtonThemeData(
          style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              minimumSize: Size(50, 50),
              backgroundColor: Colors.black),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              side: BorderSide(width: 2.0, color: Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              minimumSize: Size(50, 50),
              backgroundColor: Colors.white),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 35,
            color: Colors.black,
            fontFamily: 'Comfortaa',
          ),
          labelSmall: TextStyle(
            fontSize: 15,
            color: Colors.grey,
            fontFamily: 'Comfortaa',
          ),
          labelLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
            fontFamily: 'Comfortaa',
          ),
          labelMedium: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
            fontFamily: 'Comfortaa',
          ),
       headlineMedium:  TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
            fontFamily: 'Comfortaa',
          ),
        ),
      ),
      routes: MyRouter.routes(),
      onGenerateRoute: MyRouter.getRouter,
      supportedLocales: [
        const Locale('fr', 'FR'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
