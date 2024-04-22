import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digimon Info',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DigimonListPage(),
    );
  }
}

class DigimonListPage extends StatefulWidget {
  @override
  _DigimonListPageState createState() => _DigimonListPageState();
}

class _DigimonListPageState extends State<DigimonListPage> {
  List<dynamic> _digimonList = [];
  int _pageNumber = 1;
  int _pageSize = 5;
  bool _isLoading = false;

  Future<void> _fetchDigimonList() async {
    setState(() {
      _isLoading = true;
    });
    final response = await http.get('https://digi-api.com/api/v1/digimon?page=$_pageNumber&pageSize=$_pageSize' as Uri);
    if (response.statusCode == 200) {
      setState(() {
        _digimonList.addAll(json.decode(response.body));
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load digimon list');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDigimonList();
  }

  void _loadMoreDigimons() {
    setState(() {
      _pageNumber++;
    });
    _fetchDigimonList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digimon List'),
      ),
      body: _digimonList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _digimonList.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _digimonList.length) {
                  var digimon = _digimonList[index];
                  return ListTile(
                    title: Text(digimon['name']),
                    subtitle: Text(digimon['level']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DigimonDetailsPage(digimon: digimon),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              onPressed: _loadMoreDigimons,
              tooltip: 'Load more',
              child: Icon(Icons.add),
            ),
    );
  }
}

class DigimonDetailsPage extends StatelessWidget {
  final Map<String, dynamic> digimon;

  DigimonDetailsPage({required this.digimon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digimon Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${digimon["name"]}'),
            Text('Level: ${digimon["level"]}'),
            // Add more fields here as needed
          ],
        ),
      ),
    );
  }
}
