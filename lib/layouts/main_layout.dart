import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../theme/theme_type.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;

  
  const MainLayout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
            color: Colors.white, // 👈 change this to any color you like
        ),
        title: Text(title, style: TextStyle(color: Colors.white),),
        elevation: 1,
        backgroundColor: Colors.blue.shade700,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('AddCOTINetworkToMetaMask')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/AddCOTINetworkToMetaMask');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                context.locale.languageCode == 'en' ? 'French ' : 'English',
              ),
              onTap: () {
                final newLocale =
                    context.locale.languageCode == 'en' ? const Locale('fr') : const Locale('en');
                context.setLocale(newLocale);
                Navigator.pop(context);
              },
            ),

            Consumer<ThemeNotifier>(
              builder: (context, themeNotifier, _) {
                return IconButton(
                  icon: Icon(
                    themeNotifier.currentTheme == AppThemeType.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  onPressed: () {
                    themeNotifier.toggleTheme();
                  },
                );
              },
            ),

          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}