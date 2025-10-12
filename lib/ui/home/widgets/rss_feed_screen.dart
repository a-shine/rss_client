import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../router/routes.dart';
import '../view_models/home_feed_view_model.dart';

class RssFeedScreen extends StatefulWidget {
  const RssFeedScreen({super.key});

  @override
  State<RssFeedScreen> createState() => _RssFeedScreenState();
}

class _RssFeedScreenState extends State<RssFeedScreen> {
  @override
  void initState() {
    super.initState();
    // Load feeds when screen is first created
    _loadFeeds();
  }

  void _loadFeeds() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeFeedViewModel>().loadAllFeeds();
      }
    });
  }

  @override
  void didUpdateWidget(RssFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh feeds when returning to this screen
    _loadFeeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSS Feed Reader'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go(Routes.manageFeeds);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HomeFeedViewModel>().refresh();
            },
          ),
        ],
      ),
      body: Consumer<HomeFeedViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading feeds',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!viewModel.hasFeedUrls) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
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
                      'Add your first RSS feed to get started',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go(Routes.manageFeeds);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Feed'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!viewModel.hasFeeds) {
            return const Center(child: Text('No feed items available'));
          }

          // Combine all items from all feeds
          final allItems = viewModel.feeds
              .expand(
                (feed) =>
                    feed.items.map((item) => {'feed': feed, 'item': item}),
              )
              .toList();

          // Sort by date (newest first)
          allItems.sort((a, b) {
            final dateA = (a['item'] as dynamic).pubDate as DateTime?;
            final dateB = (b['item'] as dynamic).pubDate as DateTime?;
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA);
          });

          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.loadAllFeeds();
            },
            child: ListView.builder(
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                final feedData = allItems[index]['feed'] as dynamic;
                final item = allItems[index]['item'] as dynamic;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Feed source badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            feedData.title,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            item.description!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (item.pubDate != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            DateFormat(
                              'MMM d, yyyy - h:mm a',
                            ).format(item.pubDate!),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: item.link != null
                        ? () {
                            // TODO: Open link in browser
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Link: ${item.link}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        : null,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
