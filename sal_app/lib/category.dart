import 'room.dart';

List<String> categoryNames = ["SU-salar", "PC-salar"];

class Category {
  List<Room> rooms;
  final String name;

  Category(this.name);

  Category.fromRoomList(this.name, this.rooms); 

  List<Room> freeRoomsBetween(DateTime begin, DateTime end) {
    List<Room> freeRooms = <Room>[];
    for (var room in rooms) {
      if (room.isFreeBetween(begin, end)) freeRooms.add(room); 
    }
    return freeRooms;
  } 
}
