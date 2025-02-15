import 'package:flutter/material.dart';
import 'package:physics_canon_example/providers/physics_provider.dart';
import 'package:physics_canon_example/ui/pages/basic_physics_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PhysicsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Canon Physics',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BasicPhysicsPage(),
    );
  }
}
