import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../models/client.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int _skip = 0;
  int _take = 10;

  Future<List<Client>> _getClientList() async {
    final Map<String, String> queryParams = {
      'skip': '$_skip',
      'take': '$_take',
      "specialist": '1',
    };

    final uri =
        Uri.https('hexagon-no2i.onrender.com', '/client/list', queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((item) => Client.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load client list');
    }
  }

  void _loadMoreClients() {
    setState(() {
      _skip += _take;
    });
  }

  void _previousPage() {
    setState(() {
      _skip -= _take;
      if (_skip < 0) {
        _skip = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Client List'),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Detail'),
              onTap: () => context.go('/detail'),
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Client>>(
              future: _getClientList(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        _loadMoreClients();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Client client = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            tileColor: Colors.amber,
                            title: Text(client.name ?? 'not fetched'),
                            subtitle: Text(client.identifier ?? 'not fetched'),
                            leading: const CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'https://cdn.pixabay.com/photo/2023/07/04/09/36/baby-8105822_1280.jpg'),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading client list'),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: _previousPage, child: const Text("after")),
              TextButton(
                  onPressed: _loadMoreClients, child: const Text("next")),
            ],
          ),
        ],
      ),
    );
  }
}
