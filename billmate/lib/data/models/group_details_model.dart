
import 'package:billmate/data/models/user_model.dart';
import 'package:billmate/domain/entities/group_details.dart';

class GroupDetailsModel extends GroupDetails {
  // ignore: use_super_parameters
  const GroupDetailsModel({
    required int id,
    required String name,
    required int owner,
    required List<UserModel> members,
    required String ownerName,
  }) : super(
          id: id,
          name: name,
          owner: owner,
          members: members,
          ownerName: ownerName,
        );

  factory GroupDetailsModel.fromMap(Map<String, dynamic> map) {
    return GroupDetailsModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      owner: map['owner'] as int? ?? 0,
      members: (map['members'] as List<dynamic>?)
          ?.map((item) => UserModel.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      ownerName: map['owner_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'owner': owner,
      'members': members.map((user) => UserModel(id: user.id, email: user.email, name: user.name, accountType: user.accountType, fixedIncome: user.fixedIncome, avatar: user.avatar).toMap()).toList(),
      'owner_name': ownerName,
    };
  }
}
