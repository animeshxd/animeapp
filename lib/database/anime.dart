import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

class DataBaseHelper {
  DataBaseHelper._();
  static final instance = DataBaseHelper._();

  static sql.Database? _database;
  Future<sql.Database> get database async => _database ??= await _init();

  Future<sql.Database> _init() async {
    var documentdir = await getApplicationDocumentsDirectory();

    return sql.openDatabase(
      join(documentdir.path, 'anime.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE anime(
            id TEXT PRIMARY KEY,
            name TEXT,
            time DATETIME
          );
        ''');
      },
    );
  }

  Future<bool> isLiked(String id) async {
    var db = await instance.database;
    var query = await db.query('anime', where: "id = ?", whereArgs: [id]);
    // print(query);
    return query.isEmpty ? false : true;
  }

  Future<bool> remove(String id) async {
    var db = await instance.database;
    var query = await db.delete('anime', where: "id = ?", whereArgs: [id]);
    return query != 0 ? true : false;
  }

  Future<List<Anime>> likedList() async {
    var db = await instance.database;
    var list = await db.query('anime', orderBy: 'name');
    // print(list);
    List<Anime> animes =
        list.isEmpty ? [] : list.map((e) => Anime.fromMap(e)).toList();
    return animes;
  }

  Future<void> add(Anime anime) async {
    var db = await instance.database;
    await db.insert('anime', anime.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.ignore);
  }
}

class Anime {
  // ignore: non_constant_identifier_names
  final String id;
  // ignore: non_constant_identifier_names
  final String name;
  DateTime? time;
  Anime({required this.id, required this.name, DateTime? time}) {
    this.time = time?? DateTime.now();
  }

  factory Anime.fromMap(Map<String, dynamic> map,) {
    return Anime(id: map['id']!, name: map['name']!, time: DateTime.parse(map['time']));
  }
  Map<String, dynamic> toMap() {
    return {"id": id, "name": name, "time": time.toString()};
  }
}
