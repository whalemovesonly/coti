import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'theme/theme_notifier.dart';
import 'theme/themes.dart';
import 'theme/theme_type.dart';
import 'pages/AddCOTINetworkToMetaMask.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
await EasyLocalization.ensureInitialized();

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
          return AddCOTINetworkToMetaMask();
        },
      },
    );
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddCOTINetworkToMetaMask(); // No need for FutureBuilder
  }
}