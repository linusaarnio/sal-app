import 'dart:async';

import 'package:flutter/material.dart';
import 'category.dart';
import 'rooms_for_category_screen.dart';
import 'utils.dart';

/// A screen that shows a list of categories and takes you to the rooms screen for selected category when you click it.
class CategoryScreen extends StatefulWidget {
  _CategoryScreenSate createState() => _CategoryScreenSate();
}

class _CategoryScreenSate extends State<CategoryScreen> {

void _navigateToRoomsForCategory(BuildContext context, String categoryName) async {
      Navigator.of(context)
          .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.lime[50],
            iconTheme: IconThemeData(color: Colors.black),
            title: Text(
              categoryName,
              style: TextStyle(color: Colors.black),
            ),
            elevation: 1.0,
          ),
          body: RoomsForCategoryScreen(categoryName),
        );
      }));
    }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
        child: Card(
            elevation: 10,
            color: Colors.teal[100],
            child: ListView.builder(
              itemBuilder: (BuildContext context, int i) {
                var categoryName = categoryNames[i];
                return ListTile(
                  onTap: () => _navigateToRoomsForCategory(context, categoryName),
                  title: Text(categoryName,
                  style: Theme.of(context).textTheme.display1.apply(fontSizeFactor: 0.6)),
                  leading: Icon(iconForCategory[categoryName], size: 25,),
                );
              },
              itemCount: categoryNames.length,

              shrinkWrap: true,
            )));
  }
}

  

/// The padding all around a category tile.
double _basePadding = 16.0;

/// The padding between icon and text in a category tile.
double _paddingBetweenIconAndText = 70.0;

/// A tile showing a single category name.
/// Navigates to the rooms screen for named category on click.
class CategoryTile extends StatelessWidget {
  final String _categoryName;
  CategoryTile(this._categoryName);

  void _navigateToRoomsForCategory(BuildContext context) async {
    Navigator.of(context)
        .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lime[50],
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            _categoryName,
            style: TextStyle(color: Colors.black),
          ),
          elevation: 1.0,
        ),
        body: RoomsForCategoryScreen(_categoryName),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
            color: Colors.teal[100],
            child: InkWell(
                onTap: () => _navigateToRoomsForCategory(context),
                child: Padding(
                    padding: EdgeInsets.all(_basePadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: 8.0,
                              left: 8.0,
                              right: _paddingBetweenIconAndText,
                              top: 8.0),
                          child: Icon(Icons.code),
                        ),
                        Center(
                          child: Text(
                            _categoryName,
                            style: Theme.of(context).textTheme.display1.apply(),
                            //textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )))));
  }
}
