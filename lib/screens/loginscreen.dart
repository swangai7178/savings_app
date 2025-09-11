import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_saver/models/user_model.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    final userBox = Hive.box<UserModel>('userBox');
    final user = userBox.get('user'); // returns UserModel?

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No account found. Please sign up.')),
        );
      }
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_pinController.text == user.pin) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect PIN.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter your PIN',
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
                onPressed: _login,
                child: const Text('Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
