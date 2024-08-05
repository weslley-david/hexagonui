import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AtecRecommendationPage extends StatefulWidget {
  final int client;
  final int avaliation;

  const AtecRecommendationPage(
      {super.key, required this.client, required this.avaliation});

  @override
  // ignore: library_private_types_in_public_api
  _AtecRecommendationPageState createState() => _AtecRecommendationPageState();
}

class _AtecRecommendationPageState extends State<AtecRecommendationPage> {
  Future<Map<String, dynamic>> fetchRecommendations() async {
    final response = await http.get(
      Uri.parse(
          'https://hexagonrecsys.onrender.com/atec/recommend?client=${widget.client}&avaliation=${widget.avaliation}'),
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      //print('Response Body: $responseBody'); // Debugging line
      return json.decode(responseBody);
    } else {
      throw Exception('Failed to load recommendations');
    }
  }

  final Map<String, Color> areaColors = {
    "Fala/Linguagem/Comunicação": Colors.blue,
    "Percepção sensorial /cognitiva": Colors.green,
    "Saúde / Aspectos físicos / Comportamento": Colors.red,
    "Sociabilidade": Colors.orange,
  };

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
            final filteredQuestions =
                snapshot.data!['filtered_questions'] as List<dynamic>?;

            if (filteredQuestions == null) {
              return const Center(child: Text('No filtered questions found'));
            }

            return ListView.builder(
              itemCount: filteredQuestions.length,
              itemBuilder: (context, index) {
                final question = filteredQuestions[index];
                final area = question['area'] as String;
                final borderColor = areaColors[area] ??
                    Colors.grey; // Default color if area is not found

                return Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title:
                        Text('${question['number']} - ${question['content']}'),
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
