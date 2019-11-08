import 'package:currency_app/src/currency.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
import 'package:currency_app/src/notifiers.dart';
import 'package:intl/intl.dart';
import 'package:currency_app/src/chart.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      builder: (_) => ListModel(),
    ),
    ChangeNotifierProvider(
      builder: (_) => ChartModel(),
    )
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Tracker',
      theme: _appTheme,
      routes: {
        '/': (context) => CurrencyList(),
        '/chart': (context) => CurrencyGraph(),
      },
    );
  }

  final _appTheme = ThemeData(
      accentColor: Colors.lightGreen[800],
      primaryColor: Colors.amber[700],
      dividerTheme: DividerThemeData(
          color: Colors.amber[600], thickness: 0.5, space: 0.0),
      buttonTheme: ButtonThemeData(
          buttonColor: Colors.lightGreen[800],
          disabledColor: Colors.grey,
          textTheme: ButtonTextTheme.primary),
      textTheme: TextTheme(
          title: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          subtitle: TextStyle(color: Colors.grey[500]),
          body1: TextStyle(fontSize: 16.0)));
}

class CurrencyList extends StatefulWidget {
  CurrencyList({Key key}) : super(key: key);

  @override
  _CurrencyListState createState() => _CurrencyListState();
}

class _CurrencyListState extends State<CurrencyList> {
  @override
  Widget build(BuildContext context) {
    final _lModel = Provider.of<ListModel>(context);
    final _cModel = Provider.of<ChartModel>(context);
    return BackdropScaffold(
        title: Text('Currency'),
        headerHeight: 32.00,
        iconPosition: BackdropIconPosition.action,
        frontLayer: Column(children: <Widget>[
          _topDatePicker(),
          Divider(),
          Expanded(
              child: ListView.separated(
                  itemCount: _lModel.currencyList.length,
                  separatorBuilder: (BuildContext context, int i) => Divider(),
                  itemBuilder: (BuildContext context, int i) {
                    return ListTile(
                      title: Text(
                          _lModel.currencyList[i].nominal.toString() +
                              ' ' +
                              _lModel.currencyList[i].name,
                          style: Theme.of(context).textTheme.subtitle),
                      leading: CircleAvatar(
                          child: Text(_lModel.currencyList[i].charCode),
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context).accentColor),
                      trailing: Text(
                          '= ' +
                              _lModel.currencyList[i].price.toStringAsFixed(2) +
                              ' RUB',
                          style: TextStyle(fontSize: 16.0)),
                    );
                  })),
        ]),
        backLayer: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child:
                        Text('Graph', style: Theme.of(context).textTheme.title),
                  ),
                  _buildDropdownButton(),
                  Wrap(spacing: 12.0, children: <Widget>[
                    RaisedButton(
                        child: Text('DateFrom'),
                        onPressed: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: _cModel.fromDate,
                                  firstDate: DateTime(1992, 07),
                                  lastDate: _cModel.toDate)
                              .then((DateTime val) {
                            if (val != null) {
                              _cModel.setFromDate(val);
                            }
                          });
                        }),
                    RaisedButton(
                      child: Text('DateTo'),
                      onPressed: () {
                        showDatePicker(
                                context: context,
                                initialDate: _cModel.toDate,
                                firstDate: _cModel.fromDate,
                                lastDate: DateTime.now())
                            .then((DateTime val) {
                          if (val != null) {
                            _cModel.setToDate(val);
                          }
                        });
                      },
                    ),
                    RaisedButton(
                        disabledColor: Colors.blueGrey[600],
                        disabledTextColor: Colors.white,
                        child: Text('Build'),
                        onPressed: _cModel.selectedCur == null || _cModel.toDate.isAtSameMomentAs(_cModel.fromDate)
                            ? null
                            : () {
                                Navigator.pushNamed(context, '/chart');
                              })
                  ]),
                ],
              ),
            )));
  }

  Widget _buildDropdownButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text('Currency:', style: Theme.of(context).textTheme.body1),
        DropdownButton<Currency>(
          underline: Divider(color: Colors.black),
          hint: Text('Choose'),
          value: Provider.of<ChartModel>(context).selectedCur,
          onChanged: (Currency newValue) {
            Provider.of<ChartModel>(context).setCurrency(newValue);
          },
          items: Provider.of<ListModel>(context)
              .currencyList
              .map<DropdownMenuItem<Currency>>((Currency value) {
            return DropdownMenuItem<Currency>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _topDatePicker() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 7.0, 16.0, 7.0),
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
                DateFormat('dd/MM/yyyy')
                    .format(Provider.of<ListModel>(context).selectedDate),
                style: Theme.of(context).textTheme.title),
            RaisedButton(
              onPressed: () {
                showDatePicker(
                        context: context,
                        initialDate:
                            Provider.of<ListModel>(context).selectedDate,
                        firstDate: DateTime(1992, 07),
                        lastDate: DateTime.now())
                    .then((DateTime val) {
                  if (val != null) {
                    Provider.of<ListModel>(context).setDate(val);
                  }
                });
              },
              child: Text('Pick Date'),
              elevation: 4.0,
            )
          ]),
    );
  }
}
