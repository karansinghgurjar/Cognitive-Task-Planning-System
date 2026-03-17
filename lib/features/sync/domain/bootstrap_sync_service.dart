import 'sync_models.dart';

class BootstrapSyncService {
  const BootstrapSyncService();

  BootstrapPlan evaluate({
    required int localEntityCount,
    required int remoteEntityCount,
    required bool hasPreviousSync,
  }) {
    if (hasPreviousSync) {
      return BootstrapPlan(
        requirement: BootstrapRequirement.none,
        localEntityCount: localEntityCount,
        remoteEntityCount: remoteEntityCount,
      );
    }
    if (localEntityCount == 0 && remoteEntityCount == 0) {
      return const BootstrapPlan(
        requirement: BootstrapRequirement.none,
        localEntityCount: 0,
        remoteEntityCount: 0,
        message: 'No local or remote data to bootstrap.',
      );
    }
    if (localEntityCount > 0 && remoteEntityCount == 0) {
      return BootstrapPlan(
        requirement: BootstrapRequirement.uploadLocal,
        localEntityCount: localEntityCount,
        remoteEntityCount: remoteEntityCount,
        message: 'Remote storage is empty. Local data can be uploaded safely.',
      );
    }
    if (localEntityCount == 0 && remoteEntityCount > 0) {
      return BootstrapPlan(
        requirement: BootstrapRequirement.downloadRemote,
        localEntityCount: localEntityCount,
        remoteEntityCount: remoteEntityCount,
        message: 'This device is empty. Remote data can be downloaded safely.',
      );
    }
    return BootstrapPlan(
      requirement: BootstrapRequirement.choose,
      localEntityCount: localEntityCount,
      remoteEntityCount: remoteEntityCount,
      message:
          'Both local and remote data exist for this account. Choose how to bootstrap before syncing.',
    );
  }
}

