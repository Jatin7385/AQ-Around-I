import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/UI/const/constant.dart';
import 'package:fitness_dashboard_ui/UI/data/side_menu_data.dart';

class BottomNavigationWidget extends StatefulWidget {
  final Function(int) onItemSelected;

  const BottomNavigationWidget({
    super.key, 
    required this.onItemSelected
  });

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int _selectedIndex = 0;
  final SideMenuData _menuData = SideMenuData();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: cardBackgroundColor,
      selectedItemColor: selectionColor,
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        widget.onItemSelected(index);
      },
      items: _menuData.menu.map((menuItem) => 
        BottomNavigationBarItem(
          icon: Icon(menuItem.icon),
          label: menuItem.title,
        )
      ).toList(),
    );
  }
}