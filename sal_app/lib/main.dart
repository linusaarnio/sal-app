import 'package:flutter/material.dart';
import 'room.dart';
import 'category_screen.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter Demo',
        theme: new ThemeData(
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              "Kategorier",
            ),
            elevation: 1.0,
          ),
          body: CategoryScreen(),
        ));
  }
}
