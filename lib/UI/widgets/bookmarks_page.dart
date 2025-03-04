
import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/UI/const/constant.dart';
import 'package:fitness_dashboard_ui/UI/widgets/custom_card_widget.dart';
import 'package:fitness_dashboard_ui/UI/model/bookmark_location_model.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  // Placeholder list of bookmarked locations
  final List<BookmarkedLocation> _bookmarkedLocations = [
    BookmarkedLocation(
      id: '1',
      name: 'Work',
      address: '123 Office Street',
      currentCigarettesConsumed: 3,
    ),
    BookmarkedLocation(
      id: '2',
      name: 'Cafe',
      address: '456 Coffee Lane',
      currentCigarettesConsumed: 2,
    ),
  ];

  void _incrementCigaretteCount(BookmarkedLocation location) {
    setState(() {
      final index = _bookmarkedLocations.indexWhere((loc) => loc.id == location.id);
      if (index != -1) {
        _bookmarkedLocations[index] = _bookmarkedLocations[index].copyWith(
          currentCigarettesConsumed: _bookmarkedLocations[index].currentCigarettesConsumed + 1
        );
      }
    });
  }

  void _decrementCigaretteCount(BookmarkedLocation location) {
    setState(() {
      final index = _bookmarkedLocations.indexWhere((loc) => loc.id == location.id);
      if (index != -1 && _bookmarkedLocations[index].currentCigarettesConsumed > 0) {
        _bookmarkedLocations[index] = _bookmarkedLocations[index].copyWith(
          currentCigarettesConsumed: _bookmarkedLocations[index].currentCigarettesConsumed - 1
        );
      }
    });
  }

  void _addNewLocation() {
    // TODO: Implement add location functionality
    final newLocation = BookmarkedLocation(
      id: DateTime.now().toString(),
      name: 'New Location',
      address: 'Enter Address',
      currentCigarettesConsumed: 0,
    );

    setState(() {
      _bookmarkedLocations.add(newLocation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarked Locations',
          style: TextStyle(color: primaryColor),
        ),
        backgroundColor: backgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: primaryColor),
            onPressed: _addNewLocation,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookmarkedLocations.length,
        itemBuilder: (context, index) {
          final location = _bookmarkedLocations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            location.address,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Bookmarked: ${location.bookmarkedAt.toLocal()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _decrementCigaretteCount(location),
                          ),
                          Text(
                            '${location.currentCigarettesConsumed}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _incrementCigaretteCount(location),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _bookmarkedLocations.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}