import '../../data/models/validation_report.dart';
import '../../data/repositories/idea_repository.dart';

class SaveReportUseCase {
  final IdeaRepository repository;

  SaveReportUseCase(this.repository);

  Future<void> call(ValidationReport report) {
    return repository.saveReport(report);
  }
}
