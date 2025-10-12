import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/feed_url_repository/feed_url_repository.dart';
import '../data/repositories/rss_feed_repository/rss_feed_repository.dart';
import '../data/services/feed_url_local_storage_service/feed_url_local_storage_service.dart';
import '../ui/home/view_models/home_feed_view_model.dart';
import '../ui/home/widgets/rss_feed_screen.dart';
import '../ui/manage_feeds/view_models/manage_feeds_view_model.dart';
import '../ui/manage_feeds/widgets/manage_feeds_screen.dart';
import 'routes.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, _) => ChangeNotifierProvider(
          create: (_) => HomeFeedViewModel(
            context.read<RssFeedRepository>(),
            context.read<FeedUrlLocalStorageService>(),
          ),
          child: const RssFeedScreen(),
        ),
        routes: [
          GoRoute(
            path: Routes.manageFeedsRelative,
            builder: (context, _) => ChangeNotifierProvider(
              create: (_) =>
                  ManageFeedsViewModel(context.read<FeedUrlRepository>()),
              child: const ManageFeedsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
