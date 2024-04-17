import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Atec extends StatefulWidget {
  const Atec({super.key});

  @override
  State<Atec> createState() => _AtecState();
}

class _AtecState extends State<Atec> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ATEC Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text('Go to Home Page'),
        ),
      ),
    );
  }
}
