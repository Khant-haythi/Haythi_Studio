import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Overridden at startup after preferences have loaded. Tests can omit storage.
final preferencesProvider = Provider<SharedPreferences?>((ref) => null);
