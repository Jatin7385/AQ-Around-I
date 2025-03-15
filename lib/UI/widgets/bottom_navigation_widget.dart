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
    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: cardBackgroundColor,
          selectedItemColor: selectionColor,
          unselectedItemColor: Colors.grey.withOpacity(0.6),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            widget.onItemSelected(index);
          },
          items: _buildNavItems(),
        ),
      ),
    );
  }
  
  List<BottomNavigationBarItem> _buildNavItems() {
    return _menuData.menu.map((menuItem) {
      final isSelected = _menuData.menu.indexOf(menuItem) == _selectedIndex;
      
      return BottomNavigationBarItem(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? selectionColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(menuItem.icon),
        ),
        label: menuItem.title,
      );
    }).toList();
  }
}