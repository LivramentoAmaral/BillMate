import 'package:equatable/equatable.dart';

class Group extends Equatable {
  final int id;
  final String name;
  final int owner;

  const Group({
    required this.id,
    required this.name,
    required this.owner,
  });

  @override
  List<Object?> get props => [id, name, owner];

  @override
  bool? get stringify => true;
}
