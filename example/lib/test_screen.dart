import 'package:flutter/material.dart';
import 'package:mdsoft_google_map_routing_example/main.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Screen'),
      ),
      body: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen()),
          );
        },
        child: const Center(
          child: Text('Go To Main Screen'),
        ),
      ),
    );
  }
}
