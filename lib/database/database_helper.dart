import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../modal/post_info.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DB helper
  static Database _database;

  String postTable = 'post_table';
  //
  String colId = 'id';
  String colTitle = 'title';
  String colContent = 'content';
  String colAuthor = 'author';
  String colDate = 'date';
  String colImgUrl = 'thumbnailInfo';
  String colSlug = 'slug';
  String colType = 'type';
  String colLink = 'link';
  String colStatus = 'status';
  String colExcerpt = 'excerpt';
  String colCategory = 'categories';
  String colIntDate = 'intDate';
  String colBookmarked = 'bookmark';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initDatabase();
    }
    return _database;
  }

  Future<Database> initDatabase() async {
    //Get the dir
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'posts.db';

    //Open or Create the database using given path
    var postsDataBase = openDatabase(path, version: 1, onCreate: _createDb);
    return postsDataBase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $postTable($colId INTEGER PRIMARY KEY, $colCategory TEXT, $colTitle TEXT,$colStatus TEXT, $colType TEXT, $colContent TEXT, $colAuthor TEXT, $colSlug TEXT, $colExcerpt TEXT, $colDate TEXT, $colLink TEXT, $colBookmarked TEXT, $colIntDate TEXT, $colImgUrl TEXT )');
  }

  //Fetch : Get all Posts from DB
  Future<List<Map<String, dynamic>>> getPostMapList(bool isBookmark) async {
    Database db = await this.database;
    if (isBookmark) {
      return await db.rawQuery(
          'SELECT * FROM $postTable WHERE $colBookmarked = "true" ORDER BY $colDate DESC');
    } else {
      return await db
          .rawQuery('SELECT * FROM $postTable ORDER BY $colDate DESC');
    }
  }

  //Fetch : Get all Posts from DB
  Future<List<Map<String, dynamic>>> getPostMapListWithCategory(
      String categoryId) async {
    Database db = await this.database;
    return await db.rawQuery(
        'SELECT * FROM $postTable WHERE $colCategory = $categoryId ORDER BY $colDate DESC');
  }

  //Insert: Insert a Post Obj to database
  Future<int> insertPost(PostInfo post) async {
    Database db = await this.database;
    var result = await db.insert(postTable, post.toMap()); //Convert ti map
    return result;
  }

  // Update : Update Post Obj and Save it yo DB
  Future<int> updatePost(PostInfo post) async {
    Database db = await this.database;
    var result = await db.update(postTable, post.toMap(),
        where: '$colId = ?',
        whereArgs: [post.id]); //Convert ti map then uodate where id  /?
    return result;
  }

  //Delete: Delete a Post Obj from DB
  Future<int> deletePost(int id) async {
    Database db = await this.database;
    var result = await db.rawDelete(
        'DELETE FROM $postTable WHERE $colId = $id '); //Convert ti map then uodate where id  /?
    return result;
  }

  //delete DB : Delete entire DB
  Future<int> deleteDB() async {
    print('database has been deleted');
    Database db = await this.database;
    db.rawQuery('DELETE FROM $postTable');
    return 1;
  }

  //Get number of Posts in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $postTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<PostInfo>> getPostList(String categoryId, bool isBookmark) async {
    List<Map> postMaps;
    if (categoryId == '' || isBookmark) {
      postMaps = await getPostMapList(isBookmark);
    } else {
      postMaps = await getPostMapListWithCategory(categoryId);
    }
    int count = postMaps.length;

    List<PostInfo> postsList = List<PostInfo>();

    for (int i = 0; i < count; i++) {
      postsList.add(PostInfo.fromMapObject(postMaps[i]));
    }
    return postsList; //from here Code has been cloned to Projects
  }
}