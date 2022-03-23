import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

import 'data.dart';

class Analyze extends StatefulWidget {
  const Analyze({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AnalyzeState();
}

class AnalyzeState extends State<Analyze> {
  Map<String, int> totalData = {};
  List<BarChartGroupData> analyzeData = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime dateMinusYear = DateTime.now();
  Data data = Data();

  AnalyzeState() {
    dateMinusYear = DateTime(dateMinusYear.year-1,
        dateMinusYear.month, dateMinusYear.day);
  }

  void requestData() async {
    for (int x = 0; x < 10; ++x) {
      BarChartGroupData ele = BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
              colors: [const Color.fromRGBO(239, 83, 80, 1), Colors.red],
              toY: 15.0)
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
        title: const Text("Analyze",
            style: TextStyle(color: Colors.white, fontSize: 24)),
        actions: [
          IconButton(
              onPressed: () => _showAddDialog(),
              icon: const Icon(Icons.calendar_today))
        ],
      ),
      body: Stack(children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
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
                        swapAnimationDuration:
                            const Duration(milliseconds: 600),
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
          return StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                backgroundColor: Colors.white,
                title: const Text("View Tasks",
                    style: TextStyle(color: Colors.black, fontSize: 22.0)),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: TableCalendar(
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      headerPadding: EdgeInsets.symmetric(vertical: 17),
                    ),
                    firstDay: dateMinusYear,
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
                      print(start);
                      print(end);
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
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      "Ok",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    onPressed: () async {
                      //print('here');
                      // wip
                      QuerySnapshot tmp = await data.getAnalyticsForRange(
                          _rangeStart!, _rangeEnd!);
                      tmp.docs.forEach((element) {
                        var data = element.data();
                        var tmp = Map<dynamic, dynamic>.from(data as Map<dynamic, dynamic>);
                        //var tmp = jsonDecode(data.toString());
                        String task = element.get('task');
                        int dur = element.get('duration');
                        if(totalData.containsKey(task)) {
                          totalData[task] = totalData[task]! + dur;
                        } else {
                          totalData[task] = dur;
                        }
                      });
                      print(totalData);
                      Navigator.pop(context);
                    },
                  ),
                ]);
          });
        });
  }
}
