import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/source.dart';
import '../../providers/source_provider.dart';

class SourceManagerScreen extends StatelessWidget {
  const SourceManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SourceProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Sources')),
      body: ListView.separated(
        itemCount: provider.sources.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final source = provider.sources[index];
          return ListTile(
            title: Text(source.label),
            subtitle: Text('${source.kind.name.toUpperCase()} • ${source.status}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.removeSource(source.id),
            ),
          );
        },
      ),
    );
  }
}
