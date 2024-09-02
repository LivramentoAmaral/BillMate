import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/data/models/user_model.dart';
import 'package:billmate/data/service/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class FixedIncomeModal extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onUpdate;

  FixedIncomeModal({required this.user, required this.onUpdate});

  @override
  _FixedIncomeModalState createState() => _FixedIncomeModalState();
}

class _FixedIncomeModalState extends State<FixedIncomeModal> {
  late TextEditingController _fixedIncomeController;
  late UserService _userService;

  @override
  void initState() {
    super.initState();
    _fixedIncomeController =
        TextEditingController(text: widget.user.fixedIncome.toString());
    _userService = UserService(http.Client());
  }

  @override
  void dispose() {
    _fixedIncomeController.dispose();
    super.dispose();
  }

  Future<void> _updateFixedIncome() async {
    try {
      final newFixedIncome = double.parse(_fixedIncomeController.text);
      final updatedUser = widget.user.copyWith(
        fixedIncome: newFixedIncome,
      );

      // Call the updateUser method from UserService
      await _userService.updateUser(widget.user.id!, updatedUser);

      // Update the state in the parent widget and close the modal
      widget.onUpdate(updatedUser);
      Navigator.of(context).pop();

      // Show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Atualização realizada com sucesso')),
        );
      }
    } catch (e) {
      // Show an error message if an exception occurs
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar o valor da renda fixa: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppThemes.darkTheme.scaffoldBackgroundColor,
      title: Text('Editar Renda Fixa'),
      content: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _fixedIncomeController,
              decoration: InputDecoration(
                labelText: 'Renda Fixa',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateFixedIncome,
              child: Text('Atualizar'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
      ],
    );
  }
}
