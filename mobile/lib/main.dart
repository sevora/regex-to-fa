import 'package:flutter/material.dart';
import 'package:regex_to_fa_mobile/thompson_construction_renderer.dart';
import './algorithms/shunting_yard.dart';

void main() {
  exampleUsage();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.white),
      home: Scaffold(
        // Outer white container with padding
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 80),
          color: Colors.white,
          // Inner yellow container
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                    initialValue: "Hey",
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter a regular expression',
                    ),
                    style: const TextStyle(color: Colors.black)
                ),
                Container(
                  color: Colors.white,
                  child: CustomPaint(
                      size: const Size(1920, 1080),
                      painter: ThompsonConstructionPainter("a+b")
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
