import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/validation_report.dart';
import '../../domain/usecases/delete_report_usecase.dart';
import '../../domain/usecases/get_reports_usecase.dart';
import '../../domain/usecases/save_report_usecase.dart';

// --- Events ---
abstract class HistoryEvent {}

class LoadHistory extends HistoryEvent {}

class DeleteReport extends HistoryEvent {
  final String id;
  DeleteReport(this.id);
}

class SaveReport extends HistoryEvent {
  final ValidationReport report;
  SaveReport(this.report);
}

// --- States ---
abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<ValidationReport> reports;
  HistoryLoaded(this.reports);
}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}

// --- Bloc ---
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetReportsUseCase _getReportsUseCase;
  final DeleteReportUseCase _deleteReportUseCase;
  final SaveReportUseCase _saveReportUseCase;

  HistoryBloc({
    required GetReportsUseCase getReportsUseCase,
    required DeleteReportUseCase deleteReportUseCase,
    required SaveReportUseCase saveReportUseCase,
  })  : _getReportsUseCase = getReportsUseCase,
        _deleteReportUseCase = deleteReportUseCase,
        _saveReportUseCase = saveReportUseCase,
        super(HistoryInitial()) {
    on<LoadHistory>((event, emit) {
      emit(HistoryLoading());
      try {
        final reports = _getReportsUseCase();
        emit(HistoryLoaded(reports));
      } catch (e) {
        emit(HistoryError('Failed to load validation history: ${e.toString()}'));
      }
    });

    on<DeleteReport>((event, emit) async {
      try {
        await _deleteReportUseCase(event.id);
        final reports = _getReportsUseCase();
        emit(HistoryLoaded(reports));
      } catch (e) {
        emit(HistoryError('Failed to delete report: ${e.toString()}'));
      }
    });

    on<SaveReport>((event, emit) async {
      try {
        await _saveReportUseCase(event.report);
        final reports = _getReportsUseCase();
        emit(HistoryLoaded(reports));
      } catch (e) {
        emit(HistoryError('Failed to save report: ${e.toString()}'));
      }
    });
  }
}

