import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isBlockingEnabled = false;
  static const platform = MethodChannel('callblocker.channel');

  @override
  void initState() {
    super.initState();
    _loadBlockingState();
  }

  Future<void> _loadBlockingState() async {
    try {
      final bool enabled = await platform.invokeMethod('isBlockingEnabled');
      setState(() {
        isBlockingEnabled = enabled;
      });
    } on PlatformException catch (e) {
      print("Error getting blocking state: '${e.message}'.");
    }
  }

  Future<void> _setBlockingEnabled(bool enabled) async {
    try {
      await platform.invokeMethod('setBlockingEnabled', {'enabled': enabled});
      setState(() {
        isBlockingEnabled = enabled;
      });
    } on PlatformException catch (e) {
      print("Error setting blocking state: '${e.message}'.");
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
            SizedBox(height: height * 0.08),
            Image.asset(
              isBlockingEnabled
                  ? 'assets/imgs/enabled-vector.png'
                  : 'assets/imgs/disabled-vector.png',
              width: width * 0.7,
              height: height * 0.4,
              fit: BoxFit.contain,
            ),
            SizedBox(height: height * 0.08),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBlockingEnabled ? 'Blocking\nis ON' : 'Blocking\nis OFF',
                    style: TextStyle(
                      fontSize: height * 0.035,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color:
                          isBlockingEnabled
                              ? const Color(0xFF388E3C)
                              : const Color(0xFF757575),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _setBlockingEnabled(!isBlockingEnabled),
                    child: Container(
                      width: width * 0.35,
                      height: width * 0.17,
                      decoration: BoxDecoration(
                        color:
                            isBlockingEnabled
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left:
                                isBlockingEnabled
                                    ? (width * 0.19)
                                    : (width * 0.01),
                            top: width * 0.01,
                            child: Container(
                              width: width * 0.15,
                              height: width * 0.15,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  isBlockingEnabled ? Icons.check : Icons.close,
                                  color:
                                      isBlockingEnabled
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFF9E9E9E),
                                  size: height * 0.025,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: Text(
                isBlockingEnabled
                    ? 'Call blocking is currently active. All unknown calls will be blocked automatically.'
                    : 'Call blocking is disabled. Tap the switch to enable protection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height * 0.018,
                  color: const Color(0xFF616161),
                  fontWeight: FontWeight.w500,
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
