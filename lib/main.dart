import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:retro/timer.dart';
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
  late Data data;
  TextStyle style = TextStyle(color: Colors.black, fontSize: 24);
  TextEditingController textController = TextEditingController();


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
                  return SizedBox(child: CircularProgressIndicator(),);
                } else {
                  List<Widget> data = [];
                  List<dynamic> fromSP = List.from(snapshot.data);
                  for(int x = 0; x < fromSP.length; ++x) {
                    var t = fromSP[x];
                    var row = rowDecorator(t.keys.first, t.values.first);
                    data.add(row);
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: data,
                  );
                }
            },),
          ),
          panel: TimerTime(),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  Widget rowDecorator(name, time) {
    TextEditingController textController2 = TextEditingController();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [Container(child:EditableText(controller: textController2, style: style,
        cursorColor: Colors.black, focusNode: FocusNode(),
        backgroundCursorColor: Colors.red,), width: 200, height: 50,),
        Text(time.toString(), style: style,)],
    );
  }
}
