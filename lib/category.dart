import 'room.dart';

/// The model for a category, just contains the name and rooms.
class Category {
  List<Room> rooms;
  final String name;

  Category(this.name);

  Category.fromRoomList(this.name, this.rooms); 
  
}
