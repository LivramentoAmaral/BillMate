import 'package:billmate/presentation/widgets/form/formLogin.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints
                    .maxHeight, // Ensure the form takes up the full height
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(),
                  child: const Padding(
                    padding:
                        EdgeInsets.all(16.0), // Add padding around the form
                    child: LoginForm(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
