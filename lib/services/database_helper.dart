import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pantry_pal.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        email TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pantry_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        quantity INTEGER,
        nutritionalInfo TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE recipes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        imageUrl TEXT,
        ingredients TEXT,
        instructions TEXT,
        nutritionalInfo TEXT,
        isFavorite INTEGER
      )
    ''');
  }

  // User methods
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Pantry item methods
  Future<int> insertPantryItem(PantryItem item) async {
    Database db = await database;
    return await db.insert('pantry_items', item.toMap());
  }

  Future<List<PantryItem>> getPantryItems() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('pantry_items');
    return List.generate(maps.length, (i) {
      return PantryItem.fromMap(maps[i]);
    });
  }

  Future<int> updatePantryItem(PantryItem item) async {
    Database db = await database;
    return await db.update(
      'pantry_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deletePantryItem(int id) async {
    Database db = await database;
    return await db.delete(
      'pantry_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Recipe methods
  Future<int> insertRecipe(Recipe recipe) async {
    Database db = await database;
    return await db.insert('recipes', recipe.toMap());
  }

  Future<List<Recipe>> getRecipes() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('recipes');
    return List.generate(maps.length, (i) {
      return Recipe.fromMap(maps[i]);
    });
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return Recipe.fromMap(maps[i]);
    });
  }

  Future<int> updateRecipe(Recipe recipe) async {
    Database db = await database;
    return await db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    Database db = await database;
    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
