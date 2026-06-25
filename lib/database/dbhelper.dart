import 'package:qarazdare/models/model.dart';
import 'package:qarazdare/models/transaction_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Dbhelper {
  Database? _db;

  Future<Database> initDB() async {
    final String path = join(await getDatabasesPath(), 'person.db');
    return await openDatabase(
      path,
      version: 2, // CHANGE TO 2
      onCreate: (db, version) {
        db.execute('PRAGMA foreign_keys = ON');

        db.execute(
            'CREATE TABLE Person(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT,address TEXT, imagePath TEXT)'); // ADD imagePath
        db.execute('''CREATE TABLE Transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          personId INTEGER, 
          loan INTEGER,
          paid INTEGER,
          dateTime TEXT,
          note TEXT, 
          FOREIGN KEY (personId) REFERENCES Person(id) ON DELETE CASCADE
        )''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // ADD THIS for existing databases
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE Person ADD COLUMN imagePath TEXT');
        }
      },
    );
  }

  //---reuse database and store in _db
  Future<Database> resueDB() async {
    if (_db != null) return _db!;
    return _db = await initDB();
  }

  //---Data Insertion Method for Person
  Future<int> insertData(PersonModel person) async {
    final db = await resueDB();
    return await db.insert('Person', person.toMap());
  }

  //---ADD THIS: Update Person with image
  Future<void> updatePerson(PersonModel person) async {
    final db = await resueDB();
    await db.update('Person', person.toMap(),
        where: 'id=?', whereArgs: [person.id]);
  }

  //----Load All data to UI for Person
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await resueDB();
    return await db.query('Person');
  }

  //----Method to read just one person for Single Person Page
  Future<Map<String, dynamic>?> readPerson(int id) async {
    final db = await resueDB();
    final List<Map<String, dynamic>> table =
        await db.query('Person', where: 'id=?', whereArgs: [id]);
    if (table.isNotEmpty) return table.first;
    return null;
  }

  //------Delete Person
  Future<void> deletePerson(int id) async {
    final db = await resueDB();
    await db.delete('Person', where: 'id=?', whereArgs: [id]);
  }

  //------Method for inserting multiple rows for a person
  Future<void> insertLoan(TransactionModel transactions) async {
    final db = await resueDB();
    await db.insert('Transactions', transactions.toMap());
  }

  Future<List<Map<String, dynamic>>> getTranPerson(int personId) async {
    final db = await resueDB();
    return await db
        .query('Transactions', where: 'personId=?', whereArgs: [personId]);
  }

  // In dbhelper.dart
  Future<List<Map<String, dynamic>>> getDailyLoanAmounts() async {
    final db = await resueDB();
    return await db.rawQuery('''
    SELECT 
      date(dateTime) as date, 
      SUM(loan) as total_amount 
    FROM Transactions 
    WHERE loan > 0 
    GROUP BY date(dateTime) 
    ORDER BY date(dateTime) DESC 
    LIMIT 7
  ''');
  }
}
