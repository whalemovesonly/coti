import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../layouts/main_layout.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateUserPage extends StatefulWidget {
  final String role;
  const CreateUserPage({super.key, required this.role});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedRole = 'viewer';
  bool isLoading = false;
  String? message;

  Future<void> _createUser() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() {
    isLoading = true;
    message = null;
  });

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('❌ Not authenticated');
    return;
  }

  final idToken = await user.getIdToken(true); // force refresh
  print('🔑 ID Token: $idToken');
  print('UID: ${user.uid}');
  print('Email: ${user.email}');

  final url = Uri.parse('https://us-central1-bid-tracker-1ed65.cloudfunctions.net/createUserWithRole');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'role': selectedRole,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newUserId = data['uid'];
      message = tr('user_created');
      _formKey.currentState!.reset();
      print('✅ Created new user with UID: $newUserId');
    } else {
      print('❌ Server error: ${response.statusCode}');
      print('❌ Response body: ${response.body}');
      message = 'Server error: ${response.statusCode}';
    }
  } catch (e) {
    print('❌ Exception: $e');
    message = e.toString();
  }

  setState(() {
    isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    context.locale;
    return MainLayout(
      title: tr('create_user'), role: widget.role,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: tr('email'),
                      prefixIcon: const Icon(Icons.email),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? tr('required') : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: tr('password'),
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? tr('required') : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: tr('role'),
                      border: const OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => selectedRole = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _createUser,
                    icon: const Icon(Icons.person_add),
                    label: isLoading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(tr('create_user')),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(message!, style: TextStyle(color: Colors.blue.shade700)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}