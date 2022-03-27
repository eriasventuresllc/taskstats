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
  int max = 0;
  int min = 999;
  Map<String, int> totalData = {};
  List<BarChartGroupData> analyzeData = [];
  Map<String, int> storedData = {};
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

  @override
  void initState() {
    super.initState();
  }

  void refresh() {
    setState(() {});
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
      body: Padding(
        padding: const EdgeInsets.only(left: 34, right: 20, top: 25),
        child: SizedBox(
          width: 400,
          height: 450,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                //maxY: max.toDouble() + 5,
                //minY: min.toDouble(),
                barTouchData: BarTouchData(
                  enabled: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    showTitles: true,
                    //getTextStyles: (value) =>  TextStyle(color: Color(0xffffffff), fontWeight: FontWeight.bold, fontSize: 13),
                    margin: 15,
                    rotateAngle: 310,
                    getTitles: (double value) {
                      return storedData.keys.firstWhere((k) => storedData[k] == value.toInt());
                    },
                  ),
                  leftTitles: SideTitles(
                    showTitles: false,
                  ),
                  topTitles: SideTitles(
                    showTitles: false
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
                      storedData.clear();
                      analyzeData.clear();
                      max = 0;
                      min = 999;
                      var rangedData = await data.getAnalyticsForRange(_rangeStart!, _rangeEnd!);
                      for (var element in rangedData.docs) {
                        var data = element.data();
                          var keyData = Map<String, dynamic>.from(data as Map<String, dynamic>); //for some reason I need this?
                          int dur = keyData['duration'];
                          String task = keyData['task'];
                          if(storedData.containsKey(task)) {
                            storedData[task] = storedData[task]! + dur;
                          } else {
                            storedData[task] = dur;
                          }
                      }
                      var t = storedData.entries.toList()..sort((e1, e2) {
                        var diff = e2.value.compareTo(e1.value);
                        if (diff == 0) diff = e2.key.compareTo(e1.key);
                        return diff;
                      });
                      storedData = Map<String, int>.fromEntries(t);
                      storedData.forEach((key, value) {
                        if (value > max)
                          max = value;
                        if (value < min)
                          min = value;
                        BarChartGroupData ele = BarChartGroupData(
                          x: value,
                          barRods: [
                            BarChartRodData(
                                colors: [const Color.fromRGBO(239, 83, 80, 1), Colors.red],
                                toY: value.toDouble())
                          ],
                        );
                        analyzeData.add(ele);
                      });
                      Navigator.of(context).pop(true);
                      refresh();
                    },
                  ),
                ]);
          });
        });
  }
}
