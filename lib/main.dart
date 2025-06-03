import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const CallBlockerApp());
}

class CallBlockerApp extends StatefulWidget {
  const CallBlockerApp({super.key});

  @override
  _CallBlockerAppState createState() => _CallBlockerAppState();
}

class _CallBlockerAppState extends State<CallBlockerApp> {
  static const platform = MethodChannel('callblocker.channel');
  final TextEditingController _controller = TextEditingController();
  List<String> blockedPrefixes = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _getBlockedPrefixes();
  }

  Future<void> _requestPermissions() async {
    await Permission.phone.request();
    await Permission.contacts.request();
  }

  Future<void> _getBlockedPrefixes() async {
    try {
      final List<dynamic> prefixes = await platform.invokeMethod(
        'getBlockedPrefixes',
      );
      setState(() {
        blockedPrefixes = prefixes.cast<String>();
      });
    } on PlatformException catch (e) {
      print("خطا در دریافت پیشوندها: '${e.message}'.");
    }
  }

  Future<void> _addBlockedPrefix(String prefix) async {
    if (prefix.trim().isEmpty) return;
    try {
      await platform.invokeMethod('addBlockedPrefix', {
        'prefix': prefix.trim(),
      });
      _controller.clear();
      _getBlockedPrefixes();
    } on PlatformException catch (e) {
      print("خطا در افزودن پیشوند: '${e.message}'.");
    }
  }

  Future<void> _removeBlockedPrefix(String prefix) async {
    try {
      await platform.invokeMethod('removeBlockedPrefix', {'prefix': prefix});
      _getBlockedPrefixes();
    } on PlatformException catch (e) {
      print("خطا در حذف پیشوند: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Blocker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('بلاک تماس بر اساس پیش‌شماره')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'پیش‌شماره (مثال: +98)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _addBlockedPrefix(_controller.text),
                    child: const Text('اضافه کن'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: blockedPrefixes.length,
                  itemBuilder: (context, index) {
                    final prefix = blockedPrefixes[index];
                    return ListTile(
                      title: Text(prefix),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeBlockedPrefix(prefix),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // تست عملکرد با یک شماره
            await _addBlockedPrefix("+98");
            print("پیشوند +98 اضافه شد");
          },
          child: const Icon(Icons.check),
        ),
      ),
    );
  }
}
