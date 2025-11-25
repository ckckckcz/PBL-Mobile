import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history_model.dart';

class ScanHistoryService {
  static const String _historyKey = 'scan_history';

  // Get all scan history
  Future<List<ScanHistory>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_historyKey);

      if (historyJson == null || historyJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded.map((json) => ScanHistory.fromJson(json)).toList();
    } catch (e) {
      print('Error loading history: $e');
      return [];
    }
  }

  // Save new scan to history
  Future<bool> saveScan(ScanHistory scan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      // Add new scan at the beginning
      history.insert(0, scan);

      // Keep only last 50 scans
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }

      final String encoded = jsonEncode(
        history.map((scan) => scan.toJson()).toList(),
      );

      return await prefs.setString(_historyKey, encoded);
    } catch (e) {
      print('Error saving scan: $e');
      return false;
    }
  }

  // Delete a scan by ID
  Future<bool> deleteScan(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      history.removeWhere((scan) => scan.id == id);

      final String encoded = jsonEncode(
        history.map((scan) => scan.toJson()).toList(),
      );

      return await prefs.setString(_historyKey, encoded);
    } catch (e) {
      print('Error deleting scan: $e');
      return false;
    }
  }

  // Clear all history
  Future<bool> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing history: $e');
      return false;
    }
  }

  // Get scan by ID
  Future<ScanHistory?> getScanById(String id) async {
    try {
      final history = await getHistory();
      return history.firstWhere(
        (scan) => scan.id == id,
        orElse: () => throw Exception('Scan not found'),
      );
    } catch (e) {
      print('Error getting scan: $e');
      return null;
    }
  }

  // Get history count
  Future<int> getHistoryCount() async {
    final history = await getHistory();
    return history.length;
  }
}
