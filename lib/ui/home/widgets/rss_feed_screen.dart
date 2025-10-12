import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/article.dart';
import '../../../router/routes.dart';
import '../../../utils/result.dart';
import '../view_models/home_feed_view_model.dart';

class RssFeedScreen extends StatefulWidget {
  const RssFeedScreen({super.key});

  @override
  State<RssFeedScreen> createState() => _RssFeedScreenState();
}

class _RssFeedScreenState extends State<RssFeedScreen> {
  late final _viewModel = context.read<HomeFeedViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.parseArticle.addListener(_onParseArticle);
  }

  @override
  void dispose() {
    _viewModel.parseArticle.removeListener(_onParseArticle);
    super.dispose();
  }

  void _onParseArticle() {
    if (_viewModel.parseArticle.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to parse the article'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    if (_viewModel.parseArticle.completed) {
      // Pop the loading dialog
      context.pop();
      // Navigate to reader screen
      final article = (_viewModel.parseArticle.result as Ok<Article>?)?.value;
      if (article != null) {
        context.go(Routes.reader, extra: article);
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open article: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openInReaderMode(String url) {
    if (!mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading article...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Start parsing the article
    _viewModel.parseArticle.execute(url);
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
            onPressed: () => context.go(Routes.manageFeeds),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _viewModel.load.execute(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel.load,
        builder: (context, _) {
          if (_viewModel.load.running) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.load.error) {
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
                      "Unknown error occurred while fetching feeds. Please check your internet connection and try again.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _viewModel.load.execute(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // if (!viewModel.hasFeedUrls) {
          //   return Center(
          //     child: Padding(
          //       padding: const EdgeInsets.all(32.0),
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(Icons.rss_feed, size: 64, color: Colors.grey[400]),
          //           const SizedBox(height: 16),
          //           Text(
          //             'No feeds configured',
          //             style: Theme.of(context).textTheme.titleLarge,
          //           ),
          //           const SizedBox(height: 8),
          //           Text(
          //             'Add your first RSS feed to get started',
          //             textAlign: TextAlign.center,
          //             style: Theme.of(context).textTheme.bodyMedium,
          //           ),
          //           const SizedBox(height: 24),
          //           ElevatedButton.icon(
          //             onPressed: () {
          //               context.go(Routes.manageFeeds);
          //             },
          //             icon: const Icon(Icons.add),
          //             label: const Text('Add Feed'),
          //           ),
          //         ],
          //       ),
          //     ),
          //   );
          // }

          if (!_viewModel.hasFeeds) {
            return const Center(child: Text('No feed items available'));
          }

          // Combine all items from all feeds
          final allItems = _viewModel.feeds
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
            onRefresh: () => _viewModel.load.execute(),
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
                  child: Column(
                    children: [
                      ListTile(
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
                      ),
                      // Action buttons
                      if (item.link != null) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _openInReaderMode(item.link!),
                                icon: const Icon(Icons.article, size: 18),
                                label: const Text('Reader'),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () => _launchUrl(item.link!),
                                icon: const Icon(
                                  Icons.open_in_browser,
                                  size: 18,
                                ),
                                label: const Text('Browser'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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
