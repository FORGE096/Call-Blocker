import 'package:call_blocker/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CallBlockerApp());
}

class CallBlockerApp extends StatefulWidget {
  const CallBlockerApp({super.key});

  @override
  _CallBlockerAppState createState() => _CallBlockerAppState();
}

class _CallBlockerAppState extends State<CallBlockerApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Call Blocker',
      home: SplashScreen(),
    );
  }
}
