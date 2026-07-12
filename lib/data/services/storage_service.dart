import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/validation_report.dart';

class StorageService {
  static const String _reportsKey = 'startup_validation_reports';
  static const String _apiKeyKey = 'gemini_api_key';
  static const String _mockModeKey = 'mock_mode_enabled';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Initialize helper
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Reports ---
  
  List<ValidationReport> getReports() {
    final List<String>? reportsJson = _prefs.getStringList(_reportsKey);
    if (reportsJson == null) return [];

    try {
      return reportsJson
          .map((jsonStr) => ValidationReport.fromJson(json.decode(jsonStr)))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  Future<void> saveReport(ValidationReport report) async {
    final reports = getReports();
    
    // Remove if already exists (updating)
    reports.removeWhere((r) => r.id == report.id);
    reports.add(report);

    final List<String> reportsJson =
        reports.map((r) => json.encode(r.toJson())).toList();
    await _prefs.setStringList(_reportsKey, reportsJson);
  }

  Future<void> deleteReport(String id) async {
    final reports = getReports();
    reports.removeWhere((r) => r.id == id);

    final List<String> reportsJson =
        reports.map((r) => json.encode(r.toJson())).toList();
    await _prefs.setStringList(_reportsKey, reportsJson);
  }

  // --- Gemini API Key ---
  
  String getGeminiApiKey() {
    return _prefs.getString(_apiKeyKey) ?? '';
  }

  Future<void> saveGeminiApiKey(String apiKey) async {
    await _prefs.setString(_apiKeyKey, apiKey.trim());
  }

  // --- Mock Mode ---
  
  bool getMockModeEnabled() {
    return _prefs.getBool(_mockModeKey) ?? false;
  }

  Future<void> saveMockModeEnabled(bool enabled) async {
    await _prefs.setBool(_mockModeKey, enabled);
  }
}
