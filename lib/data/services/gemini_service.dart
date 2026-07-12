import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
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
      throw Exception('API Key is required to analyze startup ideas.');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.2,
        ),
        systemInstruction: Content.system(
          'You are a world-class startup incubator director, venture capital analyst, and entrepreneurship expert.\n'
          'Your job is to analyze startup ideas or website URLs and perform comprehensive market validation and competitor research.\n'
          'Format your entire response as a single, valid JSON object matching the JSON structure below. Do not wrap the JSON in backticks, do not include any explanatory text outside the JSON.\n\n'
          'JSON Schema:\n'
          '{\n'
          '  "businessName": "A catchy, short brand name generated for this startup/website (1-3 words)...",\n'
          '  "priority": "Action validation priority: \'High\', \'Medium\', or \'Low\'...",\n'
          '  "marketView": "A short, punchy summary of market metrics (e.g. \'\$3.4B TAM • 11.8% CAGR\')...",\n'
          '  "summary": "Executive summary of the idea/website business and core value proposition...",\n'
          '  "category": "e.g., FinTech, EdTech, AI & Machine Learning, HealthTech...",\n'
          '  "targetAudience": "Primary and secondary customer segments...",\n'
          '  "customerFeedback": {\n'
          '    "whatCustomersLove": ["Direct quotes or typical opinions on what customers love about existing options or competitors...", "Positive aspect 2..."],\n'
          '    "whatCustomersHate": ["Direct quotes or typical opinions on what customers complain about or hate in existing alternatives...", "Complaint 2..."]\n'
          '  },\n'
          '  "coreProblem": "The main pain point being addressed...",\n'
          '  "proposedSolution": "How the business solves the problem...",\n'
          '  "competitors": [\n'
          '    {\n'
          '      "name": "Competitor Company Name",\n'
          '      "description": "What the competitor does...",\n'
          '      "website": "Official URL or standard domain...",\n'
          '      "pricing": "Estimated pricing details...",\n'
          '      "targetCustomers": "Who they sell to...",\n'
          '      "launchYear": "Year of launch...",\n'
          '      "founderName": "Name of founder(s)...",\n'
          '      "ceo": "CEO name...",\n'
          '      "companySize": "Estimated employee count...",\n'
          '      "headquarters": "City, Country"\n'
          '    }\n'
          '  ],\n'
          '  "swot": {\n'
          '    "strengths": ["Strength 1", "Strength 2", "Strength 3"],\n'
          '    "weaknesses": ["Weakness 1", "Weakness 2", "Weakness 3"],\n'
          '    "opportunities": ["Opportunity 1", "Opportunity 2", "Opportunity 3"],\n'
          '    "threats": ["Threat 1", "Threat 2", "Threat 3"]\n'
          '  },\n'
          '  "marketOpportunity": {\n'
          '    "marketSize": "e.g. \$12.5 Billion TAM by 2028",\n'
          '    "industryGrowth": "e.g. 15.4% CAGR",\n'
          '    "marketMaturity": "e.g. High / Medium / Emerging",\n'
          '    "competitionLevel": "e.g. Intense / Moderate / Low",\n'
          '    "opportunityScore": 85,\n'
          '    "innovationPotential": "Explain how unique or disruptive the concept is..."\n'
          '  },\n'
          '  "scores": {\n'
          '    "innovation": 85,\n'
          '    "marketOpportunity": 80,\n'
          '    "competition": 75,\n'
          '    "feasibility": 90,\n'
          '    "complexity": 70,\n'
          '    "businessPotential": 85,\n'
          '    "revenuePotential": 80,\n'
          '    "overallScore": 81\n'
          '  },\n'
          '  "recommendations": {\n'
          '    "verdict": "Proceed" (or "Pivot" or "Halt"),\n'
          '    "reasoning": "Detailed justification for the verdict...",\n'
          '    "suggestedImprovements": ["Actionable improvement 1", "Actionable improvement 2"],\n'
          '    "missingFeatures": ["Feature 1...", "Feature 2..."],\n'
          '    "monetizationStrategies": ["SaaS subscription", "Freemium"...],\n'
          '    "marketPositioning": "Strategic angle to stand out...",\n'
          '    "risksToConsider": ["Risk 1", "Risk 2"],\n'
          '    "roadmapSteps": ["Phase 1...", "Phase 2..."]\n'
          '  },\n'
          '  "referenceLinks": [\n'
          '    {\n'
          '      "title": "Title/Description of the link (e.g. Analyzed Website, Competitor, Industry Report)...",\n'
          '      "url": "https://..."\n'
          '    }\n'
          '  ]\n'
          '}\n\n'
          'Use your built-in knowledge to search for real-world competitors, websites, pricing, and founder info. If a specific detail is not found, provide a logical estimate. Under customerFeedback, detail what customers love and hate about the existing options in the market. All score numbers MUST be integers between 0 and 100. If a website URL is provided, analyze the business represented by that website, find competitors, and return the analyzed website URL and related resources in the referenceLinks array.',
        ),
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
      throw Exception('API Key is required to generate the MVP prompt.');
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,
      ),
      systemInstruction: Content.system(
        'You are a senior full-stack developer and software architect.\n'
        'Your task is to take a startup validation report and generate a highly comprehensive, production-ready system instructions prompt formatted in Markdown.\n'
        'This prompt will be copied and pasted directly into AI Coding Assistants (e.g. Cursor, Claude, Antigravity) to build the MVP of this business from scratch.\n'
        'Keep the instructions actionable, detailed, and technically precise.',
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
