import '../../data/models/validation_report.dart';
import '../../data/repositories/idea_repository.dart';

class ValidateIdeaUseCase {
  final IdeaRepository repository;

  ValidateIdeaUseCase(this.repository);

  Future<ValidationReport> call(String ideaText) {
    return repository.validateIdea(ideaText);
  }
}
