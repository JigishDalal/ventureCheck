import 'package:flutter_test/flutter_test.dart';
import 'package:ventureCheck/data/models/validation_report.dart';
import 'package:ventureCheck/domain/usecases/delete_report_usecase.dart';
import 'package:ventureCheck/domain/usecases/get_reports_usecase.dart';
import 'package:ventureCheck/domain/usecases/validate_idea_usecase.dart';
import 'package:ventureCheck/domain/usecases/save_report_usecase.dart';
import 'package:ventureCheck/ui/bloc/history_bloc.dart';
import 'package:ventureCheck/ui/bloc/validation_bloc.dart';
import 'package:ventureCheck/data/repositories/idea_repository.dart';

// --- Hand-crafted mocks to avoid extra package dependencies ---

class MockIdeaRepository implements IdeaRepository {
  List<ValidationReport> savedReports = [];
  bool mockMode = true;
  String apiKey = 'test-key';

  @override
  Future<ValidationReport> validateIdea(String ideaText) async {
    final report = ValidationReport(
      id: '123',
      ideaText: ideaText,
      timestamp: DateTime(2026, 7, 4),
      summary: 'Mock Summary',
      category: 'FinTech',
      targetAudience: 'Users',
      coreProblem: 'Problem',
      proposedSolution: 'Solution',
      competitors: [],
      swot: SwotAnalysis(strengths: [], weaknesses: [], opportunities: [], threats: []),
      marketOpportunity: MarketOpportunity(
        marketSize: 'TAM',
        industryGrowth: '10%',
        marketMaturity: 'Emerging',
        competitionLevel: 'Low',
        opportunityScore: 80,
        innovationPotential: 'High',
      ),
      scores: ValidationScores(
        innovation: 80,
        marketOpportunity: 80,
        competition: 80,
        feasibility: 80,
        complexity: 20,
        businessPotential: 80,
        revenuePotential: 80,
        overallScore: 80,
      ),
      recommendations: AIRecommendations(
        verdict: 'Proceed',
        reasoning: 'Reason',
        suggestedImprovements: [],
        missingFeatures: [],
        monetizationStrategies: [],
        marketPositioning: 'Position',
        risksToConsider: [],
        roadmapSteps: [],
      ),
      businessName: 'Mock Biz',
      priority: 'High',
      marketView: 'TAM',
      referenceLinks: const [],
      customerFeedback: CustomerFeedback(
        whatCustomersLove: ['Mock Love'],
        whatCustomersHate: ['Mock Hate'],
      ),
      mvpDevPrompt: 'Mock Dev Prompt',
    );
    savedReports.add(report);
    return report;
  }

  @override
  Future<String> generateMvpPrompt(ValidationReport report) async {
    return 'Mock Dev Prompt';
  }

  @override
  List<ValidationReport> getSavedReports() => savedReports;

  @override
  Future<void> saveReport(ValidationReport report) async {
    if (!savedReports.contains(report)) {
      savedReports.add(report);
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    savedReports.removeWhere((r) => r.id == id);
  }

  @override
  String getApiKey() => apiKey;

  @override
  Future<void> saveApiKey(String key) async {
    apiKey = key;
  }

  @override
  bool isMockMode() => mockMode;

  @override
  Future<void> setMockMode(bool enabled) async {
    mockMode = enabled;
  }
}

void main() {
  group('ValidationReport Model Tests', () {
    test('JSON serialization & deserialization works correctly', () {
      final report = ValidationReport(
        id: 'test-id',
        ideaText: 'Test Idea',
        timestamp: DateTime(2026, 7, 4),
        summary: 'Test Summary',
        category: 'AI',
        targetAudience: 'Entrepreneurs',
        coreProblem: 'Lack of ideas',
        proposedSolution: 'This app',
        competitors: [
          Competitor(
            name: 'Comp A',
            description: 'Desc A',
            website: 'web.a',
            pricing: 'Free',
            targetCustomers: 'All',
            launchYear: '2023',
            founderName: 'Founder A',
            ceo: 'CEO A',
            companySize: '10',
            headquarters: 'HQ A',
          ),
        ],
        swot: SwotAnalysis(
          strengths: ['Strength'],
          weaknesses: ['Weakness'],
          opportunities: ['Opportunity'],
          threats: ['Threat'],
        ),
        marketOpportunity: MarketOpportunity(
          marketSize: 'Big',
          industryGrowth: 'Fast',
          marketMaturity: 'Emerging',
          competitionLevel: 'Low',
          opportunityScore: 90,
          innovationPotential: 'High',
        ),
        scores: ValidationScores(
          innovation: 90,
          marketOpportunity: 90,
          competition: 90,
          feasibility: 90,
          complexity: 10,
          businessPotential: 90,
          revenuePotential: 90,
          overallScore: 90,
        ),
        recommendations: AIRecommendations(
          verdict: 'Proceed',
          reasoning: 'Why',
          suggestedImprovements: ['Improve'],
          missingFeatures: ['Feature'],
          monetizationStrategies: ['SaaS'],
          marketPositioning: 'Positioning',
          risksToConsider: ['Risk'],
          roadmapSteps: ['Step 1'],
        ),
        businessName: 'Mock Biz',
        priority: 'High',
        marketView: 'TAM',
        referenceLinks: const [],
        customerFeedback: CustomerFeedback(
          whatCustomersLove: ['Mock Love'],
          whatCustomersHate: ['Mock Hate'],
        ),
        mvpDevPrompt: 'Mock Dev Prompt',
      );

      final jsonMap = report.toJson();
      final parsedReport = ValidationReport.fromJson(jsonMap);

      expect(parsedReport.id, equals('test-id'));
      expect(parsedReport.ideaText, equals('Test Idea'));
      expect(parsedReport.category, equals('AI'));
      expect(parsedReport.competitors.length, equals(1));
      expect(parsedReport.competitors[0].name, equals('Comp A'));
      expect(parsedReport.swot.strengths[0], equals('Strength'));
      expect(parsedReport.scores.overallScore, equals(90));
      expect(parsedReport.recommendations.verdict, equals('Proceed'));
      expect(parsedReport.businessName, equals('Mock Biz'));
      expect(parsedReport.priority, equals('High'));
      expect(parsedReport.marketView, equals('TAM'));
      expect(parsedReport.customerFeedback.whatCustomersLove[0], equals('Mock Love'));
      expect(parsedReport.customerFeedback.whatCustomersHate[0], equals('Mock Hate'));
      expect(parsedReport.mvpDevPrompt, equals('Mock Dev Prompt'));
    });
  });

  group('HistoryBloc Tests', () {
    late MockIdeaRepository repository;
    late GetReportsUseCase getReportsUseCase;
    late DeleteReportUseCase deleteReportUseCase;
    late SaveReportUseCase saveReportUseCase;
    late HistoryBloc historyBloc;

    setUp(() {
      repository = MockIdeaRepository();
      getReportsUseCase = GetReportsUseCase(repository);
      deleteReportUseCase = DeleteReportUseCase(repository);
      saveReportUseCase = SaveReportUseCase(repository);
      historyBloc = HistoryBloc(
        getReportsUseCase: getReportsUseCase,
        deleteReportUseCase: deleteReportUseCase,
        saveReportUseCase: saveReportUseCase,
      );
    });

    tearDown(() {
      historyBloc.close();
    });

    test('Initial state is HistoryInitial', () {
      expect(historyBloc.state, isA<HistoryInitial>());
    });

    test('LoadHistory emits HistoryLoading and then HistoryLoaded', () async {
      final expectedStates = [
        isA<HistoryLoading>(),
        isA<HistoryLoaded>(),
      ];

      expectLater(historyBloc.stream, emitsInOrder(expectedStates));
      historyBloc.add(LoadHistory());
    });

    test('DeleteReport removes report and updates state', () async {
      await repository.validateIdea('Test Idea');
      expect(repository.getSavedReports().length, equals(1));

      final expectedStates = [
        isA<HistoryLoaded>().having((state) => state.reports.length, 'reports length', 0),
      ];

      expectLater(historyBloc.stream, emitsInOrder(expectedStates));
      historyBloc.add(DeleteReport('123'));
    });
  });

  group('ValidationBloc Tests', () {
    late MockIdeaRepository repository;
    late ValidateIdeaUseCase validateIdeaUseCase;
    late ValidationBloc validationBloc;

    setUp(() {
      repository = MockIdeaRepository();
      validateIdeaUseCase = ValidateIdeaUseCase(repository);
      validationBloc = ValidationBloc(validateIdeaUseCase: validateIdeaUseCase);
    });

    tearDown(() {
      validationBloc.close();
    });

    test('Initial state is ValidationInitial', () {
      expect(validationBloc.state, isA<ValidationInitial>());
    });

    test('ValidateIdeaEvent emits ValidationInProgress progress updates followed by ValidationSuccess', () async {
      final expectedStates = [
        isA<ValidationInProgress>().having((s) => s.progressPercent, 'progress', 0.1),
        isA<ValidationInProgress>().having((s) => s.progressPercent, 'progress', 0.35),
        isA<ValidationInProgress>().having((s) => s.progressPercent, 'progress', 0.55),
        isA<ValidationInProgress>().having((s) => s.progressPercent, 'progress', 0.75),
        isA<ValidationInProgress>().having((s) => s.progressPercent, 'progress', 0.90),
        isA<ValidationSuccess>(),
      ];

      expectLater(validationBloc.stream, emitsInOrder(expectedStates));
      validationBloc.add(ValidateIdeaEvent('Offline expense tracker'));
    });
  });
}
