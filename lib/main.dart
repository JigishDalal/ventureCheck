import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/idea_repository.dart';
import 'data/services/gemini_service.dart';
import 'data/services/storage_service.dart';
import 'domain/usecases/delete_report_usecase.dart';
import 'domain/usecases/get_reports_usecase.dart';
import 'domain/usecases/validate_idea_usecase.dart';
import 'domain/usecases/save_report_usecase.dart';
import 'ui/bloc/history_bloc.dart';
import 'ui/bloc/validation_bloc.dart';
import 'ui/features/dashboard/dashboard_screen.dart';
import 'ui/theme/app_theme.dart';
import 'ui/features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final storageService = await StorageService.init();
  final geminiService = GeminiService();

  // Initialize repository
  final repository = IdeaRepository(
    geminiService: geminiService,
    storageService: storageService,
  );

  runApp(MyApp(repository: repository));
}


class MyApp extends StatelessWidget {
  final IdeaRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    // Build Usecases
    final getReportsUseCase = GetReportsUseCase(repository);
    final deleteReportUseCase = DeleteReportUseCase(repository);
    final validateIdeaUseCase = ValidateIdeaUseCase(repository);
    final saveReportUseCase = SaveReportUseCase(repository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<HistoryBloc>(
          create: (_) => HistoryBloc(
            getReportsUseCase: getReportsUseCase,
            deleteReportUseCase: deleteReportUseCase,
            saveReportUseCase: saveReportUseCase,
          ),
        ),
        BlocProvider<ValidationBloc>(
          create: (_) => ValidationBloc(
            validateIdeaUseCase: validateIdeaUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'VentureCheck - AI Startup Validator',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(repository: repository),
      ),
    );
  }
}
