import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/client.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  Future<List<Client>> _getClientList() async {
    final Map<String, String> queryParams = {
      'skip': '0',
      'take': '3',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client List'),
      ),
      body: FutureBuilder<List<Client>>(
        future: _getClientList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length, // Added null check here
              itemBuilder: (context, index) {
                Client client = snapshot.data![index]; // Added null check here
                return ListTile(
                  title: Text(client.name ?? 'not fetched'),
                  subtitle: Text(client.identifier ?? 'not fetched'),
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://cdn.pixabay.com/photo/2023/07/04/09/36/baby-8105822_1280.jpg'), //client.imageurl ?? 'not fetched'
                  ),
                );
              },
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
    );
  }
}
