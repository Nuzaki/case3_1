import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MaterialApp(
      home: FlutterDemo(storage: CounterStorage()),
    ),
  );
}

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    return file.writeAsString('$counter');
  }
}

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({Key? key, required this.storage}) : super(key: key);

  final CounterStorage storage;

  @override
  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  int _counter = 0;
  int _counterShared = 0;

  @override
  void initState() {
    super.initState();
    widget.storage.readCounter().then((int value) {
      setState(() {
        _counter = value;
      });
    });
    _loadCounter();
  }

  void _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counterShared = (prefs.getInt('counterSharedPrefs') ?? 0);
    });
  }

  void _sharedCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counterShared = (prefs.getInt('counterSharedPrefs') ?? 0) + 4;
      prefs.setInt('counterSharedPrefs', _counterShared);
    });
  }

  Future<File> _incrementCounter() {
    setState(() {
      _counter += 2;
    });

    return widget.storage.writeCounter(_counter);
  }

  sum() {
    var total = _counter + _counterShared;
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.pink,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
                child: const Text('Прибавить 2 (обычн.)'),
                onPressed: () {
                  setState(() {
                    _incrementCounter();
                  });
                }),
            Text(
              'Результат $_counter',
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
                child: const Text('Прибавить 4 (SharedPreferences)'),
                onPressed: () {
                  setState(() {
                    _sharedCounter();
                    _loadCounter;
                  });
                }),
            Text(
              'Результат $_counterShared',
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
                child: const Text('Очистить'),
                onPressed: () {
                  setState(() {
                    _removeShared();
                    _clearFile();
                    _loadCounter();
                  });
                }),
          ]),
        ));
  }

  Future _clearFile() {
    setState(() {
      _counter = 0;
    });
    return widget.storage.writeCounter(_counter);
  }

  Future _removeShared() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove('counterSharedPrefs');
  }
}
