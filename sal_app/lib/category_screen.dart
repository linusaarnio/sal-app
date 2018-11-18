import 'dart:async';

import 'package:flutter/material.dart';
import 'category.dart';
import 'tiles.dart';
import 'utils.dart';
import 'ical_to_category.dart';

String scheduleBaseUrl = "https://cloud.timeedit.net/liu/web/schema/";
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

// THIS SHOULD NOT BE DONE HERE, INSTEAD CREATE A CATEGORY WHEN IT OPENS
  ///Fills _categories with the finished Category:s, complete with filled Room:s.
  Future<void> _createCategories() async {
    for (var categoryName in categoryNames) {
      String urlString = scheduleBaseUrl + urlEndingForCategorySchedule[categoryName];
      Uri url = Uri.parse(urlString);
      Category category = await categoryFromUrl(url, categoryName);
      _categories.add(category);
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

