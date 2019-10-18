import  'list.dart';
import 'package:flutter/material.dart';

void main() => runApp(CTracker());

class CTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Tracker',
      theme: ThemeData(
        accentColor: Colors.lightGreen[800],
        primaryColor: Colors.amber[700],
          dividerTheme: DividerThemeData(
              color: Colors.amber[600],
              thickness: 0.5,
              space: 0.0
          ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.lightGreen[800],
          disabledColor: Colors.grey,
          textTheme: ButtonTextTheme.primary
        ),
        textTheme: TextTheme(
          title: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold
          ),
          subtitle: TextStyle(
              color: Colors.grey[500]
          )
        )
      ),
      home: CurrencyList(),
    );
  }
}