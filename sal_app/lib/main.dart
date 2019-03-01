import 'package:flutter/material.dart';
import 'utils.dart';
import 'category_screen.dart';
import 'rooms_for_category_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
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
        home: RoomsForCategoryScreen(),);}}/*Scaffold(
          drawer: Drawer(

          ),
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(0, 185, 231, 1.0),//Colors.lime[50],
            title: Text(
              "Kategorier",
              style: TextStyle(color: Colors.white),
            ),
            elevation: 1.0,
          ),  
          body: CategoryScreen(),
        ));
  }
}
*/