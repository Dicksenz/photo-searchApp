import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'source.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0A0E21),
      ),
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatelessWidget {
  final _categoryNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Color(0xFF0A0E21),
          title: Text(
            'Photo Parse',
            style: TextStyle(
              fontSize: 25.0,
              letterSpacing: 11,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    child: Icon(
                      Icons.image,
                      size: 250.0,
                      color: Color(0xFF1AC2AC),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: TextFormField(
                        controller: _categoryNameController,
                        decoration: InputDecoration(
                          labelText: 'Enter category',
                          labelStyle: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                          hintText: 'eg: cat, dog .....',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 50.0,
                    margin: EdgeInsets.all(20),
                    child: RaisedButton(
                      color: Color(0xFF1AC2AC),
                      highlightColor: Colors.amber,
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return SecondPage(_categoryNameController.text);
                        }));
                      },
                      child: Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 21,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}

class SecondPage extends StatefulWidget {
  String category;
  SecondPage(this.category);
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0A0E21),
          title: Text(
            'Photo Parse',
            style: TextStyle(
              fontSize: 25.0,
              letterSpacing: 11,
            ),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: getPics(widget.category),
          builder: (context, snapshot) {
            Map data = snapshot.data;
            if (snapshot.hasError) {
              // print(snapshot.error);
              return Text('Failed to get response from server');
            } else if (snapshot.hasData && data['hits'].length != 0) {
              print('length of data is ${data['hits'].length}');
              return Center(
                child: ListView.builder(
                  itemCount: data['hits'].length,
                  itemBuilder: (contex, index) {
                    return Column(
                      children: <Widget>[
                        Padding(padding: EdgeInsets.all(10)),
                        Container(
                          child: InkWell(
                            onTap: () {
                              print('click image');
                            },
                            child: Image.network(
                                '${data['hits'][index]['largeImageURL']}'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      size: 200.0,
                      color: Colors.amber,
                    ),
                    Text(
                      'Image not found',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 22.0,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ));
  }
}

Future<Map> getPics(String category) async {
  String url =
      'https://pixabay.com/api/?key=$kApiKey&q=$category&image_type=photo&pretty=true';

  http.Response response = await http.get(url);
  return json.decode(response.body);
}
