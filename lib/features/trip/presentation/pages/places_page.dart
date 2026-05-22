import 'package:flutter/material.dart';

class PlacesPage extends StatelessWidget {
  const PlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Places')),
      body: const Center(child: Text('Places Content')),
    );
  }
}
