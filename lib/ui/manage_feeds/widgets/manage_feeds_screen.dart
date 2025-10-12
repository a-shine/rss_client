import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/manage_feeds_view_model.dart';
import 'add_feed_dialog.dart';

class ManageFeedsScreen extends StatefulWidget {
  const ManageFeedsScreen({super.key});

  @override
  State<ManageFeedsScreen> createState() => _ManageFeedsScreenState();
}

class _ManageFeedsScreenState extends State<ManageFeedsScreen> {
  late final _viewModel = context.read<ManageFeedsViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Feeds'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: _viewModel.load,
        builder: (context, _) {
          final feedUrls = _viewModel.feedUrls;

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
                    onPressed: () => showDialog<bool>(
                      context: context,
                      builder: (context) => ListenableBuilder(
                        listenable: _viewModel.removeFeed,
                        builder: (context, _) {
                          return AlertDialog(
                            title: const Text('Remove Feed'),
                            content: Text(
                              'Are you sure you want to remove "${feedUrl.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: _viewModel.removeFeed.running
                                    ? null
                                    : () async {
                                        // Execute removal
                                        await _viewModel.removeFeed.execute(
                                          feedUrl.id,
                                        );
                                        if (context.mounted) {
                                          context.pop();
                                        }
                                      },
                                child: _viewModel.removeFeed.running
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Remove'),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<Map<String, String>>(
          context: context,
          builder: (context) => AddFeedDialog(viewModel: _viewModel),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
