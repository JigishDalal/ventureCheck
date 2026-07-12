import 'dart:convert';

class ValidationReport {
  final String id;
  final String ideaText;
  final DateTime timestamp;
  final String summary;
  final String category;
  final String targetAudience;
  final String coreProblem;
  final String proposedSolution;
  final List<Competitor> competitors;
  final SwotAnalysis swot;
  final MarketOpportunity marketOpportunity;
  final ValidationScores scores;
  final AIRecommendations recommendations;
  final String businessName;
  final String priority;
  final String marketView;
  final List<ReferenceLink> referenceLinks;
  final CustomerFeedback customerFeedback;
  final String mvpDevPrompt;

  ValidationReport({
    required this.id,
    required this.ideaText,
    required this.timestamp,
    required this.summary,
    required this.category,
    required this.targetAudience,
    required this.coreProblem,
    required this.proposedSolution,
    required this.competitors,
    required this.swot,
    required this.marketOpportunity,
    required this.scores,
    required this.recommendations,
    required this.businessName,
    required this.priority,
    required this.marketView,
    required this.referenceLinks,
    required this.customerFeedback,
    required this.mvpDevPrompt,
  });

  factory ValidationReport.fromJson(Map<String, dynamic> json) {
    var competitorsList = json['competitors'] as List? ?? [];
    List<Competitor> competitors = competitorsList
        .map((c) => Competitor.fromJson(Map<String, dynamic>.from(c)))
        .toList();

    var referenceLinksList = json['referenceLinks'] as List? ?? [];
    List<ReferenceLink> referenceLinks = referenceLinksList
        .map((r) => ReferenceLink.fromJson(Map<String, dynamic>.from(r)))
        .toList();

    return ValidationReport(
      id: json['id'] ?? '',
      ideaText: json['ideaText'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      summary: json['summary'] ?? '',
      category: json['category'] ?? '',
      targetAudience: json['targetAudience'] ?? '',
      coreProblem: json['coreProblem'] ?? '',
      proposedSolution: json['proposedSolution'] ?? '',
      competitors: competitors,
      swot: SwotAnalysis.fromJson(
        Map<String, dynamic>.from(json['swot'] ?? {}),
      ),
      marketOpportunity: MarketOpportunity.fromJson(
        Map<String, dynamic>.from(json['marketOpportunity'] ?? {}),
      ),
      scores: ValidationScores.fromJson(
        Map<String, dynamic>.from(json['scores'] ?? {}),
      ),
      recommendations: AIRecommendations.fromJson(
        Map<String, dynamic>.from(json['recommendations'] ?? {}),
      ),
      businessName: json['businessName'] ?? 'Unnamed Project',
      priority: json['priority'] ?? 'Medium',
      marketView: json['marketView'] ?? 'N/A',
      referenceLinks: referenceLinks,
      customerFeedback: CustomerFeedback.fromJson(
        Map<String, dynamic>.from(json['customerFeedback'] ?? {}),
      ),
      mvpDevPrompt: json['mvpDevPrompt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ideaText': ideaText,
      'timestamp': timestamp.toIso8601String(),
      'summary': summary,
      'category': category,
      'targetAudience': targetAudience,
      'coreProblem': coreProblem,
      'proposedSolution': proposedSolution,
      'competitors': competitors.map((c) => c.toJson()).toList(),
      'swot': swot.toJson(),
      'marketOpportunity': marketOpportunity.toJson(),
      'scores': scores.toJson(),
      'recommendations': recommendations.toJson(),
      'businessName': businessName,
      'priority': priority,
      'marketView': marketView,
      'referenceLinks': referenceLinks.map((r) => r.toJson()).toList(),
      'customerFeedback': customerFeedback.toJson(),
      'mvpDevPrompt': mvpDevPrompt,
    };
  }
}

class Competitor {
  final String name;
  final String description;
  final String website;
  final String pricing;
  final String targetCustomers;
  final String launchYear;
  final String founderName;
  final String ceo;
  final String companySize;
  final String headquarters;

  Competitor({
    required this.name,
    required this.description,
    required this.website,
    required this.pricing,
    required this.targetCustomers,
    required this.launchYear,
    required this.founderName,
    required this.ceo,
    required this.companySize,
    required this.headquarters,
  });

  factory Competitor.fromJson(Map<String, dynamic> json) {
    return Competitor(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      website: json['website'] ?? '',
      pricing: json['pricing'] ?? '',
      targetCustomers: json['targetCustomers'] ?? '',
      launchYear: json['launchYear']?.toString() ?? '',
      founderName: json['founderName'] ?? '',
      ceo: json['ceo'] ?? '',
      companySize: json['companySize'] ?? '',
      headquarters: json['headquarters'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'website': website,
      'pricing': pricing,
      'targetCustomers': targetCustomers,
      'launchYear': launchYear,
      'founderName': founderName,
      'ceo': ceo,
      'companySize': companySize,
      'headquarters': headquarters,
    };
  }
}

class SwotAnalysis {
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> opportunities;
  final List<String> threats;

  SwotAnalysis({
    required this.strengths,
    required this.weaknesses,
    required this.opportunities,
    required this.threats,
  });

  factory SwotAnalysis.fromJson(Map<String, dynamic> json) {
    return SwotAnalysis(
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      opportunities: List<String>.from(json['opportunities'] ?? []),
      threats: List<String>.from(json['threats'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strengths': strengths,
      'weaknesses': weaknesses,
      'opportunities': opportunities,
      'threats': threats,
    };
  }
}

class MarketOpportunity {
  final String marketSize;
  final String industryGrowth;
  final String marketMaturity;
  final String competitionLevel;
  final int opportunityScore;
  final String innovationPotential;

  MarketOpportunity({
    required this.marketSize,
    required this.industryGrowth,
    required this.marketMaturity,
    required this.competitionLevel,
    required this.opportunityScore,
    required this.innovationPotential,
  });

  factory MarketOpportunity.fromJson(Map<String, dynamic> json) {
    return MarketOpportunity(
      marketSize: json['marketSize'] ?? '',
      industryGrowth: json['industryGrowth'] ?? '',
      marketMaturity: json['marketMaturity'] ?? '',
      competitionLevel: json['competitionLevel'] ?? '',
      opportunityScore: json['opportunityScore'] ?? 0,
      innovationPotential: json['innovationPotential'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'marketSize': marketSize,
      'industryGrowth': industryGrowth,
      'marketMaturity': marketMaturity,
      'competitionLevel': competitionLevel,
      'opportunityScore': opportunityScore,
      'innovationPotential': innovationPotential,
    };
  }
}

class ValidationScores {
  final int innovation;
  final int marketOpportunity;
  final int competition;
  final int feasibility;
  final int complexity;
  final int businessPotential;
  final int revenuePotential;
  final int overallScore;

  ValidationScores({
    required this.innovation,
    required this.marketOpportunity,
    required this.competition,
    required this.feasibility,
    required this.complexity,
    required this.businessPotential,
    required this.revenuePotential,
    required this.overallScore,
  });

  factory ValidationScores.fromJson(Map<String, dynamic> json) {
    return ValidationScores(
      innovation: json['innovation'] ?? 0,
      marketOpportunity: json['marketOpportunity'] ?? 0,
      competition: json['competition'] ?? 0,
      feasibility: json['feasibility'] ?? 0,
      complexity: json['complexity'] ?? 0,
      businessPotential: json['businessPotential'] ?? 0,
      revenuePotential: json['revenuePotential'] ?? 0,
      overallScore: json['overallScore'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'innovation': innovation,
      'marketOpportunity': marketOpportunity,
      'competition': competition,
      'feasibility': feasibility,
      'complexity': complexity,
      'businessPotential': businessPotential,
      'revenuePotential': revenuePotential,
      'overallScore': overallScore,
    };
  }
}

class AIRecommendations {
  final String verdict;
  final String reasoning;
  final List<String> suggestedImprovements;
  final List<String> missingFeatures;
  final List<String> monetizationStrategies;
  final String marketPositioning;
  final List<String> risksToConsider;
  final List<String> roadmapSteps;

  AIRecommendations({
    required this.verdict,
    required this.reasoning,
    required this.suggestedImprovements,
    required this.missingFeatures,
    required this.monetizationStrategies,
    required this.marketPositioning,
    required this.risksToConsider,
    required this.roadmapSteps,
  });

  factory AIRecommendations.fromJson(Map<String, dynamic> json) {
    return AIRecommendations(
      verdict: json['verdict'] ?? '',
      reasoning: json['reasoning'] ?? '',
      suggestedImprovements: List<String>.from(json['suggestedImprovements'] ?? []),
      missingFeatures: List<String>.from(json['missingFeatures'] ?? []),
      monetizationStrategies: List<String>.from(json['monetizationStrategies'] ?? []),
      marketPositioning: json['marketPositioning'] ?? '',
      risksToConsider: List<String>.from(json['risksToConsider'] ?? []),
      roadmapSteps: List<String>.from(json['roadmapSteps'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verdict': verdict,
      'reasoning': reasoning,
      'suggestedImprovements': suggestedImprovements,
      'missingFeatures': missingFeatures,
      'monetizationStrategies': monetizationStrategies,
      'marketPositioning': marketPositioning,
      'risksToConsider': risksToConsider,
      'roadmapSteps': roadmapSteps,
    };
  }
}

class ReferenceLink {
  final String title;
  final String url;

  ReferenceLink({
    required this.title,
    required this.url,
  });

  factory ReferenceLink.fromJson(Map<String, dynamic> json) {
    return ReferenceLink(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
    };
  }
}

class CustomerFeedback {
  final List<String> whatCustomersLove;
  final List<String> whatCustomersHate;

  CustomerFeedback({
    required this.whatCustomersLove,
    required this.whatCustomersHate,
  });

  factory CustomerFeedback.fromJson(Map<String, dynamic> json) {
    return CustomerFeedback(
      whatCustomersLove: List<String>.from(json['whatCustomersLove'] ?? []),
      whatCustomersHate: List<String>.from(json['whatCustomersHate'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'whatCustomersLove': whatCustomersLove,
      'whatCustomersHate': whatCustomersHate,
    };
  }
}
