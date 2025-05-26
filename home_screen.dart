import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TextBoxFormScreen extends StatefulWidget {
  @override
  _TextBoxFormScreenState createState() => _TextBoxFormScreenState();
}

class _TextBoxFormScreenState extends State<TextBoxFormScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _records = [];
  Database? _db;

  @override
  void initState() {
    super.initState();
    _initDB();
  }

  Future<void> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'data.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE IF NOT EXISTS texts(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT)',
        );
      },
    );

    _fetchRecords();
  }

  Future<void> _insertRecord(String text) async {
    if (text.isNotEmpty && _db != null) {
      await _db!.insert('texts', {'content': text});
      _controller.clear();
      _fetchRecords();
    }
  }

  Future<void> _fetchRecords() async {
    if (_db != null) {
      final List<Map<String, dynamic>> results =
      await _db!.query('texts', orderBy: 'id DESC');
      setState(() {
        _records = results;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _db?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Entry Form'),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.edit, color: Colors.blue, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Text Entry Menu',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.blue),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context); // Just close the drawer
                Navigator.pop(context); // Navigate back to Home
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Close App'),
              onTap: () => exit(0),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter something...'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _insertRecord(_controller.text.trim()),
              child: Text('Save'),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_records[index]['content']),
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
