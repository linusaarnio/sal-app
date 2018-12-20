import 'room.dart';

/// The model for a category, just contains the name and rooms.
class Category {
  List<Room> rooms;
  final String name;

  Category(this.name);

  Category.fromRoomList(this.name, this.rooms); 

  
  /// Probably unneccesary? Examine when you have internet connection!
  List<Room> freeRoomsBetween(DateTime begin, DateTime end) {
    List<Room> freeRooms = <Room>[];
    for (var room in rooms) {
      if (room.isFreeBetween(begin, end)) freeRooms.add(room); 
    }
    return freeRooms;
  } 
}
