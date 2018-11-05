import 'package:flutter/material.dart';
import 'room.dart';
import 'utils.dart';

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
      return Text(DateTime(currentYear, currentMonth, currentDay, startHours[index], 15).toString());
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

/// A tile which can either show just the time span, or a list of rooms with info about availability
class ScheduleBlock extends StatefulWidget {

  final List<Room> rooms;

  ScheduleBlock(this.rooms);

  @override
  _ScheduleBlockState createState() => _ScheduleBlockState();
}

class _ScheduleBlockState extends State<ScheduleBlock> {

  
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}