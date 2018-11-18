import 'category.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'room.dart';
import 'utils.dart';

///Creates the category from an ical file in the form of a stream.
Category createCategory(Stream<List<int>> inStream, String name) {
  Map<String, Room> rooms = {};
  for (var room in categoryNames) {
    rooms[room] = Room(room);
  }
  _Vevent _vevent;
  String eventContents;

  /// Here we process the ical file per vevent, for every vevent we add a booking for all the rooms involved.
  inStream
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .listen((String line) {
        if (line == "BEGIN:VEVENT") {
          if (_vevent != null) throw FormatException("Incorrect ical file! Two begins before end of vevent.");
          _vevent = _Vevent(name);
          eventContents = "";
        } else if (line == "END:VEVENT") {
          if (_vevent == null) throw FormatException("Incorrect ical file! End before begin of vevent.");
          for (var room in _vevent.roomNames) {
            // GETTING ERROR HERE, ROOMS[ROOM] SEEMS TO BE NULL. DO INVESTIGATE!
            rooms[room].addBooking(_vevent.start, _vevent.end);
          }
          _vevent = null;
        } else if (_vevent != null) { // We are inside an event, so we should collect all data into a string
          _vevent.process(line);
        }
      });
  var roomList = <Room>[];
  for (var room in rooms.keys) {
    roomList.add(rooms[room]);
  }
  return Category.fromRoomList(name, roomList);
}

Future<Category> categoryFromUrl(Uri icalUrl, String categoryName) async {
  HttpClient client = HttpClient();
  var request = await client.getUrl(icalUrl);
  var response = await request.close();
  return createCategory(response, categoryName);
}

/// Represents a Vevent (a booking for a set of rooms) in an ical file. Has a start, end and a list of roomNames which are the rooms involved.
class _Vevent {
  DateTime start;
  DateTime end;
  List<String> roomNames = <String>[];
  bool _isInLocation = false;
  /// The whole row of locations and various other characters. All locations of the vevent are substrings of this string.
  String locationString = "";
  String categoryName;

  _Vevent(this.categoryName);

  /// process one line from the ical-format of the _Vevent
  void process(String line) {
    var parts = line.split(":");
    var firstWord = parts[0];
    if (_isInLocation && firstWord == "DESCRIPTION") {
      _isInLocation = false; // Assuming description is always after location, so we have reached the end of the location part here. 
                             // The processing will break if this ever changes!
      _processLocationsFromLocationString();
    } else if (firstWord == "LOCATION" || _isInLocation) {
      _isInLocation = true; // since locations can carry over multiple rows, we add all parts of those rows to a single string
      for (var part in parts) {
        locationString += part;
      }
    } else if (firstWord == "DTSTART") {
      var dateString = parts[1];
      var year = int.parse(dateString.substring(0,4));
      var month = int.parse(dateString.substring(4,6));
      var day = int.parse(dateString.substring(6, 8));
      var hour = int.parse(dateString.substring(9, 11));
      var minute = int.parse(dateString.substring(11, 13));
      start = DateTime(year, month, day, hour, minute);
    }  else if (firstWord == "DTEND") {
      var dateString = parts[1];
      var year = int.parse(dateString.substring(0,4));
      var month = int.parse(dateString.substring(4,6));
      var day = int.parse(dateString.substring(6, 8));
      var hour = int.parse(dateString.substring(9, 11));
      var minute = int.parse(dateString.substring(11, 13));
      end = DateTime(year, month, day, hour, minute);
    }
  }

  /// Adds all strings that are both a room in the category associated with the vevent, and a substring of the locationString to roomNames.
  void _processLocationsFromLocationString() {
    locationString = locationString.replaceAll(" ", ""); // Strip whitespace to make sure no names are broken because of linebreaks.
    for (var room in roomsInCategory[categoryName]) {
      if (locationString.contains(room)) roomNames.add(room); // This Vevent includes that room
    }
    /*
    locationString = locationString
    .replaceAll(new RegExp(r"LOCATION"), "")
    .replaceAll(new RegExp(r'\\'), "")
    .replaceAll(new RegExp(r','), "")
    .replaceAll(new RegExp(r"Lokal"), "")
    .replaceAll(new RegExp(r"L okal"), "")
    .replaceAll(new RegExp(r"Lo kal"), "")
    .replaceAll(new RegExp(r"Lok al"), "")
    .replaceAll(new RegExp(r"Loka l"), "");*/
    
    
  }
}
