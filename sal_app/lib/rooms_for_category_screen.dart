import 'package:flutter/material.dart';
import 'room.dart';
import 'utils.dart';
import 'tiles.dart';

class RoomsForCategoryScreen extends StatefulWidget {
  final List<Room> rooms;

  RoomsForCategoryScreen(this.rooms);

  @override
  _RoomsForCategoryScreenState createState() =>
      _RoomsForCategoryScreenState(rooms);
}

class _RoomsForCategoryScreenState extends State<RoomsForCategoryScreen> {
  List<Room> rooms;
  DateTime date = DateTime.now(); // change this
  TimeOfDay startTime = TimeOfDay.now(); // change this
  TimeOfDay endTime = TimeOfDay(hour: 17, minute: 0);

  _RoomsForCategoryScreenState(this.rooms);

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
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () => changeTime(context, isStartTime),
        child: Text(
          isStartTime ? startTime.format(context) : endTime.format(context),
          style: Theme.of(context).textTheme.display1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget timesRow(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      timeTile(context, true),
      timeTile(context, false),
    ]);
  }

  Widget _roomsBlock() {
    var roomtexts = <Text>[];
    for (var room in rooms) {
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
    return Column(children: roomtexts,);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: ListView(
        children: <Widget>[
          dateTile(context),
          timesRow(context),
          _roomsBlock(),
        ],
      ),
    );
  }
}
