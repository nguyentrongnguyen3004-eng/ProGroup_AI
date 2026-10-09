import '../models/ai_feedback_model.dart';

class AiFeedbackService {
  final List<AiFeedbackModel> _feedback = [];

  List<AiFeedbackModel> get submittedFeedback =>
      List.unmodifiable(_feedback);

  Future<void> submit(AiFeedbackModel feedback) async {
    _feedback.add(feedback);
  }
}