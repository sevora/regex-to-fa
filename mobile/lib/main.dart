import 'package:flutter/material.dart';
import 'package:regex_to_fa_mobile/thompson_construction_painter.dart';
import './algorithms/shunting_yard.dart';
import 'utilities/regex_validator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _regularExpression = "(a|b)*";

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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                      child: const Text(
                          "Regular Expression to FA with Thompson's Construction",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      )
                  ),

                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      initialValue: _regularExpression,
                      decoration: const InputDecoration(
                        hintText: 'Enter regex...',
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
                    width: 5000,
                    height: 100,
                  ),
                  Container(
                    color: Colors.white,
                    child: Container(
                      width: 5000,
                      height: 5000,
                      color: Colors.white,
                      child: validateRegEx(_regularExpression)
                          ? CustomPaint(
                              size: Size.infinite,
                              painter: ThompsonConstructionPainter(
                                  infixToPostfix(
                                      normalizeExpression(_regularExpression))))
                          : const Text(
                              "Regular expression is NOT valid!",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold),
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
