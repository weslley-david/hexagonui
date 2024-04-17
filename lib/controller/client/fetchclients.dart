import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/client.dart';

Future<List<Client>> fetchClients() async {
  final response =
      await http.get(Uri.parse('domain.com/client/list?skip=0&take=3'));

  if (response.statusCode == 200) {
    final List<dynamic> clientsJson = jsonDecode(response.body);
    return clientsJson
        .map((clientJson) => Client.fromJson(clientJson))
        .toList();
  } else {
    throw Exception('Failed to load clients');
  }
}
