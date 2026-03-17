import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'isar_service.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final isarInstanceProvider = FutureProvider<Isar>((ref) {
  final service = ref.watch(isarServiceProvider);
  return service.openIsar();
});
