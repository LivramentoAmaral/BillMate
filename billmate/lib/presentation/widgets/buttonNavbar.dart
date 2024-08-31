// ignore: file_names
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: 'Balanço',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups),
          label: 'Grupos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money_outlined),
          label: 'Dispesas',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface,
      backgroundColor: theme.scaffoldBackgroundColor,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/');
            break;
          case 1:
            Navigator.pushNamed(context, '/groups');
            break;
          case 2:
            Navigator.pushNamed(context, '/profile');
            break;
        }
        onItemTapped(index);
      },
    );
  }
}
