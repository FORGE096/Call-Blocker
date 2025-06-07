import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/blocker_settings_service.dart';

class BlockScreen extends StatefulWidget {
  const BlockScreen({super.key});

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  final _numberController = TextEditingController();
  final _prefixController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<BlockerSettingsService>();
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Block Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSwitchSection(
            title: 'Block All Calls',
            subtitle: 'Block all incoming calls regardless of number',
            value: settings.blockAllCalls,
            onChanged: (value) => settings.setBlockAllCalls(value),
            width: width,
            height: height,
          ),
          const Divider(),
          _buildSwitchSection(
            title: 'Block Unknown Numbers',
            subtitle: 'Block calls from numbers not in your contacts',
            value: settings.blockUnknownNumbers,
            onChanged: (value) => settings.setBlockUnknownNumbers(value),
            width: width,
            height: height,
          ),
          const Divider(),
          _buildSwitchSection(
            title: 'Block Private Numbers',
            subtitle:
                'Block calls from private, government, and security numbers',
            value: settings.blockPrivateNumbers,
            onChanged: (value) => settings.setBlockPrivateNumbers(value),
            width: width,
            height: height,
          ),
          const Divider(),
          _buildBlockedNumbersSection(settings),
          const Divider(),
          _buildBlockedPrefixesSection(settings),
        ],
      ),
    );
  }

  Widget _buildSwitchSection({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required double width,
    required double height,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: width * 0.22,
              height: width * 0.11,
              decoration: BoxDecoration(
                color: value
                    ? const Color(0xFF4CAF50)
                    : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
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
                    left: value ? (width * 0.12) : (width * 0.01),
                    top: width * 0.01,
                    child: Container(
                      width: width * 0.09,
                      height: width * 0.09,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
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
                          value ? Icons.check : Icons.close,
                          color: value
                              ? const Color(0xFF4CAF50)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : const Color(0xFF9E9E9E),
                          size: height * 0.018,
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
    );
  }

  Widget _buildBlockedNumbersSection(BlockerSettingsService settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Blocked Numbers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _numberController,
                decoration: const InputDecoration(
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (_numberController.text.isNotEmpty) {
                  settings.addBlockedNumber(_numberController.text);
                  _numberController.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...settings.blockedNumbers.map((number) => ListTile(
              title: Text(number),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => settings.removeBlockedNumber(number),
              ),
            )),
      ],
    );
  }

  Widget _buildBlockedPrefixesSection(BlockerSettingsService settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Blocked Prefixes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _prefixController,
                decoration: const InputDecoration(
                  hintText: 'Enter prefix (e.g., +98)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (_prefixController.text.isNotEmpty) {
                  settings.addBlockedPrefix(_prefixController.text);
                  _prefixController.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...settings.blockedPrefixes.map((prefix) => ListTile(
              title: Text(prefix),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => settings.removeBlockedPrefix(prefix),
              ),
            )),
      ],
    );
  }
}
