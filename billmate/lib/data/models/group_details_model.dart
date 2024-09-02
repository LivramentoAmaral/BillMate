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
    required List<dynamic> expenses, // Ajuste o tipo conforme necessário
    required String totalExpenses,
    required String averageExpensesPerPerson,
    required String totalFixedIncome,
    required DateTime createdAt,
    required List<UserModel> membersModel,

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
      expenses: map['expenses'] as List<dynamic>? ??
          [], // Ajuste o tipo conforme necessário
      totalExpenses: (map['total_expenses'] as num?)?.toDouble()?.toString() ?? '0.0',
      averageExpensesPerPerson:
          (map['average_expenses_per_person'] as num?)?.toDouble()?.toString() ?? '0.0',
      totalFixedIncome: (map['total_fixed_income'] as num?)?.toString() ?? '0.0',
      createdAt: DateTime.parse(
          map['created_at'] as String? ?? DateTime.now().toIso8601String()), membersModel: [],
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
      'expenses': expenses, // Ajuste o tipo conforme necessário
      'total_expenses': totalExpenses,
      'average_expenses_per_person': double.parse(averageExpensesPerPerson),
      'total_fixed_income': double.parse(totalFixedIncome),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
