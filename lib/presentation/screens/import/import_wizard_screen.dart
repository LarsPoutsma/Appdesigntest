import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/source.dart';
import '../../providers/course_provider.dart';
import '../../providers/import_provider.dart';
import '../../providers/source_provider.dart';

class ImportWizardScreen extends StatefulWidget {
  const ImportWizardScreen({super.key});

  @override
  State<ImportWizardScreen> createState() => _ImportWizardScreenState();
}

class _ImportWizardScreenState extends State<ImportWizardScreen> {
  final _formKey = GlobalKey<FormState>();
  SourceKind _kind = SourceKind.ics;
  final _labelController = TextEditingController();
  final _payloadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final importProvider = context.watch<ImportProvider>();
    final sourceProvider = context.watch<SourceProvider>();
    final courseProvider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Import Wizard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connect a source or paste file contents to import assignments.',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<SourceKind>(
                    value: _kind,
                    decoration: const InputDecoration(labelText: 'Source type'),
                    items: const [
                      DropdownMenuItem(value: SourceKind.ics, child: Text('ICS Calendar')), 
                      DropdownMenuItem(value: SourceKind.csv, child: Text('CSV Export')),
                      DropdownMenuItem(value: SourceKind.html, child: Text('HTML Page')), 
                    ],
                    onChanged: (value) => setState(() => _kind = value ?? SourceKind.ics),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _labelController,
                    decoration: const InputDecoration(labelText: 'Source label (e.g., Canvas ICS)'),
                    validator: (value) => value == null || value.isEmpty ? 'Label required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _payloadController,
                    decoration: InputDecoration(
                      labelText: _kind == SourceKind.html ? 'HTML content or link' : 'File contents or URL',
                    ),
                    maxLines: 6,
                    validator: (value) => value == null || value.isEmpty ? 'Provide content or link' : null,
                  ),
                  if (_kind == SourceKind.csv)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Column mapping', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...importProvider.csvMapping.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextFormField(
                                initialValue: entry.value,
                                decoration: InputDecoration(
                                  labelText: '${entry.key} column',
                                ),
                                onChanged: (value) => importProvider.csvMapping[entry.key] = value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('Preview'),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      final metadata = {
                        'connection': _payloadController.text.trim(),
                        if (_kind == SourceKind.csv) 'mapping': importProvider.csvMapping,
                      };
                      await sourceProvider.addSource(_kind, _labelController.text.trim(), metadata);
                      final source = sourceProvider.sources.last;
                      switch (_kind) {
                        case SourceKind.ics:
                          await importProvider.loadIcs(_payloadController.text.trim(), source);
                          break;
                        case SourceKind.csv:
                          await importProvider.loadCsv(_payloadController.text.trim(), source, importProvider.csvMapping);
                          break;
                        case SourceKind.html:
                          await importProvider.loadHtml(_payloadController.text.trim(), source);
                          break;
                        default:
                          break;
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (importProvider.isProcessing) const LinearProgressIndicator(),
            if (importProvider.pending.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preview ${importProvider.pending.length} assignments before committing:'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: importProvider.pending.length,
                      itemBuilder: (context, index) {
                        final item = importProvider.pending[index];
                        return ListTile(
                          title: Text(item.title),
                          subtitle: Text('${item.dueAt.toLocal()} • ${item.courseName ?? 'General'}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (courseProvider.courses.isEmpty)
                    const Text('Create a course before importing assignments.',
                        style: TextStyle(color: Colors.orange))
                  else
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: importProvider.course?.id ?? courseProvider.courses.first.id,
                            decoration: const InputDecoration(labelText: 'Import into course'),
                            items: [
                              for (final course in courseProvider.courses)
                                DropdownMenuItem(value: course.id, child: Text(course.name)),
                            ],
                            onChanged: (value) {
                              final selected = courseProvider.courses.firstWhere((c) => c.id == value);
                              importProvider.selectCourse(selected);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cloud_done),
                            label: const Text('Commit import'),
                            onPressed: () async {
                              await importProvider.commit();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Imported assignments to ${importProvider.course?.name ?? ''}')),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
