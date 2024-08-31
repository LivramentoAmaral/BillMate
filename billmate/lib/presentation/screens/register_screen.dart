import 'package:billmate/presentation/widgets/form/registration_form.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      resizeToAvoidBottomInset:
          true, // Ajusta o layout quando o teclado aparece
      body: Padding(
        padding:
            const EdgeInsets.all(16.0), // Ajusta a margem ao redor do conteúdo
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment
                .start, // Alinhamento padrão, sem necessidade de textBaseline
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 20.0), // Margem vertical ao redor do formulário
                child: RegistrationForm(), // Widget de formulário de cadastro
              ),
              // Adiciona um espaçamento para garantir que o conteúdo não fique preso ao final da tela
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
