import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'currency.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

class ListModel with ChangeNotifier {
  List<Currency> _currencyList = [];
  List<Currency> get currencyList => _currencyList;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  ListModel() {
    _loadCurrencyList();
  }

  Future<void> _loadCurrencyList() async {
    String reqDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final response = await http
        .get('http://www.cbr.ru/scripts/XML_daily_eng.asp?date_req=$reqDate');
    if (response.statusCode == 200) {
      _currencyList = parseCurrencyList(response.body);
      notifyListeners();
    }
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    _loadCurrencyList();
  }

}

class ChartModel with ChangeNotifier {
  List<charts.Series<Currency, DateTime>> _seriesList = [];
  List<charts.Series<Currency, DateTime>> get seriesList => _seriesList;

  List<Currency> _currencyList = [];
  List<Currency> get currencyList => _currencyList;

  DateTime _fromDate = DateTime.now();
  DateTime get fromDate => _fromDate;
  void setFromDate(DateTime date) => _fromDate = date;

  DateTime _toDate = DateTime.now();
  DateTime get toDate => _toDate;
  void setToDate(DateTime date) => _toDate = date;

  Currency _selectedCur;
  Currency get selectedCur => _selectedCur;
  void setCurrency(Currency cur) {
    _selectedCur = cur;
    notifyListeners();
  }

  ChartModel();

  void loadGraph() {
    if (_selectedCur != null) {
      _loadCurrencyGraph(_fromDate, _toDate, _selectedCur);
    }
  }

  _loadCurrencyGraph(DateTime fromDate, DateTime toDate, Currency cur) async {
    bool _isBigGraph = false;
    if (int.parse(toDate.year.toString()) -
        int.parse(fromDate.year.toString()) >=
        3) _isBigGraph = true;
    if (toDate == null) toDate = DateTime.now();
    final response = await http.get(
        'http://www.cbr.ru/scripts/XML_dynamic.asp?date_req1=${DateFormat(
            'dd/MM/yyyy').format(fromDate)}&date_req2=${DateFormat('dd/MM/yyyy')
            .format(toDate)}&VAL_NM_RQ=${cur.id}');
    if (response.statusCode == 200) {
      _currencyList = parseCurrencyGraph(response.body, _isBigGraph);
      _seriesList.add(
          charts.Series(
            id: 'Sales',
            colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
            domainFn: (Currency f, _) => f.date,
            measureFn: (Currency f, _) => f.price,
            data: _currencyList,
          )
      );
    }
    notifyListeners();
  }
}