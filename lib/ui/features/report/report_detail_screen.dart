import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/history_bloc.dart';
import '../../theme/app_theme.dart';
import '../../../data/models/validation_report.dart';
import '../../../data/services/report_exporter.dart';
import '../../../data/services/pdf_exporter.dart';
import '../../../data/repositories/idea_repository.dart';
import '../../../data/constants/app_constants.dart';

class ReportDetailScreen extends StatefulWidget {
  final ValidationReport report;
  final bool isNewReport;
  final IdeaRepository repository;

  const ReportDetailScreen({
    super.key,
    required this.report,
    required this.repository,
    this.isNewReport = false,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late ValidationReport _currentReport;
  bool _isGeneratingPrompt = false;
  int _currentStep = 0;

  static const List<Map<String, dynamic>> _steps = [
    {'title': 'Overview', 'icon': Icons.insights_rounded},
    {'title': 'SWOT Analysis', 'icon': Icons.grid_view_rounded},
    {'title': 'Competitors', 'icon': Icons.people_outline_rounded},
    {'title': 'Customer Feedback', 'icon': Icons.chat_bubble_outline_rounded},
    {'title': 'Launch Strategy', 'icon': Icons.trending_up_rounded},
    {'title': 'Reference Links', 'icon': Icons.link_rounded},
    {'title': 'MVP Prompt', 'icon': Icons.bolt_rounded, 'isPremium': true},
  ];

  @override
  void initState() {
    super.initState();
    _currentReport = widget.report;
  }

  ValidationReport get report => _currentReport;

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.strengthColor;
    if (score >= 60) return AppTheme.weaknessColor;
    return AppTheme.threatColor;
  }

  Widget _buildCircularScore(String title, int score) {
    final color = _getScoreColor(score);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 76,
              height: 76,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation(
                  Colors.black.withOpacity(0.05),
                ),
              ),
            ),
            SizedBox(
              width: 76,
              height: 76,
              child: CircularProgressIndicator(
                value: score / 100.0,
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMetricBar(String label, int score) {
    final color = _getScoreColor(score);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              Text(
                '$score/100',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              color: Colors.black.withOpacity(0.05),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: score / 100.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.7), color],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwotCard(
    String title,
    List<String> items,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const Divider(color: AppTheme.dividerColor, height: 16),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        items[i],
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.secondaryTextColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Export Validation Report',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: AppTheme.strengthColor,
                ),
                title: const Text(
                  'Export as PDF Document',
                  style: TextStyle(color: AppTheme.primaryTextColor),
                ),
                subtitle: const Text(
                  'Generate, save or print a beautifully styled PDF report',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                  try {
                    final pdfBytes = await PdfExporter.generatePdf(report);
                    if (context.mounted) Navigator.pop(context);
                    await Printing.sharePdf(
                      bytes: pdfBytes,
                      filename:
                          'validation_report_${report.businessName.replaceAll(RegExp(r'\s+'), '_').toLowerCase()}.pdf',
                    );
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to generate PDF: $e'),
                          backgroundColor: AppTheme.threatColor,
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.share_outlined,
                  color: AppTheme.primaryColor,
                ),
                title: const Text(
                  'Share Complete Report',
                  style: TextStyle(color: AppTheme.primaryTextColor),
                ),
                subtitle: const Text(
                  'Send via email, message or notes in Markdown format',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  final markdown = ReportExporter.toMarkdown(report);
                  Share.share(
                    markdown,
                    subject: 'Projectthink Report: ${report.businessName}',
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.copy_outlined,
                  color: AppTheme.accentColor,
                ),
                title: const Text(
                  'Copy to Clipboard',
                  style: TextStyle(color: AppTheme.primaryTextColor),
                ),
                subtitle: const Text(
                  'Copy formatted report markdown text to clipboard',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final markdown = ReportExporter.toMarkdown(report);
                  await Clipboard.setData(ClipboardData(text: markdown));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Report copied to clipboard!'),
                          ],
                        ),
                        backgroundColor: AppTheme.accentColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    final currentStepInfo = _steps[_currentStep];
    final title = currentStepInfo['title'] as String;
    final icon = currentStepInfo['icon'] as IconData;
    final isPremium = currentStepInfo['isPremium'] == true;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: AppTheme.glassBox(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: isPremium ? AppTheme.secondaryColor : AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP ${_currentStep + 1} OF ${_steps.length}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTextColor,
                            ),
                          ),
                          if (isPremium) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: AppTheme.premiumGradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${((_currentStep + 1) / _steps.length * 100).toInt()}% Done',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * ((_currentStep + 1) / _steps.length),
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: isPremium ? AppTheme.premiumGradient : AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          final isPremium = _steps[index]['isPremium'] == true;

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentStep = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 10,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: isActive
                    ? (isPremium ? AppTheme.premiumGradient : AppTheme.primaryGradient)
                    : null,
                color: isActive
                    ? null
                    : (isCompleted
                        ? (isPremium ? AppTheme.secondaryColor.withOpacity(0.4) : AppTheme.primaryColor.withOpacity(0.4))
                        : Colors.grey[300]),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepBody(BuildContext context, Color verdictColor) {
    switch (_currentStep) {
      case 0:
        return _buildOverviewTab(context, verdictColor);
      case 1:
        return _buildSwotTab(context);
      case 2:
        return _buildCompetitorsTab(context);
      case 3:
        return _buildFeedbackTab(context);
      case 4:
        return _buildStrategyTab(context, verdictColor);
      case 5:
        return _buildReferencesTab(context);
      case 6:
        return _buildMvpPromptTab(context);
      default:
        return _buildOverviewTab(context, verdictColor);
    }
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.black.withOpacity(0.08)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < _steps.length - 1) {
                    setState(() {
                      _currentStep++;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      _currentStep == _steps.length - 1 ? 'Finish' : 'Next Step',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onBackPress(BuildContext context) async {
    if (!widget.isNewReport) return true;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          AppConstants.exitReviewTitle,
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          AppConstants.exitReviewContent,
          style: TextStyle(color: AppTheme.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Exit',
              style: TextStyle(color: AppTheme.threatColor),
            ),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  void _saveAndGoHome(BuildContext context) {
    context.read<HistoryBloc>().add(SaveReport(report));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('"${report.businessName}" ${AppConstants.saveReportSuccess}'),
          ],
        ),
        backgroundColor: AppTheme.strengthColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final verdictColor = report.recommendations.verdict == 'Proceed'
        ? AppTheme.strengthColor
        : report.recommendations.verdict == 'Pivot'
        ? AppTheme.weaknessColor
        : AppTheme.threatColor;

    return PopScope(
      canPop: !widget.isNewReport,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onBackPress(context);
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(report.businessName),
          leading: IconButton(
            onPressed: () async {
              if (await _onBackPress(context)) {
                if (context.mounted) Navigator.pop(context);
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppTheme.primaryTextColor,
            ),
          ),
          actions: [
            if (widget.isNewReport)
              IconButton(
                icon: const Icon(Icons.save_rounded, color: AppTheme.primaryColor),
                onPressed: () => _saveAndGoHome(context),
              ),
            IconButton(
              icon: const Icon(Icons.share, color: AppTheme.primaryTextColor),
              onPressed: () => _showShareOptions(context),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildStepIndicator(),
                  _buildStepDots(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: KeyedSubtree(
                        key: ValueKey<int>(_currentStep),
                        child: _buildStepBody(context, verdictColor),
                      ),
                    ),
                  ),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, Color verdictColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Idea Summary Card
          Container(
            width: double.infinity,
            decoration: AppTheme.glassBox(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          report.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: verdictColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: verdictColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        report.recommendations.verdict.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: verdictColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'BUSINESS IDEA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.ideaText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                    height: 1.4,
                  ),
                ),
                const Divider(color: AppTheme.dividerColor, height: 28),
                const Text(
                  'EXECUTIVE SUMMARY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  report.summary,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryTextColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Scores Row
          const Text(
            'VALIDATION METRICS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: AppTheme.glassBox(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCircularScore(
                      'Overall Score',
                      report.scores.overallScore,
                    ),
                    _buildCircularScore(
                      'Feasibility',
                      report.scores.feasibility,
                    ),
                    _buildCircularScore('Innovation', report.scores.innovation),
                  ],
                ),
                const SizedBox(height: 24),
                _buildMetricBar(
                  'Market Opportunity',
                  report.scores.marketOpportunity,
                ),
                _buildMetricBar(
                  'Business Potential',
                  report.scores.businessPotential,
                ),
                _buildMetricBar(
                  'Revenue Potential',
                  report.scores.revenuePotential,
                ),
                _buildMetricBar(
                  'Low Technical Complexity',
                  100 - report.scores.complexity,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Problem & Solution Breakdown
          const Text(
            'PROBLEM & SOLUTION ALIGNMENT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: AppTheme.glassBox(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.orangeAccent,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Core Problem',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.coreProblem,
                            style: const TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Divider(color: AppTheme.dividerColor),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.accentColor,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Proposed Solution',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.proposedSolution,
                            style: const TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitorsTab(BuildContext context) {
    if (report.competitors.isEmpty) {
      return const Center(
        child: Text(
          'No direct competitors identified.',
          style: TextStyle(color: AppTheme.secondaryTextColor),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: report.competitors.length,
      itemBuilder: (context, i) {
        final competitor = report.competitors[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top line
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      competitor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                    if (competitor.launchYear.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.borderLightColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Est. ${competitor.launchYear}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  competitor.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.secondaryTextColor,
                    height: 1.4,
                  ),
                ),

                const Divider(color: AppTheme.dividerColor, height: 24),

                // Details Grid
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pricing',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            competitor.pricing.isNotEmpty
                                ? competitor.pricing
                                : 'N/A',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Target Customers',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            competitor.targetCustomers.isNotEmpty
                                ? competitor.targetCustomers
                                : 'N/A',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Founder/CEO',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            competitor.ceo.isNotEmpty
                                ? competitor.ceo
                                : competitor.founderName.isNotEmpty
                                ? competitor.founderName
                                : 'Unknown',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HQ',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            competitor.headquarters.isNotEmpty
                                ? competitor.headquarters
                                : 'N/A',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Website Link
                GestureDetector(
                  onTap: () => _launchURL(competitor.website),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.link,
                        size: 16,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        competitor.website.isNotEmpty
                            ? competitor.website
                            : 'No website available',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwotTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
        children: [
          _buildSwotCard(
            'Strengths',
            report.swot.strengths,
            AppTheme.strengthColor,
            Icons.add_circle_outline,
          ),
          _buildSwotCard(
            'Weaknesses',
            report.swot.weaknesses,
            AppTheme.weaknessColor,
            Icons.remove_circle_outline,
          ),
          _buildSwotCard(
            'Opportunities',
            report.swot.opportunities,
            AppTheme.opportunityColor,
            Icons.trending_up,
          ),
          _buildSwotCard(
            'Threats',
            report.swot.threats,
            AppTheme.threatColor,
            Icons.warning_amber_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyTab(BuildContext context, Color verdictColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Size & Landscape
          const Text(
            'MARKET SIZE & GROWTH',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: AppTheme.glassBox(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Addressable Market (TAM)',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        report.marketOpportunity.marketSize,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppTheme.dividerColor, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Industry Growth Rate',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        report.marketOpportunity.industryGrowth,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppTheme.dividerColor, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Market Maturity',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        report.marketOpportunity.marketMaturity,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppTheme.dividerColor, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Competition Intensity',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        report.marketOpportunity.competitionLevel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Strategic Verdict
          const Text(
            'AI RECOMMENDATION VERDICT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: verdictColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: verdictColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      report.recommendations.verdict == 'Proceed'
                          ? Icons.check_circle
                          : report.recommendations.verdict == 'Pivot'
                          ? Icons.swap_horiz
                          : Icons.cancel,
                      color: verdictColor,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Verdict: ${report.recommendations.verdict}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: verdictColor,
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppTheme.dividerColor, height: 24),
                Text(
                  report.recommendations.reasoning,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Suggested Improvements & Monetization
          _buildBulletListCard(
            'SUGGESTED IMPROVEMENTS',
            report.recommendations.suggestedImprovements,
            Icons.trending_up,
            AppTheme.accentColor,
          ),
          const SizedBox(height: 24),
          _buildBulletListCard(
            'MONETIZATION OPTIONS',
            report.recommendations.monetizationStrategies,
            Icons.monetization_on_outlined,
            AppTheme.primaryColor,
          ),
          const SizedBox(height: 24),
          _buildBulletListCard(
            'RISKS TO CONSIDER',
            report.recommendations.risksToConsider,
            Icons.warning_amber_outlined,
            Colors.redAccent,
          ),

          const SizedBox(height: 24),

          // Suggested Roadmap Steps
          const Text(
            'PROPOSED roadmap STRATEGY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: AppTheme.glassBox(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: List.generate(
                report.recommendations.roadmapSteps.length,
                (index) {
                  final step = report.recommendations.roadmapSteps[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            step,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBulletListCard(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: AppTheme.glassBox(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.secondaryTextColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String urlString) async {
    if (urlString.isEmpty) return;
    var target = urlString.trim();
    if (!target.startsWith('http://') && !target.startsWith('https://')) {
      target = 'https://$target';
    }
    final uri = Uri.parse(target);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $target');
      }
    } catch (e) {
      debugPrint('Error launching URL $target: $e');
    }
  }

  Widget _buildReferencesTab(BuildContext context) {
    final links = report.referenceLinks;
    if (links.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link_off, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No Reference Links Available',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryTextColor),
              ),
              SizedBox(height: 8),
              Text(
                'No reference links were found for this business concept.',
                style: TextStyle(fontSize: 12, color: AppTheme.secondaryTextColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _launchURL(link.url),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.insert_link,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          link.title.isNotEmpty ? link.title : 'Market Reference',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          link.url,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryTextColor,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.open_in_new,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackTab(BuildContext context) {
    final loveItems = report.customerFeedback.whatCustomersLove;
    final hateItems = report.customerFeedback.whatCustomersHate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Sentiment Analysis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                ) ??
                const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTextColor,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Understand what customers love and hate about existing alternatives or the core problem space.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          _buildFeedbackCard(
            'What Customers Love',
            loveItems,
            AppTheme.strengthColor,
            Icons.favorite_rounded,
          ),
          const SizedBox(height: 20),
          _buildFeedbackCard(
            'What Customers Hate',
            hateItems,
            AppTheme.threatColor,
            Icons.thumb_down_alt_rounded,
          ),
          const SizedBox(height: 80), // bottom spacing for FAB
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(
    String title,
    List<String> items,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.glassBox().copyWith(
        color: color.withOpacity(0.02),
        border: Border.all(color: color.withOpacity(0.12), width: 1.5),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const Divider(color: AppTheme.dividerColor, height: 24),
          if (items.isEmpty)
            const Text(
              'No information provided.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.secondaryTextColor,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Column(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryTextColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _generateMvpPrompt() async {
    final apiKey = widget.repository.getApiKey();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text(AppConstants.emptyApiKeyWarning),
            ],
          ),
          backgroundColor: AppTheme.threatColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingPrompt = true;
    });

    try {
      final prompt = await widget.repository.generateMvpPrompt(_currentReport);
      
      // Update report with the generated prompt
      final updatedReport = ValidationReport(
        id: _currentReport.id,
        ideaText: _currentReport.ideaText,
        timestamp: _currentReport.timestamp,
        summary: _currentReport.summary,
        category: _currentReport.category,
        targetAudience: _currentReport.targetAudience,
        coreProblem: _currentReport.coreProblem,
        proposedSolution: _currentReport.proposedSolution,
        competitors: _currentReport.competitors,
        swot: _currentReport.swot,
        marketOpportunity: _currentReport.marketOpportunity,
        scores: _currentReport.scores,
        recommendations: _currentReport.recommendations,
        businessName: _currentReport.businessName,
        priority: _currentReport.priority,
        marketView: _currentReport.marketView,
        referenceLinks: _currentReport.referenceLinks,
        customerFeedback: _currentReport.customerFeedback,
        mvpDevPrompt: prompt,
      );

      setState(() {
        _currentReport = updatedReport;
        _isGeneratingPrompt = false;
      });

      // If it's a historical report (already saved), update it in SharedPreferences immediately
      if (!widget.isNewReport) {
        await widget.repository.saveReport(updatedReport);
      }
    } catch (e) {
      setState(() {
        _isGeneratingPrompt = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to generate prompt: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppTheme.threatColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Widget _buildPremiumFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.secondaryColor, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFFCBD5E1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMvpPromptTab(BuildContext context) {
    final devPrompt = report.mvpDevPrompt;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MVP Generator Prompt',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryTextColor,
                            fontWeight: FontWeight.bold,
                          ) ??
                          const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Copy this prompt into any AI Coding Assistant (e.g. Claude, Cursor, Antigravity) to build this MVP.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (devPrompt.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: devPrompt));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text(AppConstants.copyPromptSuccess),
                          ],
                        ),
                        backgroundColor: AppTheme.accentColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_all_rounded, color: Colors.white, size: 18),
                  label: const Text(
                    'Copy Prompt',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isGeneratingPrompt)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gemini is architecturalizing your MVP...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (devPrompt.isEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                padding: const EdgeInsets.all(28.0),
                decoration: AppTheme.glassBox().copyWith(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1F2937),
                      Color(0xFF1E1B4B), // Deep indigo
                    ],
                  ),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryColor.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        size: 48,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'PREMIUM MVP BLUEPRINT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unlock a production-ready system instructions blueprint configured to generate your MVP automatically using AI coding tools.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE2E8F0),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 20),
                    _buildPremiumFeatureRow(Icons.layers_rounded, 'Multi-component Stack (Backend, Web Frontend, Mobile App)'),
                    const SizedBox(height: 12),
                    _buildPremiumFeatureRow(Icons.folder_copy_rounded, 'Standardized Architecture & Directory Layout'),
                    const SizedBox(height: 12),
                    _buildPremiumFeatureRow(Icons.security_rounded, 'Hardened Secrets & Cryptographic API Protections'),
                    const SizedBox(height: 12),
                    _buildPremiumFeatureRow(Icons.playlist_add_check_circle_rounded, 'Customer Feedback-Driven Feature Checklist'),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppTheme.premiumGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _generateMvpPrompt,
                        icon: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'Generate Premium MVP Coding Prompt',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Prompt Terminal Display
            Container(
              width: double.infinity,
              decoration: AppTheme.glassBox().copyWith(
                color: AppTheme.darkSurfaceColor,
                border: Border.all(
                  color: AppTheme.secondaryColor.withOpacity(0.3), // Glow premium border when generated
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryColor.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Terminal window headers
                  Row(
                    children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3), width: 0.5),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'mvp_prompt.md',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24, thickness: 1),
                  const SizedBox(height: 8),
                  SelectableText(
                    devPrompt,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 13,
                      color: Color(0xFFE2E8F0),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 80), // spacing for FAB
        ],
      ),
    );
  }
}
