import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const request = "http://api.hgbrasil.com/finance?key=f0c83d46";

void main() async {
  runApp(MaterialApp(
      home: HomeCurrency(),
      theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.blue)));
}

class HomeCurrency extends StatefulWidget {
  @override
  _HomeCurrencyState createState() => _HomeCurrencyState();
}

class _HomeCurrencyState extends State<HomeCurrency> {
  double euro = 0.0;
  double dollar = 0.0;
  

  final br = TextEditingController();
  final usd = TextEditingController();
  final eur = TextEditingController();

  void brFieldChanged(String text){
    if(text.isEmpty){
      usd.text = "";
      eur.text = "";
    }
    double real = double.parse(text);
    usd.text = (real/dollar).toStringAsFixed(2);
    eur.text = (real/euro).toStringAsFixed(2);

  }
  void usdFieldChanged(String text){
    if(text.isEmpty){
      br.text = "";
      eur.text = "";
    }
    br.text = (dollar * double.parse(text)).toStringAsFixed(2);
    eur.text = (double.parse(text) * dollar / euro).toStringAsFixed(2);
    
  }
  void eurFieldChanged(String text){
    if(text.isEmpty){
      usd.text = "";
      br.text = "";
    }
    br.text = (euro * double.parse(text)).toStringAsFixed(2);
    usd.text = (double.parse(text) * euro / dollar).toStringAsFixed(2);

  }

  void clear(){
    br.text = "";
    usd.text = "";
    eur.text = "";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Currency Comparison \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      
      body: FutureBuilder<Map>(
          future: getCurrency(),
          builder: (context, snapData) {
            switch (snapData.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Carregando dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapData.hasError) {
                  return Center(
                      child: Text(
                    "Ouve um erro ao carregar os dados :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  ));
                } else {
                  dollar = snapData.data["USD"]["buy"];
                  euro = snapData.data["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.amber),
                        Divider(),
                        textFieldBuilder("R\$","R\$",br,brFieldChanged),
                        Divider(),
                        textFieldBuilder("U\$D","\$",usd,usdFieldChanged),
                        Divider(),
                        textFieldBuilder("EUR","€",eur,eurFieldChanged)
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget textFieldBuilder(String labelText, String prefixText, TextEditingController controller, Function changed) {
  return TextField(
    onChanged: changed,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.amber),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
      ),
      focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
      prefixText: prefixText,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    controller: controller,
  );
}

Future<Map> getCurrency() async {
  http.Response currencyresponse = await http.get(request);
  print(json.decode(currencyresponse.body)["results"]["currencies"]);
  return json.decode(currencyresponse.body)["results"]["currencies"];
}
