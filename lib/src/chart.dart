import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notifiers.dart';

class CurrencyGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Graph')),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Text(
                  'Currency of 1 ${Provider.of<ChartModel>(context).selectedCur.name} in RUB'),
              SizedBox(height: 100),
              _buildChart(context),
            ],
          )),
    );
  }

  Widget _buildChart(context) {
    final _chart = Provider.of<ChartModel>(context);
    final height = MediaQuery.of(context).size.height;
    _chart.loadGraph();
    if (_chart.seriesList.isNotEmpty) {
      return SizedBox(
        height: height/2,
        child: charts.TimeSeriesChart(
            _chart.seriesList,
            animate: false,
            dateTimeFactory: charts.LocalDateTimeFactory(),
          ),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
