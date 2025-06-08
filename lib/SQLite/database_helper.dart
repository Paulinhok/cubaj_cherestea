import 'dart:async';

import 'package:scandura/SQLite/cubbing.dart';
import 'package:scandura/SQLite/measuring.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  late Future<Database> _db;

  String dbName = "scandura.db";
  String listeCubaj = "liste_cubaj";
  String cubajMasuratori = "cubaj_masuratori";

  Future<Database> get database async {
    return _db;
  }

  Future<void> insertListeCubaj(
      String name, double cubajTotal, double pretTotal) async {
    final db = await initDB();
    await db.insert(listeCubaj, {
      'nume_lista': name,
      'cubaj_total': cubajTotal.toStringAsFixed(3),
      'pret_total': pretTotal,
    });
  }

  Future<void> insertCubajMasuratori(String name, int numarCurent, int bucati,
      double lungime, double latime, double grosime, double cubajBucata) async {
    final db = await initDB();

    List<Map<String, dynamic>> existingRows = await db.query(
      cubajMasuratori,
      where:
          'nume_lista = ? AND lungime = ? AND latime = ? AND grosime = ? AND bucati = ? AND cubaj_bucata = ?',
      whereArgs: [name, lungime, latime, grosime, bucati, cubajBucata],
    );
    // if (latime < 20) {
      if (existingRows.isNotEmpty) {
        int existingBucati = existingRows.first['bucati'];
        int newBucati = existingBucati + bucati;
        await db.update(
          cubajMasuratori,
          {'bucati': newBucati},
          where: 'id = ?',
          whereArgs: [existingRows.first['id']],
        );
      } else {
        await db.insert(cubajMasuratori, {
          'nume_lista': name,
          'numar_curent': numarCurent,
          'bucati': bucati,
          'lungime': lungime,
          'latime': latime,
          'grosime': grosime,
          'cubaj_bucata': cubajBucata,
        });
      }
    // } else {
    //   await db.insert(cubajMasuratori, {
    //     'nume_lista': name,
    //     'numar_curent': numarCurent,
    //     'bucati': bucati,
    //     'lungime': lungime,
    //     'latime': latime,
    //     'grosime': grosime,
    //     'cubaj_bucata': cubajBucata,
    //   });
    // }
  }

  Future<int> getNextNumarCurent(String numeLista) async {
    final db = await initDB();
    final result = await db.rawQuery(
      'SELECT MAX(numar_curent) as max_numar_curent FROM $cubajMasuratori WHERE nume_lista = ?',
      [numeLista],
    );
    return result.first['max_numar_curent'] != null
        ? result.first['max_numar_curent'] as int
        : 0;
  }

  Future updateListeCubajCubajTotal(
      String numeLista, double cubajTotal, double pretTotal) async {
    final db = await initDB();
    await db.update(
      listeCubaj,
      {'cubaj_Total': cubajTotal, 'pret_Total': pretTotal},
      where: 'nume_lista = ?',
      whereArgs: [numeLista],
    );
  }

  Future updatePretUnitar(String numeLista, double pretUnitar) async {
    final db = await initDB();
    await db.update('liste_cubaj', {'pret_unitar': pretUnitar},
        where: 'nume_lista = ?', whereArgs: [numeLista]);
  }

  Future<void> updatePretTotal(String numeLista) async {
  final db = await initDB();

  final pretUnitar = await getPretUnitar(numeLista);
  final cubajTotal = await getCubajTotal(numeLista);

  final pretTotalActualizat = double.parse((pretUnitar * cubajTotal).toStringAsFixed(3));

  await db.rawUpdate(
    'UPDATE liste_cubaj SET pret_total = ?, cubaj_total = ? WHERE nume_lista = ?',
    [pretTotalActualizat, cubajTotal, numeLista],
  );
}

  // o metoda noua de update pentru pretul unitar
  // prima data fac un query de select pentru a lua cubajul total sau tot cu o variabila globala dinamica

  Future<Database> initDB() async {
    Directory docsDirectory = await getApplicationDocumentsDirectory();
    String path = join(docsDirectory.path, dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDB,
      onOpen: (db) async {},
    );
  }

  Future<List<Cubaj>> getCubbings() async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query(listeCubaj,
        orderBy: 'data_creare DESC',
        );
    return List.generate(maps.length, (i) {
      return Cubaj.fromMap(maps[i]);
    });
  }

  Future<List<CubajMasuratori>> getMeasuring(String numeLista) async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query(
      cubajMasuratori,
      where: 'nume_lista = ?',
      whereArgs: [numeLista],
    );
    return List.generate(maps.length, (i) {
      return CubajMasuratori.fromMap(maps[i]);
    });
  }

  Future<Cubaj> getListDetails(String numeLista) async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query(
      listeCubaj,
      where: 'nume_lista = ?',
      whereArgs: [numeLista],
    );

    return Cubaj.fromMap(maps.first);
  }

  Future<double> getCubajTotal(String numeLista) async {
  final db = await initDB();

  // Obține toate rândurile relevante din tabelul `cubaj_masuratori`
  final List<Map<String, dynamic>> rows = await db.query(
    cubajMasuratori,
    where: 'nume_lista = ?',
    whereArgs: [numeLista],
  );

  // Calculează cubajul total folosind formula
  double totalCubaj = 0.0;
  for (var row in rows) {
    final double cubajBucata = row['cubaj_bucata'] as double;
    final int bucati = row['bucati'] as int;

    // Adaugă cubajul total pentru fiecare rând
    totalCubaj += cubajBucata * bucati;
  }

  return totalCubaj;
}

  Future<double> getPretTotal(String numeLista) async {
    final db = await initDB();
    final result = await db.rawQuery(
      'SELECT pret_total AS pretTotal FROM $listeCubaj WHERE nume_lista = ?',
      [numeLista],
    );
    return result.first['pretTotal'] != null
        ? result.first['pretTotal'] as double
        : 0;
  }

  Future<double> getPretUnitar(String numeLista) async {
    final db = await initDB();
    final result = await db.rawQuery(
      'SELECT pret_unitar AS pretUnitar FROM $listeCubaj WHERE nume_lista = ?',
      [numeLista],
    );
    return result.first['pretUnitar'] != null
        ? result.first['pretUnitar'] as double
        : 0;
  }

  Future<bool> verifyListIsUnique(String numeLista) async {
    final db = await initDB();
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $listeCubaj WHERE nume_lista = ?',
      [numeLista],
    );
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count == 0;
  }

  Future<void> updateData(CubajMasuratori cubaj) async {
    final db = await initDB();
    await db.update(
      'cubaj_masuratori',
      cubaj.toMap(),
      where: 'id = ?',
      whereArgs: [cubaj.id],
    );
  }

  Future<void> updateCubaj(String numeLista) async {
    final db = await initDB();
    final cubajTotal = await getCubajTotal(numeLista);
    final pretUnitar = await getPretUnitar(numeLista);
    final pretTotal = (pretUnitar * cubajTotal).toStringAsFixed(3);

    await db.rawUpdate(
        'UPDATE liste_cubaj SET cubaj_total = ?, pret_total = ? WHERE nume_lista = ?',
        [cubajTotal, pretTotal, numeLista]);
  }

  Future<int> deteleCubaj(int id) async {
    final db = await initDB();
    return await db.delete(
      'cubaj_masuratori',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteList(String numeLista) async {
    final db = await initDB();

    await db.delete(
      'cubaj_masuratori',
      where: 'nume_lista = ?',
      whereArgs: [numeLista],
    );

    return await db.delete(
      'liste_cubaj',
      where: 'nume_lista = ?',
      whereArgs: [numeLista],
    );
  }
  

  Future<void> _onCreateDB(Database db, int version) async {
    await db.execute("""CREATE TABLE IF NOT EXISTS $listeCubaj(
      id INTEGER PRIMARY KEY NOT NULL,
      nume_lista TEXT,
      cubaj_total DOUBLE,
      pret_total DOUBLE,
      pret_unitar DOUBLE,
      data_creare INTEGER NOT NULL DEFAULT (strftime('%s','now')),
      cale TEXT
    )""");

    await db.execute("""CREATE TABLE IF NOT EXISTS $cubajMasuratori(
      id INTEGER PRIMARY KEY NOT NULL,
      nume_lista TEXT,
      numar_curent INTEGER NOT NULL,
      bucati INTEGER NOT NULL,
      lungime DOUBLE NOT NULL,
      latime INTEGER NOT NULL,
      grosime INTEGER NOT NULL,
      cubaj_bucata DOUBLE NOT NULL
    )""");
  }
}
