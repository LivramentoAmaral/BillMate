import 'package:billmate/data/models/user_model.dart';
import 'package:billmate/data/service/user_service.dart';
import 'package:billmate/domain/entities/accountTypeEnum.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fixedIncomeController = TextEditingController();
  String _accountType = 'Simple'; // Default value for account type
  bool _isLoading = false;
  String? _errorMessage;

  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = UserService(http.Client());
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final user = UserModel(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          fixedIncome: double.tryParse(_fixedIncomeController.text),
          accountType: AccountTypeEnum.fromString(_accountType),
        );

        await _userService.createUser(user);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cadastro bem-sucedido!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: Duration(seconds: 2), // Adjust duration as needed
          ),
        );

        // Show a confirmation dialog before redirecting
        await Future.delayed(
            Duration(seconds: 2)); // Delay to let the Snackbar be visible
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Cadastro Completo'),
              content: Text(
                  'Seu cadastro foi realizado com sucesso. Você será redirecionado para a tela de login.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.pushReplacementNamed(
                        context, '/login'); // Redirect to login
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
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
        title: const Text('Cadastro'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
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
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Senha',
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
                    return 'Por favor, confirme sua senha';
                  }
                  if (value != _passwordController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  focusedBorder:
                      Theme.of(context).inputDecorationTheme.focusedBorder,
                  enabledBorder:
                      Theme.of(context).inputDecorationTheme.enabledBorder,
                  border: Theme.of(context).inputDecorationTheme.border,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _fixedIncomeController,
                decoration: InputDecoration(
                  labelText: 'Renda Fixa',
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  focusedBorder:
                      Theme.of(context).inputDecorationTheme.focusedBorder,
                  enabledBorder:
                      Theme.of(context).inputDecorationTheme.enabledBorder,
                  border: Theme.of(context).inputDecorationTheme.border,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua renda fixa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _accountType,
                onChanged: (newValue) {
                  setState(() {
                    _accountType = newValue!;
                  });
                },
                items: ['Simple', 'Prime'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Tipo de Conta',
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  focusedBorder:
                      Theme.of(context).inputDecorationTheme.focusedBorder,
                  enabledBorder:
                      Theme.of(context).inputDecorationTheme.enabledBorder,
                  border: Theme.of(context).inputDecorationTheme.border,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione um tipo de conta';
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
                      onPressed: _register,
                      child: Text('Cadastrar'),
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
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _fixedIncomeController.dispose();
    super.dispose();
  }
}
