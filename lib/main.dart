import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/feed_url_repository/feed_url_repository.dart';
import 'data/repositories/feed_url_repository/feed_url_repository_impl.dart';
import 'data/repositories/rss_feed_repository/rss_feed_repository.dart';
import 'data/repositories/rss_feed_repository/rss_feed_repository_impl.dart';
import 'data/services/feed_url_local_storage_service/feed_url_local_storage_service.dart';
import 'data/services/rss_feed_http_service/rss_feed_http_service.dart';
import 'ui/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // Service layer (data sources)
        Provider<RssFeedHttpService>(
          create: (_) => RssFeedHttpService(client: http.Client()),
        ),
        Provider<FeedUrlLocalStorageService>(
          create: (_) => FeedUrlLocalStorageService(prefs),
        ),

        // Repository layer (maps service models to domain models)
        ProxyProvider<FeedUrlLocalStorageService, FeedUrlRepository>(
          update: (_, feedUrlService, __) =>
              FeedUrlRepositoryImpl(feedUrlService),
        ),
        ProxyProvider2<
          RssFeedHttpService,
          FeedUrlLocalStorageService,
          RssFeedRepository
        >(
          update: (_, rssFeedService, feedUrlService, __) =>
              RssFeedRepositoryImpl(rssFeedService, feedUrlService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
