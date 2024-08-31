import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/presentation/screens/grup_screen.dart';
import 'package:billmate/presentation/screens/home_screen.dart';
import 'package:billmate/presentation/screens/login_screen.dart';
import 'package:billmate/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/': (context) => HomePage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const SignupScreen(),
        '/groups': (context) => UserGroupsPage(),
      },
    );
  }
}
