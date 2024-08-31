import 'package:billmate/data/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  @override
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login bem-sucedido!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar para outra tela se necessário
        // Navigator.pushReplacementNamed(context, '/home');

        // Se você precisar navegar para outra tela após o login, você pode descomentar a linha acima e substituir '/home' pela rota desejada.
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
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
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  focusedBorder:
                      Theme.of(context).inputDecorationTheme.focusedBorder,
                  enabledBorder:
                      Theme.of(context).inputDecorationTheme.enabledBorder,
                  border: Theme.of(context).inputDecorationTheme.border,
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
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  focusedBorder:
                      Theme.of(context).inputDecorationTheme.focusedBorder,
                  enabledBorder:
                      Theme.of(context).inputDecorationTheme.enabledBorder,
                  border: Theme.of(context).inputDecorationTheme.border,
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              SizedBox(height: 20.0),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .elevatedButtonTheme
                            .style
                            ?.backgroundColor
                            ?.resolve({WidgetState.pressed}),
                        foregroundColor: Theme.of(context)
                            .elevatedButtonTheme
                            .style
                            ?.foregroundColor
                            ?.resolve({WidgetState.pressed}),
                      ),
                      child: Text('Entrar'),
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
