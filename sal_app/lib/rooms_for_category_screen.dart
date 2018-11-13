import 'package:flutter/material.dart';
import 'room.dart';
import 'utils.dart';
import 'tiles.dart';


class RoomsForCategoryScreen extends StatefulWidget {  
  final List<Room> rooms;

  RoomsForCategoryScreen(this.rooms);

  @override
  _RoomsForCategoryScreenState createState() => _RoomsForCategoryScreenState(rooms);
}

class _RoomsForCategoryScreenState extends State<RoomsForCategoryScreen> {

  List<Room> rooms; 
  ListView scheduleBlocks;

  _RoomsForCategoryScreenState(this.rooms);

  @override
  void initState() {
    super.initState();
    scheduleBlocks = ListView.builder(
    itemBuilder: (BuildContext context, int index) {
      return ScheduleBlockTile(startHours[index], rooms);
    },
    itemCount: startHours.length,
  );
  }

  

  @override
  Widget build(BuildContext context) {
    return Container( 
      child: scheduleBlocks,
    );
  }
}