import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: 'Lecture Schedule'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String batch = 'A1';
  String dayOfWeek = DateFormat('EEEE').format(DateTime.now());
  Map<String, dynamic> data = {};
  List<String> timeSlots = [
    "8AM to 9AM",
    "9AM to 11AM",
    "11AM to 1PM",
    "1PM to 2PM",
    "2PM to 4PM",
    "4PM to 5PM",
    "5PM to 6PM"
  ];
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];

  @override
  void initState() {
    super.initState();
    loadBatch().then((value) => setState(() {
          batch = value;
        }));
    loadJsonData();
  }

  Future<void> saveBatch(String batch) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('batch', batch);
  }

  Future<String> loadBatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('batch') ?? 'A1';
  }

  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/data');
    Map<String, dynamic> jsonData = json.decode(jsonString);

    if (jsonData.containsKey(batch) && jsonData[batch].containsKey(dayOfWeek)) {
      setState(() {
        for (int i = 0; i < 7; i++) {
          if (jsonData[batch][dayOfWeek].containsKey(timeSlots[i])) {
            data = jsonData;
          }
        }
      });
    } else {
      print('The batch or dayOfWeek does not exist in the JSON data');
    }
  }

  Widget buildTimelineTile(
      bool isFirst, bool isLast, String heading, String data, bool isCurrent) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.1,
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(
        color: isCurrent ? Colors.deepPurple : Colors.purpleAccent,
      ),
      afterLineStyle: LineStyle(
        color: isCurrent ? Colors.deepPurple : Colors.purpleAccent,
      ),
      indicatorStyle: IndicatorStyle(
        width: 60,
        color: isCurrent ? Colors.deepPurple : Colors.purpleAccent,
        indicator: Container(
          decoration: BoxDecoration(
            color: isCurrent ? Colors.deepPurple : Colors.purpleAccent,
            shape: BoxShape.circle,
          ),
        ),
      ),
      endChild: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(heading,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20)), // Increased font size
            const Divider(
              color: Colors.black,
            ),
            const SizedBox(height: 5),
            Text(data,
                style: const TextStyle(fontSize: 18)), // Increased font size
          ],
        ),
      ),
    );
  }

  bool isCurrentTimeSlot(String timeSlot) {
    var now = DateTime.now();
    var currentTime =
        now.hour * 60 + now.minute; // convert current time to minutes

    var times = timeSlot.split(" to ");
    var startTime =
        int.parse(times[0].replaceAll("AM", "").replaceAll("PM", "").trim()) *
            60;
    var endTime =
        int.parse(times[1].replaceAll("AM", "").replaceAll("PM", "").trim()) *
            60;

    // Adjust for PM times
    if (times[0].contains("PM") && !times[0].startsWith("12"))
      startTime += 12 * 60;
    if (times[1].contains("PM") && !times[1].startsWith("12"))
      endTime += 12 * 60;

    return currentTime >= startTime && currentTime < endTime;
  }

  @override
  Widget build(BuildContext context) {
    if (dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Lecture Schedule : $batch",
            style: const TextStyle(
              fontSize: 30,
              fontFamily: "Caveat",
            ),
          ),
          backgroundColor: Colors.amber,
        ),
        body: const Center(
          child: Text(
            "Holiday!! \nLet's hope for no buffer",
            style: TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 241, 184, 163),
        appBar: AppBar(
          title: Text(
            "Lecture Schedule : $batch",
            style: const TextStyle(
              fontSize: 30,
              fontFamily: "Caveat",
            ),
          ),
          backgroundColor: Colors.amber,
          actions: <Widget>[
            DropdownButton<String>(
              value: batch,
              dropdownColor: Colors.amber,
              icon: const Icon(Icons.arrow_downward, color: Colors.deepPurple),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              underline: Container(
                height: 2,
                color: Colors.black,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  batch = newValue!;
                  saveBatch(batch);
                });
              },
              items: <String>[
                'A1',
                'A2',
                'A3',
                'A4',
                'A5',
                'A6',
                'B1',
                'B2',
                'B3',
                'B4',
                'B5',
                'B6',
                'B7'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        body: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: DropdownButton<String>(
                value: dayOfWeek,
                alignment: Alignment.topRight,
                dropdownColor: Colors.amber,
                icon: const Icon(Icons.arrow_downward, color: Colors.black),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.black, fontSize: 20),
                onChanged: (String? newValue) {
                  setState(() {
                    dayOfWeek = newValue!;
                    loadJsonData();
                  });
                },
                items: daysOfWeek.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: const TextStyle(
                          fontSize: 20,
                        )),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                children: [
                  for (int i = 0; i < 7; i++) ...[
                    if (data[batch] != null &&
                        data[batch][dayOfWeek] != null &&
                        data[batch][dayOfWeek][timeSlots[i]] != null)
                      buildTimelineTile(
                        i == 0,
                        i == 6,
                        timeSlots[i],
                        data[batch][dayOfWeek][timeSlots[i]],
                        isCurrentTimeSlot(timeSlots[i].toString()),
                      )
                  ]
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: const Text(
                          'Developed by Arun Kumar',
                          style: TextStyle(fontSize: 25, fontFamily: "Caveat"),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('About'),
              ),
            ),
          ],
        ),
      );
    }
  }
}
