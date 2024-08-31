import 'package:billmate/presentation/widgets/form/formLogin.dart';
import 'package:flutter/material.dart';
import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/presentation/widgets/form/registration_form.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BillMate',
      theme: AppThemes.lightTheme, // Tema claro
      darkTheme: AppThemes.darkTheme, // Tema escuro
      themeMode: ThemeMode
          .system, // Usa o tema claro ou escuro conforme a configuração do sistema

      // Define a rota inicial do aplicativo
      initialRoute: '/',

      // Configura as rotas
      routes: {
        '/': (context) => RegistrationForm(),
        '/login': (context) => LoginForm(), // Página de login
      },
    );
  }
}
