import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedCity = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/rsm.jpg'),
        fit: BoxFit.cover,
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: TextField(
                  onChanged: (value) {
                    selectedCity = value;
                    print(value);
                  },
                  decoration: const InputDecoration(
                      hintText: 'Bölge Seçiniz',
                      border: OutlineInputBorder(borderSide: BorderSide.none)),
                  style: TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    var Response = await http.get(Uri.parse(
                        'https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=de55da5e46ce11f683d64c5a838aab8a'));

                    if (Response.statusCode == 200) {
                      Navigator.pop(context, selectedCity);
                    } else {
                      _showMyDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
                  child: const Text('BÖLGE SEÇ'))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('LOCATION NOT FOUND'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Lütfen doğru konum giriniz...'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
