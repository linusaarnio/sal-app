import 'dart:async';

import 'package:flutter/material.dart';
import 'category.dart';
import 'rooms_for_category_screen.dart';


/// The UI for choosing a category.
class CategoryScreen extends StatefulWidget {
  _CategoryScreenSate createState() => _CategoryScreenSate();
}

class _CategoryScreenSate extends State<CategoryScreen> {
  List<Category> _categories = <Category>[];

  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (_categories.isEmpty) {
      await _createCategories();
    }
  }

  ///Fills _categories with the finished Category:s, complete with filled Room:s.
  Future<void> _createCategories() async {
    for (var categoryName in categoryNames) {
      _categories.add(Category(categoryName));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
          itemBuilder: (BuildContext context, int i) {
            var category = _categories[i];
            return CategoryTile(category);
          },
          itemCount: _categories.length,
        );
  }
}

/// The UI for a single category in categories display
class CategoryTile extends StatelessWidget {
  final Category _category;
  CategoryTile(this._category);


void _navigateToRoomsForCategory(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<Null>(
    builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Lediga " + _category.name),
          elevation: 1.0,
        ),
        body: RoomsForCategoryScreen(_category.rooms),
      );
    }
  ));
}


  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
          //color: Colors.blue[100],
          child: InkWell(
            onTap: () => _navigateToRoomsForCategory(context),
            child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0, left: 16.0, right: 70.0, top: 8.0),
                      child: Icon(Icons.code),
                    ),
                    Center(
                      child: Text(
                        _category.name,
                        style: Theme.of(context).textTheme.display1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )))));
  }
}
