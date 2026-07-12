import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/app_constants.dart';
import '../models/validation_report.dart';

class GeminiService {
  bool _isUrl(String text) {
    final trimmed = text.trim();
    return trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        RegExp(r'^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}(/.*)?$').hasMatch(trimmed);
  }

  Future<String> _fetchWebsiteContent(String urlString) async {
    String normalizedUrl = urlString.trim();
    if (!normalizedUrl.startsWith('http://') && !normalizedUrl.startsWith('https://')) {
      normalizedUrl = 'https://$normalizedUrl';
    }
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse(normalizedUrl));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final cleanText = body
            .replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>'), '')
            .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>'), '')
            .replaceAll(RegExp(r'<[^>]*>'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        
        if (cleanText.length > 5000) {
          return cleanText.substring(0, 5000);
        }
        return cleanText;
      }
    } catch (e) {
      debugPrint('Error fetching website $urlString: $e');
    }
    return '';
  }

  Future<ValidationReport> analyzeIdea({
    required String ideaText,
    required String apiKey,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception(AppConstants.errorApiKeyRequired);
    }

    try {
      final model = GenerativeModel(
        model: AppConstants.geminiModel,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: AppConstants.apiTemperatureValidate,
        ),
        systemInstruction: Content.system(AppConstants.systemInstructionAnalyze),
      );

      String targetPrompt = 'Please validate this startup idea: "$ideaText"';
      if (_isUrl(ideaText)) {
        final siteContent = await _fetchWebsiteContent(ideaText);
        if (siteContent.isNotEmpty) {
          targetPrompt = 'Please analyze this business/website at URL "$ideaText". Here is some scraped visible text content from the website:\n\n$siteContent\n\nAnalyze what business it represents, what product/service it provides, its target audience, and evaluate it as a business idea.';
        } else {
          targetPrompt = 'Please analyze this business/website at URL "$ideaText". (Note: The URL could not be crawled, so please use your internal knowledge base about this domain or similar businesses to perform the analysis).';
        }
      }

      final response = await model.generateContent([Content.text(targetPrompt)]);

      final String? responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      // Try parsing JSON
      final Map<String, dynamic> jsonMap = json.decode(responseText.trim());

      // Inject user-defined details
      jsonMap['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      jsonMap['ideaText'] = ideaText;
      jsonMap['timestamp'] = DateTime.now().toIso8601String();

      return ValidationReport.fromJson(jsonMap);
    } catch (e) {
      debugPrint(
        'Gemini Service Error: $e. Falling back to structured parsing.',
      );
      rethrow;
    }
  }

  Future<String> generateMvpPrompt({
    required ValidationReport report,
    required String apiKey,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception(AppConstants.errorApiKeyRequired);
    }

    final model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: AppConstants.apiTemperatureMvp,
      ),
      systemInstruction: Content.system(
        AppConstants.systemInstructionMvpPrompt,
      ),
    );

    final String targetPrompt = '''
Please generate a developer MVP coding prompt based on the following startup validation details:

- Business Name: ${report.businessName}
- Summary: ${report.summary}
- Target Audience: ${report.targetAudience}
- Core Problem: ${report.coreProblem}
- Proposed Solution: ${report.proposedSolution}
- Key Competitors & Pricing: ${report.competitors.map((c) => '${c.name} (${c.pricing})').join(', ')}
- Suggested Monetization: ${report.recommendations.monetizationStrategies.join(', ')}
- Missing Features to Build: ${report.recommendations.missingFeatures.join(', ')}
- What Customers Love (Leverage): ${report.customerFeedback.whatCustomersLove.join(', ')}
- What Customers Hate (Resolve): ${report.customerFeedback.whatCustomersHate.join(', ')}

Structure the generated prompt exactly like this:
# Role & Context
You are a senior full-stack developer. Your task is to build the MVP for [Business Name]: [Core Value Proposition].

# 1. Tech Stack, Architecture & Dependencies
- Frontend/Backend: Recommend standard frameworks (e.g. Flutter, React, Node.js) based on the idea. If it needs a backend API, web dashboard, and mobile app, provide separate subsections/configs for each.
- Folder Structure & Architecture: Outline the file layout and architecture.
- Packages & Libraries: Specify required dependencies to install.

# 2. Complete Modules & Feature Checklist
Detailed feature list divided into functional modules/components.

# 3. Customer-Feedback-Driven Enhancements
- Resolved Complaints (What Customers Hate about alternatives)
- Value Additions (What Customers Love)

# 4. Security & Protection Guidelines
Include rules for secrets management (.env), secure authentication (hashing, tokens), input sanitization, CORS, and network protection.

# 5. Code Quality & Best Practices
Include rules for separation of concerns, global error handling/logging, and performance optimization.

# 6. Step-by-Step Build Instructions
A sequential blueprint to code and deploy the MVP.
''';

    final response = await model.generateContent([Content.text(targetPrompt)]);
    return response.text ?? '';
  }
}
