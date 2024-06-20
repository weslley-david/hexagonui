import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AtecRecommendationPage extends StatefulWidget {
  final int client;
  final int avaliation;

  const AtecRecommendationPage(
      {required this.client, required this.avaliation});

  @override
  _AtecRecommendationPageState createState() => _AtecRecommendationPageState();
}

class _AtecRecommendationPageState extends State<AtecRecommendationPage> {
  Future<Map<String, dynamic>> fetchRecommendations() async {
    final response = await http.get(
      Uri.parse(
          'https://hexagonrecsys.onrender.com/atec/recommend?client=${widget.client}&avaliation=${widget.avaliation}'),
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load recommendations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendações'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchRecommendations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data found'));
          } else {
            final recommendations =
                snapshot.data!['recommended_questions'] as List<dynamic>;
            return ListView.builder(
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final question = recommendations[index];
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title: Text('${question['content']}'),
                    subtitle: Text(question['area']),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
