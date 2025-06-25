import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../theme/theme_type.dart';
import '../theme/styles/login_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
final user = FirebaseAuth.instance.currentUser;
final idToken = await user?.getIdToken();
print('🔥 Logged in user UID: ${user?.uid}');
print('🔥 Token: $idToken');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void _changeLanguage(Locale locale) {
    context.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 400,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 48, color: Colors.blue.shade700),
                    const SizedBox(height: 16),
                    Text(tr('login'),
                        style: LoginTextStyles.title(context),),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: tr('email'),
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? tr('required') : null,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: tr('password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) =>
                          v == null || v.isEmpty ? tr('required') : null,
                    ),

                    const SizedBox(height: 20),

                    if (errorMessage != null)
                      Text(errorMessage!,
                          style: const TextStyle(color: Colors.red)),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                            icon: Icon(Icons.login, color: LoginIconStyles.iconColor(context)), // 👈 make icon white
                            label: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white, // 👈 loader white
                                    ),
                                    )
                                : Text(
                                    tr('login'),
                                    style: LoginTextStyles.buttonText(context), // 👈 make text white
                                    ),
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.blue.shade700,
                                shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                ),
                            ),
                            ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(tr('language') + ': '),
                        TextButton(
                          onPressed: () => _changeLanguage(const Locale('vi')),
                          child: const Text('🇻🇳 Tiếng Việt'),
                        ),
                        TextButton(
                          onPressed: () => _changeLanguage(const Locale('en')),
                          child: const Text('🇬🇧 English'),
                        ),
                      ],
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
                      )

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}