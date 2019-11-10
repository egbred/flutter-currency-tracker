import 'dart:convert';
import 'package:backdrop/backdrop.dart';
import 'currency.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:xml2json/xml2json.dart';
import 'package:intl/intl.dart';
import 'graph.dart' as graph;

class CurrencyList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CurrencyListState();
  }
}

class CurrencyListState extends State<CurrencyList> {
  List<CurrencyData> data = [];
  CurrencyData _btnSelectedCur;
  var _btnDateFrom = DateTime.now();
  var _btnDateTo = DateTime.now();
  var _btnDateList = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(
      title: Text('Currency Tracker'),
      headerHeight: 500.0,
      iconPosition: BackdropIconPosition.action,
      frontLayer: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16.0, 7.0, 16.0, 7.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget> [
                Text('$_btnDateList', style: Theme.of(context).textTheme.title),
                RaisedButton(
                  onPressed: () {
                    showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1992),
                        lastDate: DateTime.now()).then((DateTime val)
                    {if(val != null) {
                      _loadCurrencyList(val);
                    }});
                  },
                  child: Text('Pick Date'),
                  elevation: 4.0,
                )
              ]
            ),
          ),
          Divider(),
            Expanded(
                child: ListView.builder(
                    itemCount: data.length * 2 - 1,
                    itemBuilder: (BuildContext context, int i) {
                      if (i.isEven) {
                        int x = (i/2).round();
                        return ListTile(
                          title: Text(
                              data[x].nominal.toString() + ' ' + data[x].name, style: Theme.of(context).textTheme.subtitle),
                          leading: CircleAvatar(
                              child: Text(data[x].charCode),
                              foregroundColor: Colors.white,
                              backgroundColor: Theme.of(context).accentColor),
                          trailing: Text(
                              '= ' + data[x].price.toStringAsFixed(2) + ' RUB', style: TextStyle(
                            fontSize: 16.0
                          )),
                        );
                      } else {
                        return Divider();
                      }
                    })
            )
          ],
        ),

      backLayer: Padding(
        padding: EdgeInsets.fromLTRB(16.00, 8.00, 16.00, 16.00),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text('Graph', style: Theme.of(context).textTheme.title),
            ),
            buildDropdownButton(),
            Wrap(
                spacing: 12.0,
                children: <Widget>[
                  RaisedButton(
                      child: Text('DateFrom'),
                      onPressed: () {
                        showDatePicker(
                            context: context,
                            initialDate: _btnDateFrom,
                            firstDate: DateTime(1992, 07),
                            lastDate: _btnDateTo).then((DateTime val) {
                          if (val != null) {
                            setState(() {
                              _btnDateFrom = val;
                            });
                          }
                        });
                      }
                  ),
                  RaisedButton(
                    child: Text('DateTo'),
                    onPressed: () {
                      showDatePicker(
                          context: context,
                          initialDate: _btnDateTo,
                          firstDate: _btnDateFrom,
                          lastDate: DateTime.now()).then((DateTime val) {
                        if (val != null) {
                          setState(() {
                            _btnDateTo = val;
                          });
                        }
                      });
                    },
                  ),
                  RaisedButton(
                      disabledColor: Colors.blueGrey[600],
                      disabledTextColor: Colors.white,
                      child: Text('Build'),
                      onPressed: _btnSelectedCur == null ? null : () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => graph.CurrencyGraph(fromDate: _btnDateFrom, toDate: _btnDateTo, curId: _btnSelectedCur)
                        ));
                      }
                  )
                ]),
          ],
        ),
      )
    );
  }

  _loadCurrencyList(DateTime selectedDate) async {
    if (selectedDate == null) selectedDate = DateTime.now();
    String reqDate = DateFormat('dd/MM/yyyy').format(selectedDate);
    final response = await http
        .get('http://www.cbr.ru/scripts/XML_daily_eng.asp?date_req=$reqDate');
    if (response.statusCode == 200) {
      var parsedResponse = xml.parse(response.body);
      final Xml2Json myTransformer = Xml2Json();
      myTransformer.parse(parsedResponse.toString());
      String jsonString = myTransformer.toBadgerfish();
      var allData = (json.decode(jsonString) as Map)['ValCurs']['Valute']
      as List<dynamic>;
      if (allData != null) {
        var currencyDataList = List<CurrencyData>();
        allData.forEach((dynamic val) {
          var record = CurrencyData(
              name: val['Name']['\$'],
              charCode: val['CharCode']['\$'],
              nominal: int.parse(val['Nominal']['\$']),
              price: double.parse(
                  (val['Value']['\$'].toString().replaceAll(',', '.'))),
              date: selectedDate,
              id: val['@ID']);
          currencyDataList.add(record);
        });

        currencyDataList.add(CurrencyData(
            name: 'Russian Ruble',
            id: '0',
            nominal: 1,
            price: 1.0,
            charCode: 'RUB',
            date: selectedDate));

        setState(() {
          _btnDateList = reqDate;
          data = currencyDataList;
        });
      } else {
        _callBottomSheet();
      }
    }
  }

  _callBottomSheet() {
    showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext context) => Container(
          decoration: BoxDecoration(
            color: Colors.amber[300],
          ),
          child: ListView(
            shrinkWrap: true,
            primary: true,
            children: <Widget>[
              ListTile(
                dense: true,
                title: Text('No data for the requested Date'),
              ),
              ListTile(
                dense: true,
                title: Text('Try to pick another one'),
                subtitle: Text('Tap anywhere on Screen to dismiss'),
              )
            ],
          ),
    ));
  }

  @override
  void initState() {
    super.initState();
    _loadCurrencyList(DateTime.now());
  }

  Widget buildDropdownButton() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: const Text('Currency:'),
            trailing: DropdownButton<CurrencyData>(
              underline: Divider(color: Colors.black),
              hint: Text('Choose'),
              value: _btnSelectedCur,
              onChanged: (CurrencyData newValue) {
                setState(() {
                  _btnSelectedCur = newValue;
                });
              },
              items: data
                  .map<DropdownMenuItem<CurrencyData>>((CurrencyData value) {
                return DropdownMenuItem<CurrencyData>(
                  value: value,
                  child: Text(value.name),
                );
              })
                  .toList(),
            ),
          ),
        ],
      );
  }
}

