import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListAvaliations extends StatefulWidget {
  final String clientId;
  const ListAvaliations({super.key, required this.clientId});

  @override
  State<ListAvaliations> createState() => _ListAvaliationsState();
}

class _ListAvaliationsState extends State<ListAvaliations> {
  List<dynamic> avaliations = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchAvaliations();
  }

  Future<void> fetchAvaliations() async {
    try {
      final response = await http.get(Uri.parse(
          'https://hexagon-no2i.onrender.com/atec/listatectestsbyclientid?skip=0&take=30&client=${widget.clientId}'));
      if (response.statusCode == 200) {
        setState(() {
          final jsonBody = json.decode(response.body);
          if (jsonBody != null && jsonBody.isNotEmpty) {
            avaliations = jsonBody;
          } else {
            avaliations = [];
          }
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text('Failed to load data'))
              : avaliations.isEmpty
                  ? const Center(child: Text('No data available'))
                  : ListView.builder(
                      itemCount: avaliations.length,
                      itemBuilder: (context, index) {
                        final avaliacao = avaliations[index];
                        return Card(
                          margin: const EdgeInsets.all(10.0),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  avaliacao['title'],
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Text('Data: ${avaliacao['created_at']}'),
                                const SizedBox(height: 10.0),
                                ...avaliacao['areas'].map<Widget>((area) {
                                  return Text(
                                      '${area['area']}: ${area['pontuation']}');
                                }).toList(),
                                TextButton(
                                  child: const Text("detalhar respostas"),
                                  onPressed: () => {
                                    context.push(
                                        '/detailavaliation/${avaliacao['id']}')
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
