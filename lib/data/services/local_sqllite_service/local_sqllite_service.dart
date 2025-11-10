import 'package:sqflite/sqlite_api.dart';

class LocalSqlliteService {
  LocalSqlliteService(Database? db) : _db = db;
  final Database? _db;
}
