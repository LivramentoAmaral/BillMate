import 'package:billmate/core/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:billmate/data/models/user_model.dart';
import 'package:billmate/data/service/user_service.dart';
import 'package:billmate/domain/entities/accountTypeEnum.dart';
import 'package:http/http.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
    _userService = UserService(Client());
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
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cadastro bem-sucedido!'),
            // ignore: use_build_context_synchronously
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Delay to let the Snackbar be visible
        await Future.delayed(const Duration(seconds: 2));

        // Show dialog before redirecting
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Cadastro Completo'),
              content: Text(
                'Seu cadastro foi realizado com sucesso. Você será redirecionado para a tela de login.',
                style: AppThemes.lightTheme.textTheme.bodyLarge,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.pushReplacementNamed(
                        context, '/'); // Redirect to login
                  },
                  child: const Text('OK'),
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
    return Padding(
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
            const SizedBox(height: 20.0),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 20.0),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Cadastrar'),
                  ),
          ],
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
