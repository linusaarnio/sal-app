import 'room.dart';

List<String> categoryNames = ["SU-salar", "PC-salar"];

class Category {
  List<Room> rooms = <Room>[Room("SU00")];
  final String name;

  Category(this.name);

  List<Room> freeRoomsBetween(DateTime begin, DateTime end) {
    List<Room> freeRooms = <Room>[];
    for (var room in rooms) {
      if (room.isFreeBetween(begin, end)) freeRooms.add(room); 
    }
    return freeRooms;
  } 
}
