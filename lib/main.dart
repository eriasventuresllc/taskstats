import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:retro/sign_in.dart';

import 'analyze.dart';
import 'data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    FirebaseApp app = await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCxQJX--m232XrqN-LJmpIE5bWYynShXDU',
        databaseURL: 'https://taskstats-5bd3c.firebaseio.com',
        projectId: 'taskstats-5bd3c',
        storageBucket: 'taskstats-5bd3c.appspot.com',
        messagingSenderId: '1031691115800',
        appId: '1:1031691115800:ios:3c233a3ee49eabab78126d',
      ),
    );
    FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
  } else {
    FirebaseApp app = await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDPWXvH0hn6GGCx3dDel2ya6-xhvrZKM-w',
        databaseURL: 'https://taskstats-5bd3c.firebaseio.com',
        projectId: 'taskstats-5bd3c',
        storageBucket: 'taskstats-5bd3c.appspot.com',
        messagingSenderId: '1031691115800',
        appId: '1:1031691115800:android:492d854b5504b5cc78126d',
      ),
    );
    FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
  }
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  TextStyle style = const TextStyle(color: Colors.black, fontSize: 24);
  TextEditingController textController = TextEditingController();
  Map<String, Widget> tasks = {};
  bool flag = true;
  Stream<int>? timerStream;
  StreamSubscription<int>? timerSubscription;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';
  int totalSec = 0;
  int startTime = 0;
  bool hasAlreadyLoaded = false;
  String recordingName = '';

  @override
  void initState() {
    super.initState();
    data = Data();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  void loadTables() async {
    List<String> tmp = await data.getActivities();
    for (int x = 0; x < tmp.length; ++x) {
      tasks.addAll({tmp[x]: taskWidget(tmp[x])});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rowTasks = [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => stopTimer(),
            child: Text(
              "$hoursStr:$minutesStr:$secondsStr",
              style: const TextStyle(fontSize: 36.0, color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "Activity: " + recordingName,
              style: const TextStyle(fontSize: 20.0, color: Colors.black),
            ),
          ),
        ],
      ),
    ];
    rowTasks += buildRows();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 2,
        title: const Text("Taskstat", style: TextStyle(color: Colors.white, fontSize: 24)),
        actions:  [
          IconButton(onPressed: () {
            if (Platform.isAndroid) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Analyze()));
            } else {
              Navigator.push(context, CupertinoPageRoute(builder: (context) => Analyze()));
            }
          }, icon: const Icon(Icons.analytics))
        ],
      ),
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
          padding: const EdgeInsets.all(5),
          child: FutureBuilder<List<String>>(
              future: data.getActivities(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.blue,
                  ));
                } else if (!hasAlreadyLoaded) {
                  List<String> tmp = snapshot.data!.toList();
                  for (int x = 0; x < tmp.length; ++x) {
                    tasks.addAll({tmp[x]: taskWidget(tmp[x])});
                  }
                  rowTasks += buildRows();
                  hasAlreadyLoaded = true;
                }
                return ListView(
                  children: rowTasks,
                );
              }),
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
                    tasks.addAll(
                        {textController.text: taskWidget(textController.text)});
                    data.saveTask(textController.text);
                    textController.text = '';
                    setState(() {});
                  },
                ),
              ]);
        });
  }

  void submitTask() {
    DateTime now = DateTime.now();
    String date = data.formatCurrentDate(now);
    data.setSaveTask(date, recordingName, startTime, now.millisecondsSinceEpoch, totalSec);
  }

  List<Widget> buildRows() {
    List<Widget> rows = [];
    List<Widget> task = tasks.values.toList();
    for (int x = 0; tasks.length > x; x += 2) {
      Row row;
      // check to make sure we don't so something silly
      if (x + 2 > tasks.length) {
        row = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            task[x],
          ],
        );
      } else {
        row = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            task[x],
            task[x + 1],
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
      // List<dynamic> tmp = await data.getData();
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
    // Color color = Colors.blue;
    // if(recordingName == name) {
    //   color = Colors.red;
    // }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 150,
        height: 110,
        child: MaterialButton(
          child: Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () {
            if (timerSubscription == null) {
              registerTimer();
            } else {
              timerSubscription!.cancel();
              timerSubscription = null;
              submitTask();
              registerTimer();
            }
            recordingName = name;
            setState(() {});
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
    DateTime now = DateTime.now();
    startTime = now.millisecondsSinceEpoch;
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

  void stopTimer() {
    if (timerSubscription != null) {
      timerSubscription!.cancel();
      timerSubscription = null;
      totalSec = 0;
      hoursStr = '00';
      minutesStr = '00';
      secondsStr = '00';
      submitTask();
      recordingName = "";
      setState(() {});
    }
  }

  Widget rowDecorator(name, time) {
    TextEditingController textController2 = TextEditingController();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
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
