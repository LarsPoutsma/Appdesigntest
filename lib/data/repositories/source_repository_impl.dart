import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/source.dart';
import '../../domain/repositories/source_repository.dart';
import '../datasources/local/source_local_data_source.dart';
import '../datasources/remote/source_remote_data_source.dart';
import '../models/source_model.dart';

class SourceRepositoryImpl implements SourceRepository {
  SourceRepositoryImpl({
    required SourceLocalDataSource localDataSource,
    required SourceRemoteDataSource remoteDataSource,
    required String userId,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _userId = userId;

  final SourceLocalDataSource _localDataSource;
  final SourceRemoteDataSource _remoteDataSource;
  final String _userId;
  final _logger = Logger('SourceRepository');
  final _uuid = const Uuid();

  @override
  Stream<List<SourceConnection>> watchSources() => _localDataSource.watchSources();

  @override
  Future<List<SourceConnection>> fetchSources() => _localDataSource.fetchSources();

  @override
  Future<void> upsertSource(SourceConnection source) async {
    final model = SourceModel(
      id: source.id.isEmpty ? _uuid.v4() : source.id,
      userId: source.userId.isEmpty ? _userId : source.userId,
      kind: source.kind,
      label: source.label,
      metadata: source.metadata,
      status: source.status,
      lastSyncedAt: DateTime.now().toUtc(),
    );
    await _localDataSource.upsertSource(model);
  }

  @override
  Future<void> deleteSource(String id) => _localDataSource.deleteSource(id);

  @override
  Future<void> sync() async {
    try {
      final remote = await _remoteDataSource.fetchSources(_userId);
      for (final source in remote) {
        await _localDataSource.upsertSource(source);
      }
    } catch (error, stackTrace) {
      _logger.warning('Failed to sync sources', error, stackTrace);
    }
  }
}
