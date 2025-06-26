import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'theme/theme_notifier.dart';
import 'theme/themes.dart';
import 'theme/theme_type.dart';
import 'pages/AddCOTINetworkToMetaMask.dart';
import 'pages/addingNativeCOTItokensToMetamask.dart';
import 'pages/buygCOTI.dart';
import 'pages/bridgeHack.dart';
import 'pages/GCotiDepositsPage.dart';
import 'pages/CotiDepositsPage.dart';
import 'pages/GCotiTreasuryTrackerPage.dart';
import 'pages/GCotiChartPage.dart';
import 'pages/GCotiTreasuryOverviewPage.dart';
import 'pages/CotiTreasuryTrackerPage.dart';



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
      title: 'COTI V2 tools',

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
        '/AddCOTINetworkToMetaMask': (context) {
          return AddCOTINetworkToMetaMask();
        },
        '/AddCOTITokenToMetaMask': (context) {
          return AddCOTITokenToMetaMask();
        },
        '/BuyGCOTIPage': (context) {
          return BuyGCOTIPage();
        },
        '/BridgeHackPage': (context) {
          return BridgeHackPage();
        },
        '/GCotiDepositsPage': (context) {
          return GCotiDepositsPage();
        },
        '/CotiDepositsPage': (context) {
          return CotiDepositsPage();
        },
        '/GCotiTreasuryTrackerPage': (context) {
          return GCotiTreasuryTrackerPage();
        }, 
        '/GCotiChartPage': (context) {
          return GCotiChartPage();
        }, 
        '/GCotiTreasuryOverviewPage': (context) {
          return GCotiTreasuryOverviewPage();
        }, 
        '/CotiTreasuryTrackerPage': (context) {
          return CotiTreasuryTrackerPage();
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