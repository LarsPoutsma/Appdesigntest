import '../entities/source.dart';

abstract class SourceRepository {
  Stream<List<SourceConnection>> watchSources();

  Future<List<SourceConnection>> fetchSources();

  Future<void> upsertSource(SourceConnection source);

  Future<void> deleteSource(String id);

  Future<void> sync();
}
