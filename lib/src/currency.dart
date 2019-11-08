import 'package:xml/xml.dart' as xml;
import 'package:xml2json/xml2json.dart';
import 'dart:convert';

class Currency {
  String charCode;
  int nominal;
  double price;
  DateTime date;
  String id;
  String name;

  Currency(
      {this.name, this.id, this.charCode, this.nominal, this.price, this.date});
}

List<Currency> parseCurrencyList(String xmlString) {
  var parsedResponse = xml.parse(xmlString);
  final Xml2Json myTransformer = Xml2Json();
  myTransformer.parse(parsedResponse.toString());
  String jsonString = myTransformer.toBadgerfish();
  var allData =
      (json.decode(jsonString) as Map)['ValCurs']['Valute'] as List<dynamic>;
  var currencyDataList = List<Currency>();
  allData.forEach((dynamic val) {
    var record = Currency(
        name: val['Name']['\$'],
        charCode: val['CharCode']['\$'],
        nominal: int.parse(val['Nominal']['\$']),
        price:
            double.parse((val['Value']['\$'].toString().replaceAll(',', '.'))),
        id: val['@ID']);
    currencyDataList.add(record);
  });
  return currencyDataList;
}

List<Currency> parseCurrencyGraph(String xmlString, bool isBig) {
  var parsedResponse = xml.parse(xmlString);
  final Xml2Json myTransformer = Xml2Json();
  myTransformer.parse(parsedResponse.toString());
  String jsonString = myTransformer.toBadgerfish();
  var allData = (json.decode(jsonString) as Map)['ValCurs']['Record']
  as List<dynamic>;
  var currencyDataList = List<Currency>();
  allData.forEach((dynamic val) {
    var record = Currency(
        price: double.parse(
            (val['Value']['\$'].toString().replaceAll(',', '.'))) /
            int.parse(val['Nominal']['\$']),
        date: DateTime.parse(val['@Date'].substring(6, 10) +
            '-' +
            val['@Date'].substring(3, 5) +
            '-' +
            val['@Date'].substring(0, 2)));
    if (isBig && record.date.day == 1) {
      currencyDataList.add(record);
    } else if (!isBig) {
      currencyDataList.add(record);
    }
  });
  return currencyDataList;

}
