import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/validation_report.dart';
import '../../domain/usecases/validate_idea_usecase.dart';

// --- Events ---
abstract class ValidationEvent {}

class ValidateIdeaEvent extends ValidationEvent {
  final String ideaText;
  ValidateIdeaEvent(this.ideaText);
}

class ResetValidationEvent extends ValidationEvent {}

// --- States ---
abstract class ValidationState {}

class ValidationInitial extends ValidationState {}

class ValidationInProgress extends ValidationState {
  final String statusMessage;
  final double progressPercent;

  ValidationInProgress({
    required this.statusMessage,
    required this.progressPercent,
  });
}

class ValidationSuccess extends ValidationState {
  final ValidationReport report;
  ValidationSuccess(this.report);
}

class ValidationFailure extends ValidationState {
  final String errorMessage;
  ValidationFailure(this.errorMessage);
}

// --- Bloc ---
class ValidationBloc extends Bloc<ValidationEvent, ValidationState> {
  final ValidateIdeaUseCase _validateIdeaUseCase;

  ValidationBloc({
    required ValidateIdeaUseCase validateIdeaUseCase,
  })  : _validateIdeaUseCase = validateIdeaUseCase,
        super(ValidationInitial()) {
    on<ResetValidationEvent>((event, emit) => emit(ValidationInitial()));

    on<ValidateIdeaEvent>((event, emit) async {
      emit(ValidationInProgress(
        statusMessage: 'Deconstructing idea & target market...',
        progressPercent: 0.1,
      ));

      // Introduce visual delays to simulate progress and show steps in UI
      await Future.delayed(const Duration(milliseconds: 700));
      emit(ValidationInProgress(
        statusMessage: 'Searching market for competitors & open source tools...',
        progressPercent: 0.35,
      ));

      await Future.delayed(const Duration(milliseconds: 700));
      emit(ValidationInProgress(
        statusMessage: 'Analyzing competitor pricing and founder teams...',
        progressPercent: 0.55,
      ));

      await Future.delayed(const Duration(milliseconds: 700));
      emit(ValidationInProgress(
        statusMessage: 'Formulating SWOT matrix & calculating validation scores...',
        progressPercent: 0.75,
      ));

      await Future.delayed(const Duration(milliseconds: 600));
      emit(ValidationInProgress(
        statusMessage: 'Generating actionable strategic recommendations...',
        progressPercent: 0.90,
      ));

      try {
        final report = await _validateIdeaUseCase(event.ideaText);
        emit(ValidationSuccess(report));
      } catch (e) {
        emit(ValidationFailure(
          'Failed to validate idea. Please verify your Gemini API key is valid in the Settings or try again later. Details: ${e.toString()}',
        ));
      }
    });
  }
}
