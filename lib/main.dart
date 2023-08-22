import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

const request = 'https://api.hgbrasil.com/finance?key=87aa5331';
Uri uri = Uri.parse(request);

void main() async {
  runApp(const MyApp());
}

Future<Map> getCurrencyData() async {
  http.Response result = await http.get(uri);
  return json.decode(result.body);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Converter(),
    );
  }
}

class Converter extends StatefulWidget {
  const Converter({super.key});

  @override
  State<Converter> createState() => _Converter();
}

class _Converter extends State<Converter> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dollar;
  late double euro;
  late double real;

  void clearAll() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
    return;
  }

  void _realChanged(String text) {
    if (text.isEmpty){
      clearAll();
    }
    double real = double.parse(text);
    dolarController.text = (real / dollar).toStringAsPrecision(2);
    euroController.text = (real / euro).toStringAsPrecision(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty){
      clearAll();
    }
    double dollar = double.parse(text);
    realController.text = (dollar * this.dollar).toStringAsPrecision(2);
    euroController.text = (dollar * this.dollar / euro).toStringAsPrecision(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty){
      clearAll();
    }
    double euro = double.parse(text);
    dolarController.text = (euro * this.euro).toStringAsPrecision(2);
    realController.text = (euro * this.euro / dollar).toStringAsPrecision(2);
  }


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            hintColor: Colors.amber,
            primaryColor: Colors.white,
            inputDecorationTheme: const InputDecorationTheme(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
              hintStyle: TextStyle(color: Colors.amber),
            )),
        home: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('\$ Converter \$'),
            backgroundColor: Colors.amber,
            centerTitle: true,
          ),
          body: FutureBuilder<Map>(
            future: getCurrencyData(),
            builder: (context, snapshot) {
              switch(snapshot.connectionState){
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(
                    child: Text('Carregando Dados ...',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                default:
                  if (snapshot.hasError){
                    return const Center(
                      child: Text('Erro ao carregar dados ...',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    dollar = snapshot.data!['results']['currencies']['USD']['buy'];
                    euro = snapshot.data!['results']['currencies']['EUR']['buy'];
                    // real = snapshot.data!['results']['currencies']['RS']['buy'];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.monetization_on, size: 150,color: Colors.amber,),
                          const Divider(),
                          buildFieldText('Reais', 'R\$ ', realController, _realChanged),
                          const Divider(),
                          buildFieldText('Dólares', 'US\$ ', dolarController, _dolarChanged),
                          const Divider(),
                          buildFieldText('Euro', '€ ', euroController, _euroChanged),
                        ],
                      ),
                    );
                  }
              }
            },
          ),
        ),
    );
  }
}

Widget buildFieldText(String label, String prefix, TextEditingController funct, Function changeFunct) {
  return TextField(
    controller: funct,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(
      color: Colors.amber, fontSize: 25,
    ),
    onChanged: (String text) {
      changeFunct(text);
    },
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}
