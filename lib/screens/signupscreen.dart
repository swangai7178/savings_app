import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_saver/models/user_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _saveUserAndSignUp() async {
    if (_formKey.currentState!.validate()) {
      final userBox = Hive.box<UserModel>('userBox');
      final user = UserModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        pin: _pinController.text.trim(),
      );
      await userBox.put('user', user); // store with key 'user'

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Create 4-digit PIN',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.length != 4) {
                    return 'PIN must be 4 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUserAndSignUp,
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
