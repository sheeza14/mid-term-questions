import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    home: SQLiteDemo(),
  ));
}

class SQLiteDemo extends StatefulWidget {
  @override
  _SQLiteDemoState createState() => _SQLiteDemoState();
}

class _SQLiteDemoState extends State<SQLiteDemo> {
  TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> _records = [];

  Database? _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "records.db");

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE records (id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT)",
        );
      },
    );
    print('Database initialized at $path');
    await _fetchRecords(); // await added here
  }

  Future<void> _insertRecord(String text) async {
    if (_database == null) {
      print('Database is not initialized yet!');
      return;
    }
    await _database!.insert('records', {'text': text});
    print('Inserted: $text');
    _textController.clear();
    await _fetchRecords();  // await added here
  }

  Future<void> _fetchRecords() async {
    if (_database == null) {
      print('Database is not initialized yet!');
      return;
    }
    List<Map<String, dynamic>> data = await _database!.query('records');
    print('Fetched Records: $data');
    setState(() {
      _records = data;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SQLite Text Saver')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Enter text'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                String text = _textController.text.trim();
                if (text.isNotEmpty) {
                  await _insertRecord(text);
                }
              },
              child: Text('Save to SQLite'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_records[index]['text']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
