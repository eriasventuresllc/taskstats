import 'dart:async';

import 'package:flutter/material.dart';

import 'data.dart';

class TimerTime extends StatefulWidget {
  const TimerTime({Key? key}) : super(key: key);

  @override
  _TimerTimeState createState() => _TimerTimeState();
}

class _TimerTimeState extends State<TimerTime> {
  bool flag = true;
  Stream<int>? timerStream;
  StreamSubscription<int>? timerSubscription;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';
  int totalSec = 0;
  late Data data;

  _TimerTimeState() {
    data = Data();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center ,
          crossAxisAlignment: CrossAxisAlignment.center ,
          children: [
            Container(
              width: 50,
              height: 7,
              decoration: const BoxDecoration(color: Colors.black38,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
          ],),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center ,
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
      Row(
    mainAxisAlignment: MainAxisAlignment.center ,
    crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // RaisedButton(
          //   padding:
          //   const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          //   onPressed: () {
          //     timerStream = stopWatchStream();
          //     timerSubscription = timerStream!.listen((int newTick) {
          //       totalSec = newTick;
          //       setState(() {
          //         hoursStr = ((newTick / (60 * 60)) % 60)
          //             .floor()
          //             .toString()
          //             .padLeft(2, '0');
          //         minutesStr = ((newTick / 60) % 60)
          //             .floor()
          //             .toString()
          //             .padLeft(2, '0');
          //         secondsStr =
          //             (newTick % 60).floor().toString().padLeft(2, '0');
          //       });
          //     });
          //   },
          //   color: Colors.green,
          //   child: const Text(
          //     'Start',
          //     style: TextStyle(
          //       fontSize: 20.0,
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 40.0),
          // RaisedButton(
          //   padding:
          //   const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          //   onPressed: () {
          //     timerSubscription!.cancel();
          //     timerStream = null;
          //     setState(() {
          //       hoursStr = '00';
          //       minutesStr = '00';
          //       secondsStr = '00';
          //     });
          //   },
          //   color: Colors.red,
          //   child: const Text(
          //     'Reset',
          //     style: TextStyle(
          //       color: Colors.white,
          //       fontSize: 20.0,
          //     ),
          //   ),
          // ),
        ],
      )
    ]);
  }

  Stream<int> stopWatchStream() {
    StreamController<int>? streamController;
    Timer? timer;
    Duration? timerInterval = const Duration(seconds: 1);
    int counter = 0;

    void stopTimer() async {
      List<dynamic> tmp = await data.getData();
      tmp.add({"": totalSec});
      data.setData(tmp);
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
