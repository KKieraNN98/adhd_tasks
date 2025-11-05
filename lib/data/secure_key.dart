// Imports/Packages
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

class SecureKeyManager {
  SecureKeyManager._();
  static final SecureKeyManager instance = SecureKeyManager._();

  static const _fileName = 'adhd_todo.db.key';

  // Get or create a 256-bit hex key
  Future<String> getOrCreateHexKey256() async {
    // Get key file path
    final dir = await getApplicationDocumentsDirectory();
    final keyFile = File('${dir.path}/$_fileName');

    // Read existing key if valid
    if (await keyFile.exists()) {
      final hex = (await keyFile.readAsString()).trim();
      if (_isValidHex256(hex)) return hex;
    }

    // Generate and save a new key
    final bytes = _randomBytes(32);
    final hex = _toHex(bytes);
    await keyFile.writeAsString('$hex\n', flush: true);
    return hex;
  }

  // Check if hex string is 256-bit
  bool _isValidHex256(String s) {
    if (s.length != 64) return false;
    final re = RegExp(r'^[0-9a-fA-F]+$');
    return re.hasMatch(s);
  }

  // Generate random bytes
  List<int> _randomBytes(int n) {
    final rng = Random.secure();
    return List<int>.generate(n, (_) => rng.nextInt(256));
  }

  // Convert bytes to hex
  String _toHex(List<int> bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }
}
