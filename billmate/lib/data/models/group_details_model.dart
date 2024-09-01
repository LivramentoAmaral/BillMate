import 'package:billmate/data/models/user_model.dart';
import 'package:billmate/domain/entities/group_details.dart';
import 'package:billmate/domain/entities/user.dart';

class GroupDetailsModel extends GroupDetails {
  const GroupDetailsModel({
    required int id,
    required String name,
    required int owner,
    required List<User> members,
    required String ownerName,
    required String expenses,
    required String totalExpenses,
    required String averageExpensesPerPerson,
    required String totalFixedIncome,
    required DateTime createdAt,
  }) : super(
          id: id,
          name: name,
          owner: owner,
          members: members,
          ownerName: ownerName,
          expenses: expenses,
          totalExpenses: totalExpenses,
          averageExpensesPerPerson: averageExpensesPerPerson,
          totalFixedIncome: totalFixedIncome,
          createdAt: createdAt,
        );

  factory GroupDetailsModel.fromMap(Map<String, dynamic> map) {
    return GroupDetailsModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      owner: map['owner'] as int? ?? 0,
      members: (map['members'] as List<dynamic>?)
              ?.map((item) => UserModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      ownerName: map['owner_name'] as String? ?? '',
      expenses: map['expenses'] as String? ?? '',
      totalExpenses: map['total_expenses'] as String? ?? '',
      averageExpensesPerPerson:
          map['average_expenses_per_person'] as String? ?? '',
      totalFixedIncome: map['total_fixed_income'] as String? ?? '',
      createdAt: DateTime.parse(
          map['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'owner': owner,
      'members': members
          .map((user) => UserModel(
                  id: user.id,
                  email: user.email,
                  name: user.name,
                  accountType: user.accountType,
                  fixedIncome: user.fixedIncome,
                  avatar: user.avatar)
              .toMap())
          .toList(),
      'owner_name': ownerName,
      'expenses': expenses,
      'total_expenses': totalExpenses,
      'average_expenses_per_person': averageExpensesPerPerson,
      'total_fixed_income': totalFixedIncome,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
