import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../data/repositories/idea_repository.dart';
import '../../bloc/validation_bloc.dart';
import '../../theme/app_theme.dart';
import '../report/report_detail_screen.dart';

class AnalysisLoadingScreen extends StatefulWidget {
  final String ideaText;
  final IdeaRepository repository;

  const AnalysisLoadingScreen({
    super.key,
    required this.ideaText,
    required this.repository,
  });

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch validation request when mounted
    context.read<ValidationBloc>().add(ValidateIdeaEvent(widget.ideaText));
  }

  Widget _buildCheckItem(String label, bool isCompleted, bool isActive) {
    Color textColor = Colors.grey;
    if (isCompleted) {
      textColor = AppTheme.accentColor;
    } else if (isActive) {
      textColor = AppTheme.primaryTextColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted 
                  ? AppTheme.accentColor.withOpacity(0.1) 
                  : Colors.transparent,
              border: Border.all(
                color: isCompleted 
                    ? AppTheme.accentColor 
                    : isActive 
                        ? AppTheme.primaryColor 
                        : Colors.black.withOpacity(0.12),
                width: 1.5,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: AppTheme.accentColor)
                : isActive
                    ? const Center(
                        child: SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                          ),
                        ),
                      )
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: BlocConsumer<ValidationBloc, ValidationState>(
              listener: (context, state) {
                if (state is ValidationSuccess) {
                  // Navigate to report details and replace the loading screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportDetailScreen(
                        report: state.report,
                        repository: widget.repository,
                        isNewReport: true,
                      ),
                    ),
                  ).then((_) {
                    // Once popped, notify entry screen to return true
                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  });
                }
              },
              builder: (context, state) {
                if (state is ValidationFailure) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Validation Failed',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: AppTheme.glassBox(borderColor: Colors.redAccent.withOpacity(0.2)),
                            child: Text(
                              state.errorMessage,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.secondaryTextColor,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.black.withOpacity(0.12)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: const Text('Back to Input', style: TextStyle(color: AppTheme.primaryTextColor)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<ValidationBloc>().add(ValidateIdeaEvent(widget.ideaText));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: const Text('Retry Analysis', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }

                String activeMessage = 'Initiating idea analysis...';
                double progress = 0.0;

                if (state is ValidationInProgress) {
                  activeMessage = state.statusMessage;
                  progress = state.progressPercent;
                }

                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Loading Anim
                      const SpinKitSpinningLines(
                        color: AppTheme.primaryColor,
                        size: 80.0,
                      ),
                      const SizedBox(height: 40),

                      Text(
                        'Analyzing Your Startup Idea',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        activeMessage,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.secondaryTextColor,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Progress Bar
                      Container(
                        width: double.infinity,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: MediaQuery.of(context).size.width * 0.8 * progress,
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Checklist items
                      Container(
                        decoration: AppTheme.glassBox(),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            _buildCheckItem(
                              'Deconstruct Idea & Market Segment',
                              progress > 0.1,
                              (progress >= 0.1 && progress < 0.35),
                            ),
                            _buildCheckItem(
                              'Audit Market for Direct Competitors',
                              progress > 0.35,
                              (progress >= 0.35 && progress < 0.55),
                            ),
                            _buildCheckItem(
                              'Analyze Founder & Pricing Models',
                              progress > 0.55,
                              (progress >= 0.55 && progress < 0.75),
                            ),
                            _buildCheckItem(
                              'Formulate SWOT Matrix & Validation Scores',
                              progress > 0.75,
                              (progress >= 0.75 && progress < 0.90),
                            ),
                            _buildCheckItem(
                              'Generate Strategic Actions & Recommendations',
                              progress > 0.90,
                              (progress >= 0.90 && progress < 1.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
