import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Taskstats',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController addController = TextEditingController();
  late Data data;
  TextStyle style = TextStyle(color: Colors.black, fontSize: 24);
  TextEditingController textController = TextEditingController();
  List<Widget> tasks = [];
  bool flag = true;
  Stream<int>? timerStream;
  StreamSubscription<int>? timerSubscription;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';
  int totalSec = 0;
  int recordingIndex = 0;
  List<Color> colors = [Colors.blue, Colors.red];

  @override
  void initState() {
    data = Data();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rowTasks = [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$hoursStr:$minutesStr:$secondsStr",
            style: const TextStyle(
              fontSize: 40.0,
            ),
          ),
        ],
      ),
    ];
    rowTasks += buildRows();
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Text(
          '+',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        onPressed: () => _showAddDialog(),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            //mainAxisSize: MainAxisSize.min,
            children: rowTasks,
          ),
        ),
      ),
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
              content: TextFormField(
                keyboardType: TextInputType.text,
                maxLines: 1,
                controller: textController,
                decoration: const InputDecoration(
                    hintText: 'Task Name',
                    prefixIcon: Icon(
                      Icons.add_task,
                      color: Colors.grey,
                    ),
                    disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue))),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    "Add",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    tasks.add(taskWidget(textController.text));
                    textController.text = '';
                    setState(() {});
                  },
                ),
              ]);
        });
  }

  List<Widget> buildRows() {
    List<Widget> rows = [];
    for (int x = 0; tasks.length > x; x += 2) {
      Row row;
      // check to make sure we don't so something silly
      if (x + 2 > tasks.length) {
        row = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            tasks[x],
          ],
        );
      } else {
        row = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            tasks[x],
            tasks[x + 1],
          ],
        );
      }
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Center(child: row),
      ));
    }
    return rows;
  }

  Stream<int> stopWatchStream() {
    StreamController<int>? streamController;
    Timer? timer;
    Duration? timerInterval = const Duration(seconds: 1);
    int counter = 0;

    void stopTimer() async {
      //List<dynamic> tmp = await data.getData();
      if (timer != null) {
        timer!.cancel();
        timer = null;
        counter = 0;
        streamController!.close();
      }
    }

    void tick(_) {
      counter++;
      streamController!.add(counter);
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  Widget taskWidget(name) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 150,
        height: 110,
        child: MaterialButton(
          child: Text(
            name,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () {
            if (timerSubscription == null) {
              registerTimer();
            } else {
              print(totalSec);
              timerSubscription!.cancel();
              timerSubscription = null;
              registerTimer();
            }
          },
          color: Colors.blue,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
        ),
      ),
    );
  }

  void registerTimer() {
    timerStream = stopWatchStream();
    timerSubscription = timerStream!.listen((int newTick) {
      totalSec = newTick;
      setState(() {
        hoursStr =
            ((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
        minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
        secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
      });
    });
  }

  Widget rowDecorator(name, time) {
    TextEditingController textController2 = TextEditingController();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          child: EditableText(
            controller: textController2,
            style: style,
            cursorColor: Colors.black,
            focusNode: FocusNode(),
            backgroundCursorColor: Colors.red,
          ),
          width: 200,
          height: 50,
        ),
        Text(
          time.toString(),
          style: style,
        )
      ],
    );
  }
}
