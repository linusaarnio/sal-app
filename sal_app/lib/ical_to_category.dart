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
          print(eventContents);
          _vevent = null;
        } else if (_vevent != null) { // We are inside an event, so we should collect all data into a string
          eventContents += line;
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

  /// process one line from the ical-format of the _Vevent
  void process(String line) {
    var list = line.split("Lokal : ");
    if (list.length > 1) {
      for (var item in list) {
        print(item);
      }
    }
  }
}
