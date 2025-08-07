import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_flutter/log.dart';

void main() {
  testWidgets("Test the Entry Screen", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Log()));
  });
}
