import 'package:flutter/material.dart';
import 'utils.dart';
import 'category.dart';
import 'ical_to_category.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/animation.dart';

Color activeArrowColor = Colors.grey[600];
Color disabledArrowColor = Colors.grey[300];
double fontSizeFactor = 0.5;
double chipSizeFactor = 0.7;

/// The screen showing which rooms are free for a chosen category.
class RoomsForCategoryScreen extends StatefulWidget {
  RoomsForCategoryScreen();

  @override
  _RoomsForCategoryScreenState createState() => _RoomsForCategoryScreenState();
}

class _RoomsForCategoryScreenState extends State<RoomsForCategoryScreen>
    with SingleTickerProviderStateMixin {
  Category category;
  String categoryName = "SU-salar";
  DateTime date = DateTime.now();
  TimeOfDay startTime; 
  TimeOfDay endTime;
  Alignment chipsAlignment = Alignment(0.0, 0.0);
  Animation<double> chipsAnimation;
  AnimationController animationController;
  bool positiveAnimation = true;
  double slideExtent = 50; // how far the chips slide when animated

  /// Asynchronously creates the category from ical, will fail without internet connection.
  Future<void> _createCategory() async {
    String urlString =
        scheduleBaseUrl + urlEndingForCategorySchedule[categoryName];
    Uri url = Uri.parse(urlString);
    var tempCategory = await categoryFromUrl(url, categoryName);
    setState(() {
      category = tempCategory;
    });
  }

  /// Runs after initState and whenever dependencies are changed.
  /// Creates category if it doesn't exist and correctly sets initial times.
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (category == null) {
      var nowHour = TimeOfDay.now().hour;
      if (!viewingToday()) {
        startTime = TimeOfDay(
          hour: 8,
          minute: 15,
        );
      } else if (nowHour <= 8) {
        startTime = TimeOfDay(
          hour: 8,
          minute: 15,
        );
      } else if (nowHour >= 19) {
        startTime = TimeOfDay(
          hour: 19,
          minute: 15,
        );
      } else if (nowHour == 12) {
        startTime = TimeOfDay(
          hour: 13,
          minute: 15,
        );
      } else {
        for (var i = 1; i < startHours.length; ++i) {
          if (startHours[i] > nowHour) {
            startTime = TimeOfDay(
              hour: startHours[
                  i - 1], // Starthour will be the latest passed hour.
              minute: 15,
            );
            break;
          }
        }
      }
      endTime = TimeOfDay(
        hour: startTime.hour + 2,
        minute: 0,
      );
      await _createCategory();
    }
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    chipsAnimation =
        Tween<double>(begin: 0, end: slideExtent).animate(animationController)
          ..addListener(() {
            setState(() {
              if (positiveAnimation) {
                chipsAlignment = Alignment(chipsAnimation.value, 0);
              } else {
                chipsAlignment = Alignment(-chipsAnimation.value, 0);
              }
            });
          });
  }

  /// Is the chosen date todays date?
  bool viewingToday() {
    DateTime today = DateTime.now();
    return (date.day == today.day &&
        date.month == today.month &&
        date.year == today.year);
  }

  /// Is the chosen date the last date we have info for?
  bool viewingLastAllowedDate() {
    DateTime lastDay = DateTime.now().add(Duration(
      days: 14,
    ));
    return (date.day == lastDay.day &&
        date.month == lastDay.month &&
        date.year == lastDay.year);
  }

  /// Is the chosen time at or before the first schedule block?
  bool viewingFirstBlock() {
    return startTime.hour <= startHours[0];
  }

  /// Is the chosen time at or after the last schedule block?
  bool viewingLastBlock() {
    return startTime.hour >= startHours[startHours.length - 1];
  }

  /// Is the end time set to be before the start time?
  bool endTimeBeforeStart() {
    return (startTime.hour > endTime.hour ||
        (startTime.hour == endTime.hour && startTime.minute > endTime.minute));
  }

  /// Shows a time picker, and sets either starttime or endtime (depending on the parameter isStartTime)
  /// to the chosen time.
  /// If the user sets endtime before starttime, it tries to ajust the not set time to fit normal schedule block times.
  void changeTime(BuildContext context, bool isStartTime) async {
    var newTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? startTime : endTime,
    );
    setState(() {
      if (isStartTime) {
        startTime = newTime ?? startTime;
        if (endTimeBeforeStart()) {
          endTime = TimeOfDay(hour: startTime.hour + 2, minute: 0);
        }
      } else {
        endTime = newTime ?? endTime;
        if (endTimeBeforeStart()) {
          startTime = TimeOfDay(hour: endTime.hour - 2, minute: 15);
        }
      }
    });
  }

  /// Switches to the schedule block before the chosen starthour.
  void previousScheduleBlock() {
    int nowHour = startTime.hour;
    for (var i = 1; i < startHours.length; ++i) {
      if (startHours[i] >= nowHour) {
        setState(() {
          startTime = TimeOfDay(
            hour:
                startHours[i - 1], // Starthour will be the latest passed hour.
            minute: 15,
          );
          endTime = TimeOfDay(hour: startTime.hour + 2, minute: 0);
        });
        return;
      }
    }
    setState(() {
      startTime = TimeOfDay(
        hour: startHours[startHours.length - 1],
        minute: 15,
      );
      endTime = TimeOfDay(hour: startTime.hour + 2, minute: 0);
    });
  }

  /// Switches to the schedule block after the chosen starthour.
  void nextScheduleBlock() {
    int nowHour = startTime.hour;
    for (var i = 0; i < startHours.length; ++i) {
      if (startHours[i] > nowHour) {
        setState(() {
          startTime = TimeOfDay(
            hour: startHours[i], // Starthour will be the latest passed hour.
            minute: 15,
          );
          endTime = TimeOfDay(hour: startTime.hour + 2, minute: 0);
        });
        break;
      }
    }
  }

  /// Changes date with duration.
  /// If duration = null,shows a datepicker and sets the date to the chosen date (you can choose earliest yesterday and latest two weeks ahead).
  /// Sets times to the first schedule block.
  void changeDate(BuildContext context, Duration duration) async {
    var newDate;
    if (duration == null) {
      newDate = await showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(Duration(days: 1)),
        lastDate: DateTime.now().add(new Duration(days: 14)),
        initialDate: date,
      );
    } else {
      newDate = date.add(duration);
    }
    setState(() {
      date = newDate ?? date;
      startTime = TimeOfDay(hour: 8, minute: 15);
      endTime = TimeOfDay(hour: 10, minute: 0);
    });
  }

  /// The tile that shows the chosen date, will show a time picker to change date on click.
  Widget dateTile(BuildContext context) {
    double arrowSize = 40;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          child: Icon(
            Icons.arrow_left,
            size: arrowSize,
            color: viewingToday() ? disabledArrowColor : activeArrowColor,
          ),
          onTap: () =>
              viewingToday() ? null : changeDate(context, Duration(days: -1)),
        ),
        InkWell(
          onTap: () => changeDate(context, null),
          child: Text(
            date.year.toString() +
                "-" +
                date.month.toString() +
                "-" +
                date.day.toString(),
            style: Theme.of(context).textTheme.display1.apply(
                  fontSizeFactor: fontSizeFactor,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        InkWell(
          child: Icon(
            Icons.arrow_right,
            size: arrowSize,
            color: viewingLastAllowedDate()
                ? disabledArrowColor
                : activeArrowColor,
          ),
          onTap: () => viewingLastAllowedDate()
              ? null
              : changeDate(context, Duration(days: 1)),
        )
      ],
    );
  }

  /// A tile that shows a time, will change either start or end time on click (depending on parameter isStartTime)
  Widget timeTile(BuildContext context, bool isStartTime) {
    return Padding(
      padding: EdgeInsets.only(top: 4, bottom: 4),
      child: InkWell(
        onTap: () => changeTime(context, isStartTime),
        child: Text(
          isStartTime ? startTime.format(context) : endTime.format(context),
          style: Theme.of(context)
              .textTheme
              .display1
              .apply(fontSizeFactor: fontSizeFactor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// The row of both start time and end time
  Widget timesRow(BuildContext context) {
    double iconSize = 40;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      IconButton(
        icon: Icon(Icons.arrow_left,
            size: iconSize,
            color: viewingFirstBlock() ? disabledArrowColor : activeArrowColor),
        onPressed: () => previousScheduleBlock(),
      ),
      timeTile(context, true),
      Text(
        " - ",
        style: Theme.of(context).textTheme.display1.apply(),
      ),
      timeTile(context, false),
      IconButton(
        icon: Icon(
          Icons.arrow_right,
          size: iconSize,
          color: viewingLastBlock() ? disabledArrowColor : activeArrowColor,
        ),
        onPressed: () => nextScheduleBlock(),
      ),
    ]);
  }

  /// The block which shows the rooms and indicates wheter they are free or not for the chosen date and times.
  Widget _roomsBlock() {
    var roomtexts = <Widget>[];
    for (var room in category.rooms) {
      var isFree = room.isFreeBetween(
          DateTime(
            date.year,
            date.month,
            date.day,
            startTime.hour,
            startTime.minute,
          ),
          DateTime(
            date.year,
            date.month,
            date.day,
            endTime.hour,
            endTime.minute,
          ));
      roomtexts.add(Chip(
        backgroundColor: isFree ? Colors.lime[200] : Colors.orange[200],
        label: Text(
          room.name,
          style: Theme.of(context).textTheme.display1.apply(
                color: isFree ? Colors.green[500] : Colors.red,
                fontSizeFactor: 0.55,
              ),
        ),
      ));
    }
    return Align(
        alignment: chipsAlignment,
        child: Container(
            padding: EdgeInsets.only(top: 10, bottom: 50, left: 20, right: 20),
            child: Wrap(
              children: roomtexts,
              spacing: 8.0,
              runSpacing: 4.0,
            )));
  }

  /// Switch schedule block and animate chips according to direction
  _switchBlockAnimated(SlideDirection direction) {
    animationController.value = 0;
    setState(() {
      positiveAnimation = (direction == SlideDirection.left) ? false : true;
    });
    animationController.forward(from: chipsAlignment.x).whenCompleteOrCancel(
        (direction == SlideDirection.left)
            ? _slideInNextScheduleBlockFromRight
            : _slideInPreviousScheduleBlockFromLeft);
  }

  /// Switches to the next schedule block and animates from the right side
  void _slideInNextScheduleBlockFromRight() {
    if (viewingLastBlock()) {
      if (!viewingLastAllowedDate()) {
        changeDate(context, Duration(days: 1));
      } else {
        setState(() {
          chipsAlignment = Alignment(0, 0);
        });
        return;
      }
    } else {
      nextScheduleBlock();
    }
    setState(() {
      positiveAnimation = true;
    });
    animationController.value = slideExtent;
    animationController.reverse().whenCompleteOrCancel(() {
      setState(() {
        chipsAlignment = Alignment(0, 0);
      });
    });
  }

  /// Switches to the previous schedule block and animates the chips sliding in from left
  void _slideInPreviousScheduleBlockFromLeft() {
    if (viewingFirstBlock()) {
      if (!viewingToday()) {
        changeDate(context, Duration(days: -1));
        setState(() {
          startTime = TimeOfDay(
            hour: startHours[startHours.length -
                1], // Starthour will be the latest passed hour.
            minute: 15,
          );
          endTime = TimeOfDay(hour: startTime.hour + 2, minute: 0);
        });
      } else {
        setState(() {
          chipsAlignment = Alignment(0, 0);
        });
        return;
      }
    } else {
      previousScheduleBlock();
    }
    setState(() {
      positiveAnimation = false;
    });
    animationController.value = slideExtent;
    animationController.reverse().whenCompleteOrCancel(() {
      setState(() {
        chipsAlignment = Alignment(0, 0);
      });
    });
  }

  /// The block showing date and times, and controls for these
  Widget _dateTimeBlock(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 15, bottom: 10, left: 20, right: 20),
        child: Card(
            elevation: 5,
            color: liuTurqoise40,
            child: Column(
              children: <Widget>[
                Center(child: dateTile(context)),
                timesRow(context)
              ],
            )));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  /// The ListView containing buttons that change the category.
  Widget _navigationListView() {
    List<Widget> tiles = <Widget>[];
    tiles.add(DrawerHeader(
      child: Text("Kategorier", style: TextStyle(color: Colors.white, fontSize: 18),),
      decoration: BoxDecoration(color: liuBlue100),
    ));
    for (int i = 0; i < categoryNames.length; ++i) {
      var tileCategoryName = categoryNames[i];
      tiles.add(ListTile(
          onTap: () {
            setState(() {
              categoryName = tileCategoryName;
              category =
                  null; // category will be loaded in didChangeDependencies
            });
            didChangeDependencies(); // force update
            Navigator.pop(context); // close menu drawer
          },
          title: Text(tileCategoryName,
              style: Theme.of(context)
                  .textTheme
                  .display1
                  .apply(fontSizeFactor: 0.6)),
          leading: Icon(
            iconForCategory[tileCategoryName],
            size: 25,
          )));
    }
    return ListView(
      children: tiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: _navigationListView(),
        ),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(0, 185, 231, 1.0), 
          title: Text(
            categoryName,
            style: TextStyle(color: Colors.white),
          ),
          elevation: 1.0,
        ),
        body:

            // Everything is wrapped in a GD to detect swipes
            GestureDetector(
                // While swiping
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    chipsAlignment = Alignment(
                        chipsAlignment.x +
                            20 *
                                details.delta.dx /
                                MediaQuery.of(context).size.width,
                        0.0);
                  });
                },
                // When swipe is released
                onPanEnd: (DragEndDetails details) {
                  if (chipsAlignment.x < -3.0) {
                    _switchBlockAnimated(SlideDirection.left);
                  } else if (chipsAlignment.x > 3.0) {
                    _switchBlockAnimated(SlideDirection.right);
                  } else {
                    setState(() {
                      chipsAlignment = Alignment(0.0, 0.0);
                    });
                  }
                },
                // Shows a progress indicator until the category is loaded, then the actual content.
                child: Container(
                  alignment: Alignment.topCenter,
                  child: (category != null)
                      ? ListView(
                          children: <Widget>[
                            _dateTimeBlock(context),
                            _roomsBlock(),
                          ],
                        )
                      : LinearProgressIndicator(
                          value: null,
                        ),
                )));
  }
}
