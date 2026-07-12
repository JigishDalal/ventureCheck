class AppConstants {
  // --- Gemini API Configurations ---
  static const String geminiModel = 'gemini-2.5-flash-lite';
  static const double apiTemperatureValidate = 0.2;
  static const double apiTemperatureMvp = 0.3;

  // --- Gemini System Instruction: Analyze Idea ---
  static const String systemInstructionAnalyze = 
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
      '      "title": "Title/Description of the link (e.g. Website, Competitor, Industry Report)...",\n'
      '      "url": "https://..."\n'
      '    }\n'
      '  ]\n'
      '}\n\n'
      'Use your built-in knowledge to search for real-world competitors, websites, pricing, and founder info. If a specific detail is not found, provide a logical estimate. Under customerFeedback, detail what customers love and hate about the existing options in the market. All score numbers MUST be integers between 0 and 100. If a website URL is provided, analyze the business represented by that website, find competitors, and return the analyzed website URL and related resources in the referenceLinks array.';

  // --- Gemini System Instruction: Generate MVP Prompt ---
  static const String systemInstructionMvpPrompt = 
      'You are a senior full-stack developer and software architect.\n'
      'Your task is to take a startup validation report and generate a highly comprehensive, production-ready system instructions prompt formatted in Markdown.\n'
      'This prompt will be copied and pasted directly into AI Coding Assistants (e.g. Cursor, Claude, Antigravity) to build the MVP of this business from scratch.\n'
      'Keep the instructions actionable, detailed, and technically precise.';

  // --- User-facing UI Texts & Messages ---
  static const String appTitle = 'VentureCheck';
  static const String appTagline = 'AI Startup Validator';
  
  // Dashboard
  static const String dashboardTitle = 'My Workspace';
  static const String dashboardSubtitle = 'Validate startup concepts & plan MVPs in minutes';
  static const String emptyHistoryTitle = 'No Startup Ideas Validated Yet';
  static const String emptyHistorySubtitle = 'Validate your first idea by tapping the plus button below.';
  static const String deleteReportMessage = 'validation report deleted successfully.';
  static const String confirmDeleteTitle = 'Delete Report?';
  static const String confirmDeleteContent = 'Are you sure you want to permanently delete this report from history?';
  
  // Idea Entry
  static const String ideaEntryTitle = 'Validate Idea';
  static const String ideaEntryPlaceholder = 'e.g. A marketplace matching freelance mobile app developers with small businesses in India, offering escrow payments and verified skill badges.';
  static const String validateButtonText = 'Analyze Startup Idea';
  
  // Settings
  static const String settingsTitle = 'Settings';
  static const String apiKeyLabel = 'Gemini API Key';
  static const String apiKeyPlaceholder = 'Enter your Gemini API Key';
  static const String saveApiKeySuccess = 'API key saved successfully!';
  static const String emptyApiKeyWarning = 'Please configure your Gemini API Key in Settings first.';

  // Report Detail
  static const String reportDetailsTitle = 'Validation Report';
  static const String exitReviewTitle = 'Exit Review?';
  static const String exitReviewContent = 'Are you sure you want to exit without saving? This validation report will be permanently lost.';
  static const String saveReportSuccess = 'saved to history list!';
  static const String copyPromptSuccess = 'Prompt copied to clipboard!';
  
  // Error handling
  static const String errorEmptyResponse = 'Empty response from Gemini API';
  static const String errorApiKeyRequired = 'API Key is required to analyze startup ideas.';
}
