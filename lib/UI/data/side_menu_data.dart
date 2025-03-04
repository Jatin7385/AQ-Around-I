import 'package:fitness_dashboard_ui/UI/model/menu_model.dart';
import 'package:flutter/material.dart';

class SideMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icons.home, title: 'Home'),
    MenuModel(icon: Icons.bookmark, title: 'Bookmarks'),
    MenuModel(icon: Icons.map, title: 'Maps'),
    // MenuModel(icon: Icons.history, title: 'Share'), // For later
    // MenuModel(icon: Icons.logout, title: 'Donate'), // For later
  ];
}