import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return openDatabase(
      path,
      version: 6, 
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT NOT NULL,
            password TEXT NOT NULL,
            age INTEGER,
            food_preferences TEXT,
            allergies TEXT,
            shop_preference TEXT,
            weight REAL,
            height REAL,
            workout_frequency TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 3) {
          db.execute('ALTER TABLE users ADD COLUMN age INTEGER');
          db.execute('ALTER TABLE users ADD COLUMN food_preferences TEXT');
          db.execute('ALTER TABLE users ADD COLUMN allergies TEXT');
          db.execute('ALTER TABLE users ADD COLUMN shop_preference TEXT');
        }
        if (oldVersion < 4) {
          db.execute('ALTER TABLE users ADD COLUMN weight REAL');
        }
        if (oldVersion < 5) {
          db.execute('ALTER TABLE users ADD COLUMN height REAL');
        }
        if (oldVersion < 6) {
          db.execute('ALTER TABLE users ADD COLUMN workout_frequency TEXT');
        }
      },
    );
  }

  Future<int> insertUser(String email, String password, String name, {int? age, List<String>? foodPreferences, List<String>? allergies, String? shopPreference, double? weight, double? height, String? workoutFrequency}) async {
    final db = await database;
    return db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'food_preferences': foodPreferences?.join(','),
      'allergies': allergies?.join(','),
      'shop_preference': shopPreference,
      'weight': weight,
      'height': height,
      'workout_frequency': workoutFrequency,
    });
  }

  Future<Map<String, dynamic>?> getUser(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    print('getUser query result: $result'); 
    return result.isNotEmpty ? result.first : null;
  }
}
