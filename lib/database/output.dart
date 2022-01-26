import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

class DataBaseOutputHelper {
  DataBaseOutputHelper._();
  static final instance = DataBaseOutputHelper._();

  static sql.Database? _database;
  Future<sql.Database> get database async => _database ??= await _init();

  Future<sql.Database> _init() async {
    var documentdir = await getApplicationDocumentsDirectory();

    return sql.openDatabase(
      join(documentdir.path, 'output.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE output(
            id TEXT PRIMARY KEY,
            duration INT,
            total INT
          );
        ''',
        );
      },
    );
  }

  Future<bool> find(String id) async {
    var db = await instance.database;
    var query = await db.query('output', where: "id = ?", whereArgs: [id]);
    // print(query);
    return query.isEmpty ? false : true;
  }

  Future<Duration> getDuration(String id) async {
    var db = await instance.database;
    var query =
        await db.query('output', where: "id = ?", whereArgs: [id], limit: 1);
    // print(query);
    return query.isNotEmpty
        ? Duration(seconds: query.first['duration'] as int)
        : const Duration();
  }

  Future<double> getPercentage(String id) async {
    var db = await instance.database;
    var query =
        await db.query('output', where: "id = ?", whereArgs: [id], limit: 1);
    // print(query);
    if (query.isEmpty) return 0;

    int total = query.first['total'] as int;
    int duration = query.first['duration'] as int;
    if (total == 0) {
      return -100.0;
    }
    return duration / total;
  }

  Future<bool> remove(String id) async {
    var db = await instance.database;
    var query = await db.delete('output', where: "id = ?", whereArgs: [id]);
    return query != 0 ? true : false;
  }

  Future<void> add(AnimeOutput anime) async {
    var db = await instance.database;
    await db.insert(
      'output',
      anime.toMap(),
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }
}

class AnimeOutput {
  // ignore: non_constant_identifier_names
  final String id;
  // ignore: non_constant_identifier_names
  final int duration;
  final int total;

  AnimeOutput({
    required this.id,
    required this.duration,
    required this.total,
  });

  factory AnimeOutput.fromMap(Map<String, dynamic> map) {
    return AnimeOutput(
        id: map['id']!, duration: map['duration']!, total: map['total']);
  }
  Map<String, dynamic> toMap() {
    return {"id": id, "duration": duration, 'total': total};
  }
}
