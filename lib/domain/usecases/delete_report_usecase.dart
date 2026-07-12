import '../../data/repositories/idea_repository.dart';

class DeleteReportUseCase {
  final IdeaRepository repository;

  DeleteReportUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteReport(id);
  }
}
