// lib/my_widget.dart
import 'package:flutter/material.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text('Hello'),
            ElevatedButton(onPressed: () {}, child: Text('Click Me')),
            Text("This is a simple widget"),
          ],
        ),
      ),
    );
  }
}
