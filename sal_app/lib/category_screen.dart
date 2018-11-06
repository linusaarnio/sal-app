import 'dart:async';

import 'package:flutter/material.dart';
import 'category.dart';
import 'tiles.dart';


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

