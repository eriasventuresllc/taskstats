import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
      title: 'RetroTime',
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
  PanelController controller = PanelController();
  bool flag = true;
  Stream<int>? timerStream;
  StreamSubscription<int>? timerSubscription;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';
  late Data data;


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
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SlidingUpPanel(
          maxHeight: 550,
          controller: controller,
          body: Padding(
            padding: const EdgeInsets.only(top: 35),
            child: FutureBuilder(
              future: data.getData(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if(!snapshot.hasData) {
                  return CircularProgressIndicator();
                } else {
                  List<Widget> data = [];
                  for (var ele in snapshot.data) {
                    var row = rowDecorator(ele[0], ele[0]);
                    data.add(row);
                  }
                  return ListView(
                    children: data,
                  );
                }
            },),
          ),
          panel: Column(children: [
            Row(
              children: [
              Container(
                width: 50,
                height: 7,
                decoration: const BoxDecoration(color: Colors.black38,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
              ),
            ],),
            Row(
              children: [
                Text(
                  "$hoursStr:$minutesStr:$secondsStr",
                  style: const TextStyle(
                    fontSize: 70.0,
                  ),
                ),
                const SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      onPressed: () {
                        timerStream = stopWatchStream();
                        timerSubscription = timerStream!.listen((int newTick) {
                          setState(() {
                            hoursStr = ((newTick / (60 * 60)) % 60)
                                .floor()
                                .toString()
                                .padLeft(2, '0');
                            minutesStr = ((newTick / 60) % 60)
                                .floor()
                                .toString()
                                .padLeft(2, '0');
                            secondsStr =
                                (newTick % 60).floor().toString().padLeft(2, '0');
                          });
                        });
                      },
                      color: Colors.green,
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40.0),
                    RaisedButton(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      onPressed: () {
                        timerSubscription!.cancel();
                        timerStream = null;
                        setState(() {
                          hoursStr = '00';
                          minutesStr = '00';
                          secondsStr = '00';
                        });
                      },
                      color: Colors.red,
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ]),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  Widget rowDecorator(name, time) {
    return Row(
      children: [Text(name), Text(time)],
    );
  }

  Stream<int> stopWatchStream() {
    StreamController<int>? streamController;
    Timer? timer;
    Duration? timerInterval = const Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
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

}
