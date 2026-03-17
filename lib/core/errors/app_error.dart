class AppError {
  const AppError({
    required this.title,
    required this.message,
    this.actionLabel,
    this.details,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final String? details;
}
