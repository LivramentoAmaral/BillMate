import 'package:billmate/domain/entities/group.dart';
import 'user.dart';

class GroupDetails extends Group {
  final List<User> members;
  final String ownerName;

  const GroupDetails({
    required super.id,
    required super.name,
    required super.owner,
    required this.members,
    required this.ownerName,
  });

  @override
  List<Object?> get props => [id, name, owner, members, ownerName];

  @override
  bool? get stringify => true;
}
