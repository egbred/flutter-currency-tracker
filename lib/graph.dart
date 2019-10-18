import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:xml2json/xml2json.dart';
import 'currency.dart';
import 'package:intl/intl.dart';

class CurrencyGraph extends StatefulWidget {
  final DateTime toDate;
  final DateTime fromDate;
  final CurrencyData curId;
  CurrencyGraph({Key key, @required this.fromDate, this.toDate, @required this.curId}) : super(key : key);
  @override
  State<StatefulWidget> createState() {
    return CurrencyGraphState();
  }
}

class CurrencyGraphState extends State<CurrencyGraph> {
  List<charts.Series<CurrencyData, DateTime>> _seriesList = [];
  String _answer = 'Data is loading...';

  @override
  Widget build(BuildContext context) {
    String curName = widget.curId.name;
    if(_seriesList.isNotEmpty) {
      return Scaffold(
          appBar: AppBar(title: Text('Graph')),
          body: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Center(child: Text('Currency of $curName in RUB')),
                Container (
                  width: 450,
                  height: 600,
                  child: new charts.TimeSeriesChart(
                    _seriesList,
                    animate: false,
                    dateTimeFactory: const charts.LocalDateTimeFactory(),
                  ),
                )
              ],
            ),
          )
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text('Graph')),
        body: Center(child: Text('$_answer')),
      );
    }

  }

  _loadCurrencyGraph(DateTime fromDate, DateTime toDate, CurrencyData cur) async {
      bool _isBigGraph = false;
      if(int.parse(toDate.year.toString()) - int.parse(fromDate.year.toString()) >= 3) _isBigGraph = true;
      if(toDate == null) toDate = DateTime.now();
      String curId = cur.id;
      String reqFromDate = DateFormat('dd/MM/yyyy').format(fromDate);
      String reqToDate = DateFormat('dd/MM/yyyy').format(toDate);
      final response = await http
          .get('http://www.cbr.ru/scripts/XML_dynamic.asp?date_req1=$reqFromDate&date_req2=$reqToDate&VAL_NM_RQ=$curId');
      if(response.statusCode == 200 && reqFromDate != reqToDate) {
        var parsedResponse = xml.parse(response.body);

        final Xml2Json myTransformer = Xml2Json();
        myTransformer.parse(parsedResponse.toString());
        String jsonString = myTransformer.toBadgerfish();
        var allData = (json.decode(jsonString) as Map)['ValCurs']['Record']
        as List<dynamic>;

        var currencyDataList = List<CurrencyData>();
        allData.forEach((dynamic val) {
          var record = CurrencyData(
              price: double.parse(
                  (val['Value']['\$'].toString().replaceAll(',', '.'))) / int.parse(val['Nominal']['\$']),
              date: DateTime.parse(val['@Date'].substring(6, 10) + '-' + val['@Date'].substring(3, 5) + '-' +val['@Date'].substring(0, 2)));
          if(_isBigGraph && record.date.day == 1) {
            currencyDataList.add(record);
          } else if(!_isBigGraph){
            currencyDataList.add(record);
          }
        });

        List<charts.Series<CurrencyData, DateTime>> currencySeriesList = [];
        currencyDataList.forEach((CurrencyData val) {
          var record = charts.Series<CurrencyData, DateTime>(
            id: 'Sales',
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            domainFn: (val, _) => val.date,
            measureFn: (val, _) => val.price,
            data: currencyDataList
          );
          if(record != null) {
            currencySeriesList.add(record);
          }
        });

        setState(() {
          _seriesList = currencySeriesList;
        });
      } else {
        setState(() {
          _answer = 'Bad Gateway.\nCheck Internet connection and both Dates.\n(They can\'t be equal)';
        });
      }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrencyGraph(widget.fromDate, widget.toDate, widget.curId);
  }
}