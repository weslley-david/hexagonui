import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class About extends StatefulWidget {
  final String name;
  const About({super.key, required this.name, String? id});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("about"),
      ),
      body: Center(
        child: Column(
          children: [
            Text(" ${widget.name}"),
            TextButton(
                onPressed: () => context.goNamed('home'),
                child: const Text("back to home"))
          ],
        ),
      ),
    );
  }
}
