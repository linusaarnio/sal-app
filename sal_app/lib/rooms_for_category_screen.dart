import 'package:flutter/material.dart';
import 'room.dart';
import 'utils.dart';
import 'tiles.dart';
import 'category.dart';
import 'ical_to_category.dart';

class RoomsForCategoryScreen extends StatefulWidget {
  final String categoryName;

  RoomsForCategoryScreen(this.categoryName);

  @override
  _RoomsForCategoryScreenState createState() => _RoomsForCategoryScreenState();
}

class _RoomsForCategoryScreenState extends State<RoomsForCategoryScreen> {
  Category category;
  DateTime date = DateTime.now(); // change this
  TimeOfDay startTime = TimeOfDay.now(); // change this
  TimeOfDay endTime = TimeOfDay(hour: 17, minute: 0);

  Future<void> _createCategory() async {
    String urlString =
        scheduleBaseUrl + urlEndingForCategorySchedule[widget.categoryName];
    Uri url = Uri.parse(urlString);
    var tempCategory = await categoryFromUrl(url, widget.categoryName);
    setState(() {
          category = tempCategory;
        });
       
  }

  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (category == null) {
      await _createCategory();
    }
  }

  void changeTime(BuildContext context, bool isStartTime) async {
    var newTime = await showTimePicker(
        context: context, initialTime: isStartTime ? startTime : endTime);
    setState(() {
      if (isStartTime)
        startTime = newTime ?? startTime;
      else
        endTime = newTime ?? endTime;
    });
  }

  void changeDate(BuildContext context) async {
    var newDate = await showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(Duration(days: 1)),
        lastDate: DateTime.now().add(new Duration(days: 14)),
        initialDate: date);
    setState(() {
      date = newDate ?? date;
    });
  }

  Widget dateTile(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () => changeDate(context),
        child: Text(
          date.year.toString() +
              "-" +
              date.month.toString() +
              "-" +
              date.day.toString(),
          style: Theme.of(context).textTheme.display1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget timeTile(BuildContext context, bool isStartTime) {
    return Container(
        color: Colors.blue,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () => changeTime(context, isStartTime),
            child: Text(
              isStartTime ? startTime.format(context) : endTime.format(context),
              style: Theme.of(context).textTheme.display1,
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }

  Widget timesRow(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      timeTile(context, true),
      timeTile(context, false),
    ]);
  }

  Widget _roomsBlock() {
    var roomtexts = <Text>[];
    for (var room in category.rooms) {
      var isFree = room.isFreeBetween(
          DateTime(
            date.year,
            date.month,
            date.day,
            startTime.hour,
            startTime.minute,
          ),
          DateTime(
            date.year,
            date.month,
            date.day,
            endTime.hour,
            endTime.minute,
          ));
      roomtexts.add(Text(
        room.name,
        style: Theme.of(context).textTheme.display1.apply(
              color: isFree ? Colors.green : Colors.red,
            ),
      ));
    }
    return Column(
      children: roomtexts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: (category != null)
          ? ListView(
              children: <Widget>[
                dateTile(context),
                timesRow(context),
                _roomsBlock(),
              ],
            )
          : LinearProgressIndicator(
              value: null,
            ),
    );
  }
}
