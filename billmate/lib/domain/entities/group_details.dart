import 'package:billmate/domain/entities/group.dart';
import 'user.dart';

class GroupDetails extends Group {
  final List<User> members;
  final String ownerName;
  final String expenses;
  final String totalExpenses;
  final String averageExpensesPerPerson;
  final String totalFixedIncome;
  final DateTime createdAt;

  const GroupDetails({
    required super.id,
    required super.name,
    required super.owner,
    required this.members,
    required this.ownerName,
    required this.expenses,
    required this.totalExpenses,
    required this.averageExpensesPerPerson,
    required this.totalFixedIncome,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        owner,
        members,
        ownerName,
        expenses,
        totalExpenses,
        averageExpensesPerPerson,
        totalFixedIncome,
        createdAt,
      ];

  @override
  bool? get stringify => true;
}
