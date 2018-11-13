import 'category.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'room.dart';

///Creates the category from an ical file in the form of a stream.
Category createCategory(Stream<List<int>> inStream) {
  List<Room> rooms = <Room>[];
  _Vevent _vevent;
  String eventContents;

  inStream
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .listen((String line) {
        if (line == "BEGIN:VEVENT") {
          if (_vevent != null) throw FormatException("Incorrect ical file! Two begins before end of vevent.");
          _vevent = _Vevent();
          eventContents = "";
        } else if (line == "END:VEVENT") {
          if (_vevent == null) throw FormatException("Incorrect ical file! End before begin of vevent.");
          _vevent = null;
        } else if (_vevent != null) { // We are inside an event, so we should collect all data into a string
          _vevent.process(line);
        }
      });
  return null;
}

Future<Category> categoryFromUrl(Uri icalUrl) async {
  HttpClient client = HttpClient();
  var request = await client.getUrl(icalUrl);
  var response = await request.close();
  return createCategory(response);
}

class _Vevent {
  DateTime start;
  DateTime end;
  List<String> roomNames;
  bool _isInLocation = false;

  /// process one line from the ical-format of the _Vevent
  void process(String line) {
    var parts = line.split(":");
    var firstWord = parts[0];
    if (_isInLocation && firstWord == "DESCRIPTION") {
      _isInLocation = false;
    } else if (firstWord == "LOCATION" || _isInLocation) {
      _isInLocation = true;
      for (var part in parts) {
        if (part != "LOCATION") {
          part.trim();
          part.replaceAll(new RegExp(r"\, Lokal"), ""); // TODO: Dela upp till lokaldelar
          print(part);
        }
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
}
