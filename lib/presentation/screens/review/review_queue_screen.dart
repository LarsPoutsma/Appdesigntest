import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/review_provider.dart';

class ReviewQueueScreen extends StatelessWidget {
  const ReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Review Queue')),
      body: reviewProvider.items.isEmpty
          ? const Center(child: Text('No conflicts detected. You are up to date!'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = reviewProvider.items[index];
                return Card(
                  child: ListTile(
                    title: Text(item.assignment.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Due ${item.assignment.dueAt.toLocal()}'),
                        if (item.conflict != null)
                          Text('Conflict: ${item.conflict!.dueAt.toLocal()}',
                              style: const TextStyle(color: Colors.orange)),
                      ],
                    ),
                    trailing: FilledButton(
                      onPressed: () async {
                        await reviewProvider.approveAll();
                      },
                      child: const Text('Approve'),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: reviewProvider.items.length,
            ),
    );
  }
}
