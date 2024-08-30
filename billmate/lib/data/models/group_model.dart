import 'package:billmate/domain/entities/group.dart';

class GroupModel extends Group {
  const GroupModel({
    required super.id,
    required super.name,
    required super.owner,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      owner: map['owner'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'owner': owner,
    };
  }

  GroupModel copyWith({
    int? id,
    String? name,
    int? owner,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      owner: owner ?? this.owner,
    );
  }
}
