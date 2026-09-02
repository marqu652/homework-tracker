import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
     body: Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        'Welcome to Homework Tracker!',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          // Button action goes here
        },
        child: const Text('Add Homework'),
      ),
    ],
  ),
),
    );
  }
}