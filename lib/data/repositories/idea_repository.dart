import '../models/validation_report.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';

class IdeaRepository {
  final GeminiService _geminiService;
  final StorageService _storageService;

  IdeaRepository({
    required GeminiService geminiService,
    required StorageService storageService,
  })  : _geminiService = geminiService,
        _storageService = storageService;

  Future<ValidationReport> validateIdea(String ideaText) async {
    final apiKey = _storageService.getGeminiApiKey();

    // Call API service
    final report = await _geminiService.analyzeIdea(
      ideaText: ideaText,
      apiKey: apiKey,
    );

    return report;
  }

  Future<String> generateMvpPrompt(ValidationReport report) async {
    final apiKey = _storageService.getGeminiApiKey();
    return _geminiService.generateMvpPrompt(
      report: report,
      apiKey: apiKey,
    );
  }

  Future<void> saveReport(ValidationReport report) async {
    await _storageService.saveReport(report);
  }

  List<ValidationReport> getSavedReports() {
    return _storageService.getReports();
  }

  Future<void> deleteReport(String id) async {
    await _storageService.deleteReport(id);
  }

  // --- API Key & Settings ---
  
  String getApiKey() => _storageService.getGeminiApiKey();

  Future<void> saveApiKey(String key) async {
    await _storageService.saveGeminiApiKey(key);
  }

  bool isMockMode() => _storageService.getMockModeEnabled();

  Future<void> setMockMode(bool enabled) async {
    await _storageService.saveMockModeEnabled(enabled);
  }
}
