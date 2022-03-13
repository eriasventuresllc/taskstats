import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

class Analyze extends StatefulWidget {
  const Analyze({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AnalyzeState();
}

class AnalyzeState extends State<Analyze> {
  List<BarChartGroupData> analyzeData = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOn; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  void requestData() async {
    for(int x = 0; x < 10; ++x) {
      BarChartGroupData ele = BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
              colors: [const Color.fromRGBO(239, 83, 80, 1), Colors.red], toY: 15.0)
        ],
      );
      analyzeData.add(ele);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 2,
        title: const Text("Analyze", style: TextStyle(color: Colors.white, fontSize: 24)),
        actions:  [
          IconButton(onPressed: ()=> _showAddDialog(), icon: const Icon(Icons.calendar_today))
        ],
      ),
      body: Stack(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
          const Padding(
            padding: EdgeInsets.only(left: 18, top: 15),
            child: Text(
              "Analyze Data",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 34, right: 20),
              child: RotatedBox(
                quarterTurns: 1,
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceEvenly,
                      maxY: 10,
                      barTouchData: BarTouchData(
                        enabled: false,
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: SideTitles(
                          showTitles: true,
                          //getTextStyles: (value) =>  TextStyle(color: Color(0xffffffff), fontWeight: FontWeight.bold, fontSize: 13),
                          margin: 15,
                          rotateAngle: 270,
                          getTitles: (double value) {
                            return "10.0";
                          },
                        ),
                        leftTitles: SideTitles(
                          showTitles: false,
                        ),
                        topTitles: SideTitles(
                          showTitles: true,
                          //getTextStyles: GetText,
                          //getTextStyles: (value) =,
                          margin: 35,
                          rotateAngle: 270,
                          getTitles: (double value) {
                            return "hello";
                          },
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      //groupsSpace: 40,
                      barGroups: analyzeData,
                    ),
                    swapAnimationDuration: Duration(milliseconds: 600),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  void _showAddDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Add Task",
                  style: TextStyle(color: Colors.black, fontSize: 22.0)),
              content: Container(
                width: double.maxFinite,
                child: ListView(
                    shrinkWrap: true,
                  children: [TableCalendar(
                    firstDay: DateTime(2022, 2, 13),
                    lastDay: DateTime.now(),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    calendarFormat: _calendarFormat,
                    rangeSelectionMode: _rangeSelectionMode,
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _rangeStart = null; // Important to clean those
                          _rangeEnd = null;
                          _rangeSelectionMode = RangeSelectionMode.toggledOff;
                        });
                      }
                    },
                    onRangeSelected: (start, end, focusedDay) {
                      setState(() {
                        _selectedDay = null;
                        _focusedDay = focusedDay;
                        _rangeStart = start;
                        _rangeEnd = end;
                        _rangeSelectionMode = RangeSelectionMode.toggledOn;
                      });
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),]
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    "Ok",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onPressed: () {

                  },
                ),
              ]);
        });
  }

}