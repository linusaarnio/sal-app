/// A timespan with a beginning and end. Always UTC
class TimeSpan {
  final DateTime begin;
  final DateTime end;
  const TimeSpan(this.begin, this.end);
}

/// Compares two TimeSpans. Returns:
/// -1 if a precedes b
/// 1 if b precedes a
/// 0 if a and b overlap in any way
int timeSpanComparator(TimeSpan a, TimeSpan b) {
  if (!a.begin.isAfter(b.begin) && !a.end.isAfter(b.begin))
    return -1; // a is before b
  if (!a.begin.isBefore(b.end)) return 1; // a is after b
  return 0; // a and b are overlapping
}

/// Finds if span overlaps with any of the bookings.
/// Prerequisite: BOOKINGS HAS TO BE SORTED!
/// Complexity: O(logN)
bool overlapsWithAny(
    TimeSpan span, List<TimeSpan> bookings, int left, int right) {
  if (right >= left) {
    var mid = left + ((right - left) / 2).floor();
    switch (timeSpanComparator(bookings[mid], span)) {
      case 0: // bookings[mid] overlaps with span
        return true;
        break;
      case 1: // bookings[mid] is to the right of span, span can only overlap with the bookings to the left of span
        return overlapsWithAny(span, bookings, left, mid - 1);
        break;
      case -1: //bookings[mid] is to the left of span, span can only overlap with the bookings to the right of span
        return overlapsWithAny(span, bookings, mid + 1, right);
    }
  }
  return false;
}

/// Represents a room, which can be booked or free at any given time.
/// All times are presented in UTC!
class Room {

  String name;
  //List of TimeSpans, in UTC
  List<TimeSpan> _bookings;
  bool _bookingsIsSorted = true;
  
  Room.fromBookingsList(this.name, this._bookings) {_bookingsIsSorted = false;}

  Room(this.name) { _bookings = <TimeSpan>[];}

  /// Adds a booking and sets sorted flag to false
  void addBooking(DateTime begin, DateTime end) {
    _bookings.add(TimeSpan(begin, end));
    _bookingsIsSorted = false; 
  }

  /// Returns wheter the room is free between the given times.
  bool isFreeBetween(DateTime begin, DateTime end) {
    if (!_bookingsIsSorted) {
      _bookings.sort(timeSpanComparator);  //bookings has to be sorted
      _bookingsIsSorted = true;
    }
    return !overlapsWithAny(TimeSpan(begin, end), _bookings, 0, _bookings.length -1);
  }

}
