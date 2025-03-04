import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/UI/const/constant.dart';
import 'package:fitness_dashboard_ui/UI/util/responsive.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AQ Around I',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: primaryColor,
              ),
              onPressed: () {
                // Implement notification logic
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search location or region',
            prefixIcon: Icon(
              Icons.search,
              color: primaryColor,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.location_on,
                color: primaryColor,
              ),
              onPressed: () {
                // Implement current location detection
              },
            ),
            filled: true,
            fillColor: cardBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          ),
          onChanged: (value) {
            // Implement search functionality
            print('Searching for: $value');
          },
        ),
      ],
    );
  }
}