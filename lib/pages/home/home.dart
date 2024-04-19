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
  final int _take = 10;

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

  void _loadPreviousPage() {
    if (_skip >= _take) {
      setState(() {
        _skip -= _take;
      });
    }
  }

  void _loadNextPage() {
    setState(() {
      _skip += _take;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _loadPreviousPage,
                child: const Text('<<'),
              ),
              const SizedBox(
                width: 15.0,
              ),
              Text('$_skip / ${_take + _skip}'),
              const SizedBox(
                width: 15.0,
              ),
              TextButton(
                onPressed: _loadNextPage,
                child: const Text('>>'),
              ),
              const SizedBox(
                width: 15.0,
              )
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: _getClientList(),
              builder: (context, AsyncSnapshot<List<Client>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  return ListView.builder(
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () => {},
                          leading: const CircleAvatar(child: Text('A')),
                          title: Text('@${snapshot.data![index].identifier}'),
                          subtitle:
                              Text(snapshot.data![index].name ?? "not found"),
                        );
                      });
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
