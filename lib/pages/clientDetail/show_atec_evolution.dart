import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hexagonui/models/AtecEvolution.dart';

class ShowAtecEvolution extends StatefulWidget {
  final String clientId;

  const ShowAtecEvolution({Key? key, required this.clientId}) : super(key: key);

  @override
  _ShowAtecEvolutionState createState() => _ShowAtecEvolutionState();
}

class _ShowAtecEvolutionState extends State<ShowAtecEvolution> {
  List<Evolution> _evolutionData = [];

  @override
  void initState() {
    super.initState();
    _fetchAtecEvolution();
  }

  Future<void> _fetchAtecEvolution() async {
    final response = await http.get(Uri.parse(
        'https://hexagon-no2i.onrender.com/atec/listevolutionbyarea?client=${widget.clientId}')); // Coloque a URL do seu endpoint aqui
    if (response.statusCode == 200) {
      setState(() {
        final jsonBody = jsonDecode(response.body);
        _evolutionData = (jsonBody['evolution'] as List)
            .map((e) => Evolution.fromJson(e))
            .toList();
      });
    } else {
      throw Exception('Failed to load Atec Evolution');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Atec Evolution'),
      // ),
      body: ListView.builder(
        itemCount: _evolutionData.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                title: Text(_evolutionData[index].area ?? ''),
                //subtitle: Text(_evolutionData[index].score.toString()),
              ),
              SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width *
                    0.9, // 90% da largura da tela
                child: CustomPaint(
                  painter: BarChartPainter(_evolutionData[index].score),
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
    final Paint barPaint = Paint()..color = Colors.blue;

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
