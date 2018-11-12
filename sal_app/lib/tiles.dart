import 'package:flutter/material.dart';
import 'category.dart';
import 'rooms_for_category_screen.dart';
import 'room.dart';
import 'utils.dart';

double _basePadding = 16.0;
double _paddingBetweenIconAndText = 70.0;

/// The UI for a single category in categories display
class CategoryTile extends StatelessWidget {
  final Category _category;
  CategoryTile(this._category);

  void _navigateToRoomsForCategory(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_category.name),
          elevation: 1.0,
        ),
        body: RoomsForCategoryScreen(_category.rooms),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
            //color: Colors.blue[100],
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
                            _category.name,
                            style: Theme.of(context).textTheme.display1,
                            //textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )))));
  }
}

/// A tile which can either show just the time span, or a list of rooms with info about availability
class ScheduleBlockTile extends StatefulWidget {
  final List<Room> rooms;
  final int startHour;

  ScheduleBlockTile(this.startHour, this.rooms);

  @override
  _ScheduleBlockTileState createState() => _ScheduleBlockTileState();
}

class _ScheduleBlockTileState extends State<ScheduleBlockTile> {
  bool _showRooms = false;

  /// Returns the basic tile which just shows the schedule block time.
  Widget _timeTile() {
    int startHour = widget.startHour;
    int endHour = startHour + 2;
    return Padding(
        padding: EdgeInsets.all(_basePadding),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  bottom: 8.0,
                  left: 8.0,
                  right: _paddingBetweenIconAndText,
                  top: 8.0),
              child: _showRooms
                  ? Icon(Icons.keyboard_arrow_down)
                  : Icon(Icons.keyboard_arrow_right),
            ),
            Center(
              child: Text(
                (startHour == 8)
                    ? "08:15-$endHour:00"
                    : "$startHour:15-$endHour:00",
                style: Theme.of(context).textTheme.display1,
              ),
            )
          ],
        ));
  }

  Widget _roomsBlock() {
    var roomtexts = <Text>[];
    for (var room in widget.rooms) {
      var isFree = room.isFreeBetween(
          DateTime(
            currentYear,
            currentMonth,
            currentDay,
            widget.startHour,
            15,
          ),
          DateTime(
            currentYear,
            currentMonth,
            currentDay,
            widget.startHour + 2,
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

  void _extendRoomList(BuildContext context) {
    setState(() {
      _showRooms = !_showRooms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: InkWell(
      onTap: () => _extendRoomList(context),
      child: Column(
        children: _showRooms
            ? <Widget>[
                _timeTile(),
                _roomsBlock(),
              ]
            : <Widget>[
                _timeTile(),
              ],
      ),
    ));
  }
}
