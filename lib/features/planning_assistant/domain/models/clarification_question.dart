enum ClarificationType {
  goalScope,
  goalHorizon,
  duration,
  schedulePreference,
  intensity,
  preferredDays,
}

class ClarificationQuestion {
  const ClarificationQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.required,
    this.options,
  });

  final String id;
  final String question;
  final ClarificationType type;
  final List<String>? options;
  final bool required;
}

class ClarificationAnswer {
  const ClarificationAnswer({required this.questionId, required this.value});

  final String questionId;
  final String value;
}
