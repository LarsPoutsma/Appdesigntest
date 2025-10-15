import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/source.dart';
import 'session_provider.dart';

class SourceProvider extends ChangeNotifier {
  SourceProvider(this._session) {
    _session.addListener(_handleSessionChange);
    if (!_session.isLoading) {
      _handleSessionChange();
    }
  }

  final SessionProvider _session;
  final _uuid = const Uuid();
  StreamSubscription<List<SourceConnection>>? _subscription;
  List<SourceConnection> sources = [];

  Future<void> _handleSessionChange() async {
    final container = _session.container;
    if (container == null) {
      return;
    }
    await _subscription?.cancel();
    _subscription = container.sourceRepository.watchSources().listen((event) {
      sources = event;
      notifyListeners();
    });
  }

  Future<void> addSource(SourceKind kind, String label, Map<String, dynamic> metadata) async {
    final container = _session.container;
    if (container == null) {
      return;
    }
    final source = SourceConnection(
      id: _uuid.v4(),
      userId: container.userId,
      kind: kind,
      label: label,
      metadata: metadata,
      status: 'connected',
      lastSyncedAt: DateTime.now().toUtc(),
    );
    await container.sourceRepository.upsertSource(source);
  }

  Future<void> removeSource(String id) async {
    await _session.container?.sourceRepository.deleteSource(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _session.removeListener(_handleSessionChange);
    super.dispose();
  }
}
