import 'package:flutter/material.dart';
import 'rooms_for_category_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('sv', 'SE'), // Swedish
        ],
        title: 'Lediga Salar',
        theme: new ThemeData(
            ),
        home: RoomsForCategoryScreen(),);}}