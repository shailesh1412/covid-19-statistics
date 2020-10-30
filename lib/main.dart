import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_echarts/flutter_echarts.dart';  
import 'package:pie_chart/pie_chart.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
        
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Covid Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  String x;
  Response res;
  Map<String,dynamic> da;
  @override
void initState() {
  super.initState();
  display();
}

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    Map<String,dynamic> cases=da['cases'];
    Map<String,dynamic> recovered=da['recovered'];
    Map<String,dynamic> deaths=da['deaths'];
    List<dynamic> current_cases=cases.values.toList();
    List<dynamic> current_recovered=recovered.values.toList();
    List<dynamic> current_deaths=deaths.values.toList();
    // print(current_cases.last);
    // print(current_recovered.last);
    // print(current_deaths.last);
    // print(cases.entries);
    // for(MapEntry x in cases.entries)
    // {
    //   print(x);
      
    // }
    charts.Series<Details, String> createSeries(String date, int count) {
    List<Details> data;
    
    // for(MapEntry x in cases.entries)
    // {
    //   print(x);
    //   Details det=Details(x.key,x.value);
    //   data.add(det);
    // }
    return charts.Series<Details, String>(
      id: date,
      domainFn: (Details wear, _) => wear.date,
      measureFn: (Details wear, _) => wear.count,
      // data is a List<LiveWerkzeuge> - extract the information from data
      // could use i as index - there isn't enough information in the question
      // map from 'data' to the series
      // this is a guess
     data: [Details(date,count)]
      
    );
  }
  Widget createChart() {
    // data is a List of Maps
    // each map contains at least temp1 (tool 1) and temp2 (tool 2)
    // what are the groupings?

    List<charts.Series<Details, String>> seriesList = [];

    for(MapEntry x in cases.entries)
    {
      seriesList.add(createSeries(x.key,x.value));
    }

    return new charts.BarChart(
      seriesList,
      barGroupingType: charts.BarGroupingType.stacked,
    );
  }


  Map<String, double> dataMap = {
    "deaths" : current_deaths.last.toDouble(),
    "recovered" : current_recovered.last.toDouble(),
    "live cases": (current_cases.last-current_recovered.last-current_deaths.last).toDouble(),
  };
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        
        child: Center(
          child:da==null? CircularProgressIndicator() :
          Column(
            

            children: <Widget>[
            Text('total cases ${current_cases.last}'),
            Text('total recovered ${current_recovered.last}'),
            Text('total deaths ${current_deaths.last}'),
            Container(
              
              height:200,
              width: 400,
              child: createChart()
              ),
            PieChart(dataMap: dataMap) 
          ],)

        ),
      ),
      // floatingActionButton: new FloatingActionButton(onPressed:(){
      //   display();

      // } ),
    );
  }
     display() async {
      Response re;
    await http.get('https://disease.sh/v3/covid-19/historical/all?lastdays=5').then((Response result){
      setState(() {
        res=result;
        da = json.decode(utf8.decode(result.bodyBytes));
      });      
    });
    

  }


}
class Details{
  final String date;
  final int count;

  Details(this.date, this.count);
  
}