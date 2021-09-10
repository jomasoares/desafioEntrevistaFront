import 'package:desafio_unimed_front/src/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desafio Unimed Front',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const Home(),
    );
  }
}
