import 'package:flutter/material.dart';

class ActivityDetailPage extends StatelessWidget {
  const ActivityDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Details')),
      body: const Center(child: Text('Activity Details Content')),
    );
  }
}
