import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hexagonui/models/atec_evolution.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowAtecEvolution extends StatefulWidget {
  final String clientId;

  const ShowAtecEvolution({super.key, required this.clientId});

  @override
  // ignore: library_private_types_in_public_api
  _ShowAtecEvolutionState createState() => _ShowAtecEvolutionState();
}

class _ShowAtecEvolutionState extends State<ShowAtecEvolution> {
  List<Evolution> _evolutionData = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchAtecEvolution();
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('acetoken');
  }

  Future<void> _fetchAtecEvolution() async {
    try {
      String? token = await getAccessToken();
      final response = await http.get(
          Uri.parse(
              'https://hexagon-no2i.onrender.com/atec/listevolutionbyarea?client=${widget.clientId}'),
          headers: {
            'Authorization': '$token'
          }); // Coloque a URL do seu endpoint aqui
      if (response.statusCode == 200) {
        setState(() {
          final jsonBody = jsonDecode(response.body);
          if (jsonBody['evolution'] != null &&
              jsonBody['evolution'].isNotEmpty) {
            _evolutionData = (jsonBody['evolution'] as List)
                .map((e) => Evolution.fromJson(e))
                .toList();
          } else {
            _evolutionData = [];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(child: Text('Failed to load data'))
              : _evolutionData.isEmpty
                  ? const Center(child: Text('No data available'))
                  : ListView.builder(
                      itemCount: _evolutionData.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text(_evolutionData[index].area ?? ''),
                            ),
                            SizedBox(
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: CustomPaint(
                                painter: BarChartPainter(
                                    _evolutionData[index].score),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<int>? data;
  final double barWidth = 20.0;

  BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data == null || data!.isEmpty) return;

    final double width = size.width;
    final double height = size.height;
    final Paint barPaint = Paint()..color = Colors.deepPurpleAccent;

    final double chartWidth = width - 20;
    final double chartHeight = height - 20;

    final double deltaX = chartWidth / data!.length;
    final double deltaY = chartHeight /
        data!.reduce((value, element) => value > element ? value : element);

    for (int i = 0; i < data!.length; i++) {
      final double barHeight = data![i] * deltaY;
      final double x = 10 + (deltaX - barWidth) / 2 + i * deltaX;
      final double y = chartHeight - barHeight + 10;

      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, barHeight), barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
