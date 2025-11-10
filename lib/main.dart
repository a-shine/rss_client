import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/repositories/article_repository/article_repository.dart';
import 'data/repositories/feed_url_repository/feed_url_repository.dart';
import 'data/repositories/feed_url_repository/feed_url_repository_impl.dart';
import 'data/repositories/rss_feed_repository/rss_feed_repository.dart';
import 'data/repositories/rss_feed_repository/rss_feed_repository_impl.dart';
import 'data/repositories/user_repository/user_repository.dart';
import 'data/repositories/user_repository/user_repository_impl.dart';
import 'data/services/article_reader_service/article_reader_service.dart';
import 'data/services/feed_url_local_storage_service/feed_url_local_storage_service.dart';
import 'data/services/local_sqllite_service/local_sqllite_service.dart';
import 'data/services/rss_feed_http_service/rss_feed_http_service.dart';
import 'data/services/supabase_auth_service/supabase_auth_service.dart';
import 'ui/app/app.dart';

const supabaseUrl = 'https://rkwdlmvitmapcbqzkcov.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJrd2RsbXZpdG1hcGNicXprY292Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4MDIzOTcsImV4cCI6MjA3ODM3ODM5N30.cXd2M-oc7OxyuynKOf5zOBtQILryOay3CHHVfsa3wec';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Only do this if not on web
  Database? db;
  if (!kIsWeb) {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        // await db.execute(
        //   'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)',
        // );
      },
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  final supabaseClient = Supabase.instance.client;

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
        Provider<ArticleReaderService>(create: (_) => ArticleReaderService()),
        Provider<LocalSqlliteService>(create: (_) => LocalSqlliteService(db)),
        Provider<SupabaseAuthService>(
          create: (_) => SupabaseAuthService(supabaseClient),
        ),

        // Repository layer (maps service models to domain models)
        Provider<FeedUrlRepository>(
          create: (context) =>
              FeedUrlRepositoryImpl(context.read<FeedUrlLocalStorageService>()),
        ),
        Provider<RssFeedRepository>(
          create: (context) => RssFeedRepositoryImpl(
            context.read<RssFeedHttpService>(),
            context.read<FeedUrlLocalStorageService>(),
          ),
        ),
        Provider<ArticleRepository>(
          create: (context) => ArticleRepository(
            articleParserService: context.read<ArticleReaderService>(),
          ),
        ),
        Provider<UserRepository>(
          create: (context) =>
              UserRepositoryImpl(context.read<SupabaseAuthService>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
