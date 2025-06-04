import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:call_blocker/screens/home_screen.dart';
import 'package:call_blocker/models/navigation/navigation_model.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool permissionsGranted = false;
  bool isRequesting = false;
  int countdownSeconds = 5;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    checkPermissionsOnStart();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> checkPermissionsOnStart() async {
    var phoneStatus = await Permission.phone.status;
    var contactsStatus = await Permission.contacts.status;
    if (phoneStatus.isGranted && contactsStatus.isGranted) {
      if (!mounted) return;
      setState(() {
        permissionsGranted = true;
      });
      startCountdown();
    }
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds > 1) {
        setState(() {
          countdownSeconds--;
        });
      } else {
        timer.cancel();
        if (!mounted) return;
        Navigator.pushReplacement(context, fadeTransition(const HomeScreen()));
      }
    });
  }

  Future<void> requestPermissions() async {
    setState(() {
      isRequesting = true;
    });

    Map<Permission, PermissionStatus> statuses =
        await [Permission.phone, Permission.contacts].request();

    bool allGranted =
        statuses[Permission.phone]?.isGranted == true &&
        statuses[Permission.contacts]?.isGranted == true;

    if (!mounted) return;

    setState(() {
      isRequesting = false;
    });

    if (allGranted) {
      setState(() {
        permissionsGranted = true;
      });
      startCountdown();
    }
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
            const Spacer(flex: 2),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child:
                  permissionsGranted
                      ? Icon(
                        CupertinoIcons.checkmark_shield,
                        key: const ValueKey('granted_icon'),
                        size: width * 0.5,
                        color: Colors.green,
                      )
                      : Icon(
                        CupertinoIcons.xmark_shield,
                        key: const ValueKey('denied_icon'),
                        size: width * 0.5,
                        color:
                            isRequesting ? Colors.amber : Colors.redAccent[700],
                      ),
            ),
            SizedBox(height: height * 0.05),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  Text(
                    permissionsGranted
                        ? 'Permissions Granted!'
                        : 'Permissions Denied!',
                    style: TextStyle(
                      fontSize: height * 0.029,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    permissionsGranted
                        ? 'Redirecting to main screen in $countdownSeconds seconds...'
                        : 'Please grant the required permissions to the app',
                    style: TextStyle(
                      fontSize: height * 0.016,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[650],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.09),
            AnimatedOpacity(
              opacity: permissionsGranted ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton(
                onPressed:
                    isRequesting || permissionsGranted
                        ? null
                        : requestPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      permissionsGranted
                          ? Colors.green[300]
                          : Colors.lightBlue[100],
                  fixedSize: Size(width * 0.55, height * 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    isRequesting
                        ? SizedBox(
                          height: height * 0.03,
                          width: height * 0.03,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                        : Text(
                          permissionsGranted
                              ? 'Permissions Granted'
                              : 'Request Permissions',
                          style: TextStyle(
                            fontSize: height * 0.02,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
