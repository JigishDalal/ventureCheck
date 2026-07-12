import '../models/validation_report.dart';

class ReportExporter {
  static String toMarkdown(ValidationReport report) {
    final buffer = StringBuffer();
    
    buffer.writeln('# Startup Validation Report: ${report.businessName}');
    buffer.writeln('**Generated on:** ${report.timestamp.toLocal().toString().split('.')[0]}');
    buffer.writeln('**Category:** ${report.category}');
    buffer.writeln('**Action Priority:** ${report.priority} Priority');
    buffer.writeln('**Market Summary:** ${report.marketView}');
    buffer.writeln('**Overall AI Validation Score:** ${report.scores.overallScore}/100');
    buffer.writeln('\n---\n');
    
    buffer.writeln('## 1. Executive Summary');
    buffer.writeln(report.summary);
    buffer.writeln('\n**Idea Description:**');
    buffer.writeln('> ${report.ideaText}');
    buffer.writeln('\n**Core Problem Addressed:**');
    buffer.writeln(report.coreProblem);
    buffer.writeln('\n**Proposed Solution:**');
    buffer.writeln(report.proposedSolution);
    buffer.writeln('\n**Target Audience:**');
    buffer.writeln(report.targetAudience);
    buffer.writeln('\n---\n');
    
    buffer.writeln('## 2. Market Opportunity Analysis');
    buffer.writeln('- **Market Size (TAM):** ${report.marketOpportunity.marketSize}');
    buffer.writeln('- **Industry Growth Rate:** ${report.marketOpportunity.industryGrowth}');
    buffer.writeln('- **Market Maturity:** ${report.marketOpportunity.marketMaturity}');
    buffer.writeln('- **Competition Level:** ${report.marketOpportunity.competitionLevel}');
    buffer.writeln('- **Opportunity Score:** ${report.marketOpportunity.opportunityScore}/100');
    buffer.writeln('- **Innovation Potential:** ${report.marketOpportunity.innovationPotential}');
    buffer.writeln('\n---\n');
    
    buffer.writeln('## 3. Score Breakdown');
    buffer.writeln('- **Innovation Score:** ${report.scores.innovation}/100');
    buffer.writeln('- **Feasibility Score:** ${report.scores.feasibility}/100');
    buffer.writeln('- **Business Potential:** ${report.scores.businessPotential}/100');
    buffer.writeln('- **Revenue Potential:** ${report.scores.revenuePotential}/100');
    buffer.writeln('- **Complexity Score (Lower is Simpler):** ${report.scores.complexity}/100');
    buffer.writeln('\n---\n');

    buffer.writeln('## 4. SWOT Analysis');
    buffer.writeln('### Strengths');
    for (var strength in report.swot.strengths) {
      buffer.writeln('- $strength');
    }
    buffer.writeln('\n### Weaknesses');
    for (var weakness in report.swot.weaknesses) {
      buffer.writeln('- $weakness');
    }
    buffer.writeln('\n### Opportunities');
    for (var opportunity in report.swot.opportunities) {
      buffer.writeln('- $opportunity');
    }
    buffer.writeln('\n### Threats');
    for (var threat in report.swot.threats) {
      buffer.writeln('- $threat');
    }
    buffer.writeln('\n---\n');
    
    buffer.writeln('## 5. Competitor Audit');
    if (report.competitors.isEmpty) {
      buffer.writeln('*No direct competitors identified.*');
    } else {
      for (var comp in report.competitors) {
        buffer.writeln('### ${comp.name}');
        buffer.writeln('- **Description:** ${comp.description}');
        buffer.writeln('- **Website:** ${comp.website}');
        buffer.writeln('- **Pricing Model:** ${comp.pricing}');
        buffer.writeln('- **Target Customers:** ${comp.targetCustomers}');
        buffer.writeln('- **Launch Year:** ${comp.launchYear}');
        buffer.writeln('- **Founder/CEO:** ${comp.ceo.isNotEmpty ? comp.ceo : comp.founderName}');
        buffer.writeln('- **Company Size:** ${comp.companySize}');
        buffer.writeln('- **Headquarters:** ${comp.headquarters}');
        buffer.writeln();
      }
    }
    buffer.writeln('\n---\n');
    
    buffer.writeln('## 6. Strategic Recommendations & Roadmap');
    buffer.writeln('### AI Recommendation Verdict: **${report.recommendations.verdict}**');
    buffer.writeln('\n**Strategic Reasoning:**');
    buffer.writeln(report.recommendations.reasoning);
    buffer.writeln('\n**Suggested Improvements:**');
    for (var imp in report.recommendations.suggestedImprovements) {
      buffer.writeln('- $imp');
    }
    buffer.writeln('\n**Missing Features (Competitor Benchmarking):**');
    for (var feat in report.recommendations.missingFeatures) {
      buffer.writeln('- $feat');
    }
    buffer.writeln('\n**Monetization Strategies:**');
    for (var mon in report.recommendations.monetizationStrategies) {
      buffer.writeln('- $mon');
    }
    buffer.writeln('\n**Market Positioning Statement:**');
    buffer.writeln(report.recommendations.marketPositioning);
    buffer.writeln('\n**Key Risks to Monitor:**');
    for (var risk in report.recommendations.risksToConsider) {
      buffer.writeln('- $risk');
    }
    buffer.writeln('\n**Implementation Roadmap:**');
    for (var i = 0; i < report.recommendations.roadmapSteps.length; i++) {
      buffer.writeln('${i + 1}. ${report.recommendations.roadmapSteps[i]}');
    }
    
    return buffer.toString();
  }
}
