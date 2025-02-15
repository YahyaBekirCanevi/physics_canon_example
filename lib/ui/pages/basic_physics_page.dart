import 'package:flutter/material.dart';
import 'package:physics_canon_example/providers/physics_provider.dart';
import 'package:provider/provider.dart';

class BasicPhysicsPage extends StatefulWidget {
  const BasicPhysicsPage({super.key});

  @override
  State<BasicPhysicsPage> createState() => _BasicPhysicsPageState();
}

class _BasicPhysicsPageState extends State<BasicPhysicsPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Add the observer to listen for lifecycle events
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove the observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final physicsProvider = Provider.of<PhysicsProvider>(context, listen: false);

    // Pause or resume the update loop based on the app's lifecycle state
    if (state == AppLifecycleState.paused) {
      physicsProvider.pause();
    } else if (state == AppLifecycleState.resumed) {
      physicsProvider.resume();
    }
  }
  @override
  Widget build(BuildContext context) {
    final physicsProvider = Provider.of<PhysicsProvider>(context);
    return Scaffold(
      body: physicsProvider.threeJs.build(),
    );
  }
}
