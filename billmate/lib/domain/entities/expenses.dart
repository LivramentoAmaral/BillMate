class Expense {
  final int id;
  final double amount;
  final String description;
  final DateTime dateSpent;
  final int group;
  final bool isFixed;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.dateSpent,
    required this.group,
    required this.isFixed,
  });
}
