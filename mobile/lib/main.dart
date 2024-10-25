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
  String _regularExpression = "a+b";

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.white),
      home:
        // Outer white container with padding
      Scaffold(
        // Outer white container with padding
        body: SafeArea(
          child: InteractiveViewer(
            panEnabled: true, // Set it to false to prevent panning.
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.5,
            maxScale: 4,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextFormField(
                      initialValue: _regularExpression,
                      decoration: const InputDecoration(
                        hintText: 'a+b',
                        labelText: 'Regular Expression',
                      ),
                      onChanged: (text) {
                        setState(() {
                          _regularExpression = text;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 100,
                    height: 100,
                  ),
                  Container(
                    color: Colors.white,
                    child: Container(
                      width: 1920,
                      height: 1920,
                      color: Colors.white,
                      child: CustomPaint(
                          size: Size.infinite,
                          painter: ThompsonConstructionPainter(
                          infixToPostfix(
                            normalizeExpression(_regularExpression)
                          )
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }
}
