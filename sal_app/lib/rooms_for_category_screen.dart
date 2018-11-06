import 'package:flutter/material.dart';
import 'room.dart';
import 'utils.dart';
import 'tiles.dart';

int currentYear = DateTime.now().year;
int currentMonth = DateTime.now().month;
int currentDay = DateTime.now().day;

class RoomsForCategoryScreen extends StatefulWidget {  
  final List<Room> rooms;

  RoomsForCategoryScreen(this.rooms);

  @override
  _RoomsForCategoryScreenState createState() => _RoomsForCategoryScreenState();
}

class _RoomsForCategoryScreenState extends State<RoomsForCategoryScreen> {

  ListView scheduleBlocks = ListView.builder(
    itemBuilder: (BuildContext context, int index) {
      return ScheduleBlockTile(startHours[index]);
    },
    itemCount: startHours.length,
  );

  @override
  Widget build(BuildContext context) {
    return Container( 
      child: scheduleBlocks,
    );
  }
}