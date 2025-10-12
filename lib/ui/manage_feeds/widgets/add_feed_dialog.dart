import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../view_models/manage_feeds_view_model.dart';

class AddFeedDialog extends StatefulWidget {
  const AddFeedDialog({super.key, required this.viewModel});

  final ManageFeedsViewModel viewModel;

  @override
  State<AddFeedDialog> createState() => _AddFeedDialogState();
}

class _AddFeedDialogState extends State<AddFeedDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addFeed.addListener(_onAddFeed);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _onAddFeed() {
    if (widget.viewModel.addFeed.completed) {
      // Close the dialog on successful addition
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel.addFeed,
      builder: (context, _) {
        return AlertDialog(
          title: const Text('Add RSS Feed'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Feed Name',
                    hintText: 'e.g., Apple News',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a feed name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Feed URL',
                    hintText: 'https://example.com/feed.rss',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a feed URL';
                    }

                    // Basic URL validation
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null ||
                        !uri.hasScheme ||
                        (!uri.scheme.startsWith('http'))) {
                      return 'Please enter a valid URL';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Common feeds:\n'
                  '• Apple: developer.apple.com/news/rss/news.rss\n'
                  '• TechCrunch: feeds.feedburner.com/TechCrunch',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                // Show error message if any
                if (widget.viewModel.addFeed.error) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Failed to add feed. Please try again.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: widget.viewModel.addFeed.running
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        final name = _nameController.text.trim();
                        final url = _urlController.text.trim();
                        widget.viewModel.addFeed.execute(
                          AddFeedForm(name: name, url: url),
                        );
                      }
                    },
              child: widget.viewModel.addFeed.running
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Feed'),
            ),
          ],
        );
      },
    );
  }
}
