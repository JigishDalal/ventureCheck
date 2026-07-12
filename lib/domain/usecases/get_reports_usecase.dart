import '../../data/models/validation_report.dart';
import '../../data/repositories/idea_repository.dart';

class GetReportsUseCase {
  final IdeaRepository repository;

  GetReportsUseCase(this.repository);

  List<ValidationReport> call() {
    return repository.getSavedReports();
  }
}
