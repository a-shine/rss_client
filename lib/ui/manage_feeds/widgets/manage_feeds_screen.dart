import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/manage_feeds_view_model.dart';
import 'add_feed_dialog.dart';

class ManageFeedsScreen extends StatefulWidget {
  const ManageFeedsScreen({super.key});

  @override
  State<ManageFeedsScreen> createState() => _ManageFeedsScreenState();
}

class _ManageFeedsScreenState extends State<ManageFeedsScreen> {
  @override
  void initState() {
    super.initState();
    // Load feed URLs when screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageFeedsViewModel>().loadFeedUrls();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Feeds'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ManageFeedsViewModel>(
        builder: (context, viewModel, child) {
          final feedUrls = viewModel.feedUrls;

          if (feedUrls.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rss_feed, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No feeds configured',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first feed',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: feedUrls.length,
            itemBuilder: (context, index) {
              final feedUrl = feedUrls[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.rss_feed),
                  title: Text(feedUrl.name),
                  subtitle: Text(
                    feedUrl.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Remove Feed'),
                          content: Text(
                            'Are you sure you want to remove "${feedUrl.name}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await context
                            .read<ManageFeedsViewModel>()
                            .removeFeedUrl(feedUrl.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<Map<String, String>>(
            context: context,
            builder: (context) => const AddFeedDialog(),
          );

          if (result != null && context.mounted) {
            final success = await context
                .read<ManageFeedsViewModel>()
                .addFeedUrl(result['url']!, result['name']!);

            if (context.mounted) {
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feed added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                final error = context.read<ManageFeedsViewModel>().error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Failed to add feed'),
                    backgroundColor: Colors.red,
                  ),
                );
                context.read<ManageFeedsViewModel>().clearError();
              }
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
