import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'pages/contract_page.dart';
import 'pages/contract_list_page.dart';
import 'pages/dashboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login_page.dart';
import 'pages/contract_detail_page.dart';
import 'pages/create_user_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';
import 'theme/theme_notifier.dart';
import 'theme/themes.dart';
import 'theme/theme_type.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

await EasyLocalization.ensureInitialized();
    await FirebaseAppCheck.instance.activate(
  webProvider: ReCaptchaV3Provider('6LdGO2crAAAAAEIskiYgWu3hpjDl5sPgZiMisivD'),
);

  runApp(

    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: EasyLocalization(
      supportedLocales: [Locale('en'), Locale('fr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: const MyApp(),
    ),
    )
    ,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contract App',

      theme: appThemes[AppThemeType.light],
      darkTheme: appThemes[AppThemeType.dark],
      themeMode: themeNotifier.currentTheme == AppThemeType.dark
          ? ThemeMode.dark
          : ThemeMode.light,

      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/dashboard': (context) {
          return DashboardPage();
        },
      },
    );
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPage(); // No need for FutureBuilder
  }
}