import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/idea_repository.dart';
import '../../bloc/history_bloc.dart';
import '../../theme/app_theme.dart';
import '../idea_entry/idea_entry_screen.dart';
import '../report/report_detail_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final IdeaRepository repository;

  const DashboardScreen({super.key, required this.repository});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load history when screen mounts
    context.read<HistoryBloc>().add(LoadHistory());
  }

  void _navigateToSettings() async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(repository: widget.repository),
      ),
    );
    if (changed == true && mounted) {
      context.read<HistoryBloc>().add(LoadHistory());
    }
  }

  void _navigateToIdeaEntry() async {
    final validated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IdeaEntryScreen(repository: widget.repository),
      ),
    );
    if (validated == true && mounted) {
      context.read<HistoryBloc>().add(LoadHistory());
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.strengthColor;
    if (score >= 60) return AppTheme.weaknessColor;
    return AppTheme.threatColor;
  }

  @override
  Widget build(BuildContext context) {
    final isMock = widget.repository.isMockMode();
    final hasKey = widget.repository.getApiKey().isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.05),
                                width: 1,
                              ),
                            ),
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VentureCheck',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primaryTextColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'AI Startup Validation',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.secondaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _navigateToSettings,
                        icon: const Icon(
                          Icons.settings,
                          color: AppTheme.primaryTextColor,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // Mock Mode Warning Indicator
                if (isMock || !hasKey)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 4.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              !hasKey
                                  ? 'API Key is missing. Running in Mock Mode.'
                                  : 'Running in demonstration Mock Mode.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.amber,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _navigateToSettings,
                            child: const Text(
                              'Setup',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // History Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'VALIDATION HISTORY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // History List Container
                Expanded(
                  child: BlocBuilder<HistoryBloc, HistoryState>(
                    builder: (context, state) {
                      if (state is HistoryLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        );
                      } else if (state is HistoryError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else if (state is HistoryLoaded) {
                        final reports = state.reports;

                        if (reports.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.rocket_launch_outlined,
                                      size: 48,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'No Startup Validations',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Enter your business concept or record a voice idea to generate a comprehensive AI report.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.secondaryTextColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 8.0,
                          ),
                          itemCount: reports.length,
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            final dateStr = DateFormat(
                              'MMM dd, yyyy • hh:mm a',
                            ).format(report.timestamp);

                            return Dismissible(
                              key: Key(report.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20.0),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (direction) {
                                context.read<HistoryBloc>().add(
                                  DeleteReport(report.id),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '"${report.category}" report deleted',
                                    ),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        // Save back
                                        // To implement simple undo, we could emit save report event
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ReportDetailScreen(
                                            report: report,
                                            repository: widget.repository,
                                          ),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        // Colored Score Tag
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: _getScoreColor(
                                              report.scores.overallScore,
                                            ).withOpacity(0.1),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _getScoreColor(
                                                report.scores.overallScore,
                                              ).withOpacity(0.5),
                                              width: 1.5,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${report.scores.overallScore}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: _getScoreColor(
                                                report.scores.overallScore,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Catchy Business Name
                                              Text(
                                                report.businessName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color:
                                                      AppTheme.primaryTextColor,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              // Tags: Category, Market View summary, and Priority
                                              Wrap(
                                                spacing: 6,
                                                runSpacing: 4,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme
                                                          .primaryColor
                                                          .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      report.category,
                                                      style: const TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppTheme
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                  if (report
                                                          .marketView
                                                          .isNotEmpty &&
                                                      report.marketView !=
                                                          'N/A')
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.04),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                0.08,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        report.marketView,
                                                        style: const TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppTheme
                                                              .secondaryTextColor,
                                                        ),
                                                      ),
                                                    ),
                                                  // Priority Chip
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          (report.priority
                                                                          .toLowerCase() ==
                                                                      'high'
                                                                  ? AppTheme
                                                                        .strengthColor
                                                                  : report.priority
                                                                            .toLowerCase() ==
                                                                        'medium'
                                                                  ? AppTheme
                                                                        .weaknessColor
                                                                  : AppTheme
                                                                        .threatColor)
                                                              .withOpacity(
                                                                0.15,
                                                              ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            (report.priority
                                                                            .toLowerCase() ==
                                                                        'high'
                                                                    ? AppTheme
                                                                          .strengthColor
                                                                    : report.priority
                                                                              .toLowerCase() ==
                                                                          'medium'
                                                                    ? AppTheme
                                                                          .weaknessColor
                                                                    : AppTheme
                                                                          .threatColor)
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '${report.priority} Priority',
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            report.priority
                                                                    .toLowerCase() ==
                                                                'high'
                                                            ? AppTheme
                                                                  .strengthColor
                                                            : report.priority
                                                                      .toLowerCase() ==
                                                                  'medium'
                                                            ? AppTheme
                                                                  .weaknessColor
                                                            : AppTheme
                                                                  .threatColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              // Idea description (truncated)
                                              Text(
                                                report.ideaText,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme
                                                      .secondaryTextColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                dateStr,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey[500],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToIdeaEntry,
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: Ink(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: const Row(
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Validate Idea',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
