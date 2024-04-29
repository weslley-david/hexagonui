import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hexagonui/models/client.dart';
import 'package:http/http.dart' as http;

class DetailClient extends StatefulWidget {
  final String id;
  const DetailClient({super.key, required this.id});

  @override
  State<DetailClient> createState() => _DetailClientState();
}

class _DetailClientState extends State<DetailClient> {
  late Future<Client> _userDetailsFuture;

  @override
  void initState() {
    super.initState();
    _userDetailsFuture = _getUserDetails();
  }

  Future<Client> _getUserDetails() async {
    final response = await http.get(
      Uri.https('hexagon-no2i.onrender.com', '/client/${widget.id}'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Client.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _userDetailsFuture,
        builder: (context, AsyncSnapshot<Client> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.data == null) {
              return const Center(child: Text('No data found'));
            }

            return Column(
              children: [
                Text('${snapshot.data!.name}'),
                ListTile(
                  title: Text('@${snapshot.data!.identifier}'),
                  subtitle: Text(snapshot.data!.name ?? "Name not found"),
                ),
                // Add more details as needed
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
