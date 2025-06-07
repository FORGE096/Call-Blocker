import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class BlockerSettingsService extends ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isBlockerEnabled = false;
  bool _blockAllCalls = false;
  bool _blockUnknownNumbers = false;
  bool _blockPrivateNumbers = false;
  final List<String> _blockedNumbers = [];
  final List<String> _blockedPrefixes = [];
  bool _isInitialized = false;
  String? _lastError;

  static const platform = MethodChannel('com.callblocker/blocker');

  BlockerSettingsService(this._prefs) {
    _loadSettings();
    _initializeNativeBlocker();
  }

  // Getters
  bool get isBlockerEnabled => _isBlockerEnabled;
  bool get blockAllCalls => _blockAllCalls;
  bool get blockUnknownNumbers => _blockUnknownNumbers;
  bool get blockPrivateNumbers => _blockPrivateNumbers;
  List<String> get blockedNumbers => List.unmodifiable(_blockedNumbers);
  List<String> get blockedPrefixes => List.unmodifiable(_blockedPrefixes);
  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;

  Future<void> _initializeNativeBlocker() async {
    if (_isInitialized) return;

    try {
      await platform.invokeMethod('initializeBlocker');
      _isInitialized = true;
      _lastError = null;
      debugPrint('Native blocker initialized successfully');
    } catch (e) {
      _lastError = 'Error initializing native blocker: $e';
      debugPrint(_lastError);
      _isInitialized = false;
    }
  }

  void _loadSettings() {
    try {
      _isBlockerEnabled = _prefs.getBool('isBlockerEnabled') ?? false;
      _blockAllCalls = _prefs.getBool('blockAllCalls') ?? false;
      _blockUnknownNumbers = _prefs.getBool('blockUnknownNumbers') ?? false;
      _blockPrivateNumbers = _prefs.getBool('blockPrivateNumbers') ?? false;
      _blockedNumbers.addAll(_prefs.getStringList('blockedNumbers') ?? []);
      _blockedPrefixes.addAll(_prefs.getStringList('blockedPrefixes') ?? []);
      _lastError = null;
      debugPrint('Settings loaded successfully');
    } catch (e) {
      _lastError = 'Error loading settings: $e';
      debugPrint(_lastError);
      _resetToDefaults();
    }
  }

  void _resetToDefaults() {
    _isBlockerEnabled = false;
    _blockAllCalls = false;
    _blockUnknownNumbers = false;
    _blockPrivateNumbers = false;
    _blockedNumbers.clear();
    _blockedPrefixes.clear();
    notifyListeners();
  }

  Future<void> setBlockerEnabled(bool value) async {
    if (!_isInitialized) {
      await _initializeNativeBlocker();
    }

    _isBlockerEnabled = value;
    try {
      await _prefs.setBool('isBlockerEnabled', value);
      if (_isInitialized) {
        await platform.invokeMethod('setBlockerEnabled', {'enabled': value});
        await _updateBlockedNumbers();
      }
      _lastError = null;
      debugPrint('Blocker ${value ? "enabled" : "disabled"}');
    } catch (e) {
      _lastError = 'Error setting blocker state: $e';
      debugPrint(_lastError);
      _isBlockerEnabled = !value;
      notifyListeners();
      rethrow;
    }
    notifyListeners();
  }

  Future<void> setBlockAllCalls(bool value) async {
    _blockAllCalls = value;
    try {
      await _prefs.setBool('blockAllCalls', value);
      if (_isInitialized) {
        await _updateBlockedNumbers();
      }
      _lastError = null;
      debugPrint('Block all calls ${value ? "enabled" : "disabled"}');
    } catch (e) {
      _lastError = 'Error setting block all calls: $e';
      debugPrint(_lastError);
      _blockAllCalls = !value;
      notifyListeners();
      rethrow;
    }
    notifyListeners();
  }

  Future<void> setBlockUnknownNumbers(bool value) async {
    _blockUnknownNumbers = value;
    try {
      await _prefs.setBool('blockUnknownNumbers', value);
      if (_isInitialized) {
        await _updateBlockedNumbers();
      }
      _lastError = null;
      debugPrint('Block unknown numbers ${value ? "enabled" : "disabled"}');
    } catch (e) {
      _lastError = 'Error setting block unknown numbers: $e';
      debugPrint(_lastError);
      _blockUnknownNumbers = !value;
      notifyListeners();
      rethrow;
    }
    notifyListeners();
  }

  Future<void> setBlockPrivateNumbers(bool value) async {
    _blockPrivateNumbers = value;
    try {
      await _prefs.setBool('blockPrivateNumbers', value);
      if (_isInitialized) {
        await _updateBlockedNumbers();
      }
      _lastError = null;
      debugPrint('Block private numbers ${value ? "enabled" : "disabled"}');
    } catch (e) {
      _lastError = 'Error setting block private numbers: $e';
      debugPrint(_lastError);
      _blockPrivateNumbers = !value;
      notifyListeners();
      rethrow;
    }
    notifyListeners();
  }

  Future<void> addBlockedNumber(String number) async {
    if (!_blockedNumbers.contains(number)) {
      _blockedNumbers.add(number);
      try {
        await _prefs.setStringList('blockedNumbers', _blockedNumbers);
        if (_isInitialized) {
          await _updateBlockedNumbers();
        }
        _lastError = null;
        debugPrint('Added blocked number: $number');
      } catch (e) {
        _lastError = 'Error adding blocked number: $e';
        debugPrint(_lastError);
        _blockedNumbers.remove(number);
        notifyListeners();
        rethrow;
      }
      notifyListeners();
    }
  }

  Future<void> removeBlockedNumber(String number) async {
    _blockedNumbers.remove(number);
    try {
      await _prefs.setStringList('blockedNumbers', _blockedNumbers);
      if (_isInitialized) {
        await _updateBlockedNumbers();
      }
      _lastError = null;
      debugPrint('Removed blocked number: $number');
    } catch (e) {
      _lastError = 'Error removing blocked number: $e';
      debugPrint(_lastError);
      _blockedNumbers.add(number);
      notifyListeners();
      rethrow;
    }
    notifyListeners();
  }

  Future<void> addBlockedPrefix(String prefix) async {
    if (!_blockedPrefixes.contains(prefix)) {
      _blockedPrefixes.add(prefix);
      try {
        await _prefs.setStringList('blockedPrefixes', _blockedPrefixes);
        if (_isInitialized) {
          await _updateBlockedNumbers();
        }
        _lastError = null;
        debugPrint('Added blocked prefix: $prefix');
      } catch (e) {
        _lastError = 'Error adding blocked prefix: $e';
        debugPrint(_lastError);
        _blockedPrefixes.remove(prefix);
        notifyListeners();
        rethrow;
      }
      notifyListeners();
    }
  }

  Future<void> removeBlockedPrefix(String prefix) async {
    _blockedPrefixes.remove(prefix);
    try {
      await _prefs.setStringList('blockedPrefixes', _blockedPrefixes);
      if (_isInitialized) {
        await _updateBlockedNumbers();
      }
      _lastError = null;
      debugPrint('Removed blocked prefix: $prefix');
    } catch (e) {
      _lastError = 'Error removing blocked prefix: $e';
      debugPrint(_lastError);
      _blockedPrefixes.add(prefix);
      notifyListeners();
      rethrow;
    }
    notifyListeners();
  }

  Future<void> _updateBlockedNumbers() async {
    if (!_isBlockerEnabled || !_isInitialized) return;

    try {
      final Map<String, dynamic> settings = {
        'blockAllCalls': _blockAllCalls,
        'blockUnknownNumbers': _blockUnknownNumbers,
        'blockPrivateNumbers': _blockPrivateNumbers,
        'blockedNumbers': _blockedNumbers,
        'blockedPrefixes': _blockedPrefixes,
      };

      await platform.invokeMethod('updateBlockedNumbers', settings);
      _lastError = null;
      debugPrint('Blocked numbers updated successfully');
    } catch (e) {
      _lastError = 'Error updating blocked numbers: $e';
      debugPrint(_lastError);
      rethrow;
    }
  }

  bool shouldBlockNumber(String number) {
    if (!_isBlockerEnabled) return false;
    if (_blockAllCalls) return true;
    if (_blockPrivateNumbers && number == 'private') return true;
    if (_blockUnknownNumbers && number == 'unknown') return true;
    if (_blockedNumbers.contains(number)) return true;
    return _blockedPrefixes.any((prefix) => number.startsWith(prefix));
  }

  Future<bool> isNumberInContacts(String number) async {
    if (!_isInitialized) return false;

    try {
      final bool result =
          await platform.invokeMethod('isNumberInContacts', {'number': number});
      _lastError = null;
      return result;
    } catch (e) {
      _lastError = 'Error checking contacts: $e';
      debugPrint(_lastError);
      return false;
    }
  }
}
