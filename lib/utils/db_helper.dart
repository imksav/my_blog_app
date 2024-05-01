import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:my_blog_app/models/blog.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'blogs.db');
    print('Database path: $path');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE blogs(id INTEGER PRIMARY KEY, title TEXT, description TEXT, author TEXT, date TEXT, tags TEXT, imagePath TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE blogs ADD COLUMN imagePath TEXT');
        }
      },
      version: 2,
    );
  }

  Future<int> insertBlog(Blog blog) async {
    final db = await instance.database;
    return await db.insert('blogs', blog.toMap());
  }

  Future<List<Blog>> getAllBlogs() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('blogs');
    return List.generate(maps.length, (i) {
      return Blog.fromMap(maps[i]);
    });
  }

  Future<int> updateBlog(Blog blog) async {
    final db = await instance.database;
    return await db.update(
      'blogs',
      blog.toMap(),
      where: 'id = ?',
      whereArgs: [blog.id],
    );
  }

  Future<int> deleteBlog(int id) async {
    final db = await instance.database;
    return await db.delete(
      'blogs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Blog>> searchBlogs(String query) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'blogs',
      where:
          'title LIKE ? OR description LIKE ? OR author LIKE ? OR tags LIKE ? OR date LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Blog.fromMap(maps[i]);
    });
  }
}
