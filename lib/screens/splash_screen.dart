import 'dart:async';
import 'package:call_blocker/models/navigation/navigation_model.dart';
import 'package:call_blocker/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permissions_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      final granted = await checkPermissions();
      if (!mounted) return;
      if (granted) {
        Navigator.pushReplacement(context, fadeTransition(const HomeScreen()));
      } else {
        Navigator.pushReplacement(
          context,
          fadeTransition(const PermissionsScreen()),
        );
      }
    });
  }

  Future<bool> checkPermissions() async {
    final permissions = [Permission.phone, Permission.contacts];

    final statuses = await Future.wait(permissions.map((p) => p.status));
    return statuses.every((status) => status.isGranted);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(width: width),
            const Spacer(),
            Text(
              'Call Blocker',
              style: TextStyle(
                fontSize: height * 0.047,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text('BETA 0.0.1'),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
