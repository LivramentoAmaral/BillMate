// ignore: file_names
import 'dart:io';

import 'package:billmate/data/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(HttpClient());
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final tokenData = await _authService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Salvar tokens usando SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', tokenData['access']);
        await prefs.setString('refresh_token', tokenData['refresh']);

        // Exibir mensagem de sucesso
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login bem-sucedido!'),
            // ignore: use_build_context_synchronously
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/');
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                  focusedBorder: theme.inputDecorationTheme.focusedBorder,
                  enabledBorder: theme.inputDecorationTheme.enabledBorder,
                  border: theme.inputDecorationTheme.border,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                  focusedBorder: theme.inputDecorationTheme.focusedBorder,
                  enabledBorder: theme.inputDecorationTheme.enabledBorder,
                  border: theme.inputDecorationTheme.border,
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              const SizedBox(height: 20.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                        backgroundColor: theme
                            .elevatedButtonTheme.style?.backgroundColor
                            ?.resolve({WidgetState.pressed}),
                        foregroundColor: theme
                            .elevatedButtonTheme.style?.foregroundColor
                            ?.resolve({WidgetState.pressed}),
                      ),
                      child: const Text('Entrar'),
                    ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                      context, '/register'); // Navegar para a tela de cadastro
                },
                child: const Text('Não tem uma conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
