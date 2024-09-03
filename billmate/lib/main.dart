import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/data/models/group_model.dart';
import 'package:billmate/presentation/screens/expensesList_screen.dart';
import 'package:billmate/presentation/screens/expenses_screen.dart';
import 'package:billmate/presentation/screens/group_details_screen.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'BillMate',
      theme: AppThemes.lightTheme, // Tema claro
      darkTheme: AppThemes.darkTheme, // Tema escuro
      themeMode:
          ThemeMode.system, // Usa o tema conforme a configuração do sistema
      initialRoute: '/login', // Rota inicial

      // Configura as rotas
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const SignupScreen(),
        '/groups': (context) => const UserGroupsPage(),
        '/listexpenses': (context) => ExpenseListScreen(),
        '/expenses': (context) => AddExpenseScreen(),
      },

      // Configuração da rota onGenerateRoute para passar argumentos
      onGenerateRoute: (settings) {
        if (settings.name == '/groupdetails') {
          final group = settings.arguments as GroupModel?;
          if (group != null) {
            return MaterialPageRoute(
              builder: (context) {
                return GroupDetailsPage(groupId: group.id);
              },
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Grupo não encontrado')),
              ),
            );
          }
        }
        return null; // Retorna null se a rota não for encontrada
      },
    );
  }
}
