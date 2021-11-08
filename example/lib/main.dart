import 'package:example/dropdownBelowTest.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _testList = [
    {'no': 1, 'keyword': 'blue'},
    {'no': 2, 'keyword': 'black'},
    {'no': 3, 'keyword': 'red'}
  ];
  List<DropdownMenuItem<Object?>> _dropdownTestItems = [];
  var _selectedTest;

  @override
  void initState() {
    _dropdownTestItems = buildDropdownTestItems(_testList);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DropdownMenuItem<Object?>> buildDropdownTestItems(List _testList) {
    List<DropdownMenuItem<Object?>> items = [];
    for (var i in _testList) {
      items.add(
        DropdownMenuItem(
          value: i,
          child: Text(i['keyword']),
        ),
      );
    }
    return items;
  }

  onChangeDropdownTests(selectedTest) {
    print(selectedTest);
    setState(() {
      _selectedTest = selectedTest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black12,
        appBar: AppBar(
          title: Text('dropdown below example'),
        ),
        body: Center(
            child: Column(
              children: [
                DropdownBelow(
                  itemWidth: 100,
                  itemTextstyle: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
                  boxTextstyle: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white54),
                  boxPadding: EdgeInsets.fromLTRB(13, 12, 13, 12),
                  boxWidth: 100,
                  boxHeight: 45,
                  boxDecoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(width: 1, color: Colors.white54)),
                  icon: Icon(
                        Icons.settings,
                        color: Colors.white54,
                  ),
                  hint: Text('Filter'),
                  value: _selectedTest,
                  items: _dropdownTestItems,
                  onChanged: onChangeDropdownTests,
                ),
                TextField(),
                ElevatedButton(
                    onPressed: () {

                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },
                child: Text('focus out button'))
              ],
            )
        )
    );
  }
}
