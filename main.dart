import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'api_screen.dart';

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}

/// ------------------ HOME SCREEN ------------------
class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> enrolledSubjects = [
    {
      'subject': 'Mobile App Development',
      'teacher': 'Sir Nabeel Akram',
      'credits': 3,
    },
    {
      'subject': 'Information Security',
      'teacher': 'Miss Kashifa',
      'credits': 4,
    },
    {
      'subject': 'Compiler Construction',
      'teacher': 'Sir Hassan Iftikhar',
      'credits': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.save),
              title: Text('SQLite Text Saver'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => SQLiteDemo()));
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Text Entry Form'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => TextBoxFormScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Exit'),
              onTap: () => exit(0),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enrolled Subjects:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: enrolledSubjects.length,
                itemBuilder: (context, index) {
                  final subject = enrolledSubjects[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(subject['subject']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Teacher: ${subject['teacher']}'),
                          Text('Credit Hours: ${subject['credits']}'),
                        ],
                      ),
                      leading: Icon(Icons.book, color: Colors.blue),
                    ),
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

/// ------------------ TEXT ENTRY FORM SCREEN ------------------
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

    await _fetchRecords();
  }

  Future<void> _insertRecord(String text) async {
    if (text.isNotEmpty && _db != null) {
      await _db!.insert('texts', {'content': text});
      _controller.clear();
      await _fetchRecords(); // <-- await added here
    }
  }

  Future<void> _fetchRecords() async {
    if (_db != null) {
      final List<Map<String, dynamic>> results = await _db!.query('texts', orderBy: 'id DESC');
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

/// ------------------ SQLITE TEXT SAVER ------------------
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
    await _fetchRecords();
  }

  Future<void> _insertRecord(String text) async {
    if (_database == null) {
      return;
    }
    await _database!.insert('records', {'text': text});
    _textController.clear();
    await _fetchRecords(); // <-- await added here
  }

  Future<void> _fetchRecords() async {
    if (_database == null) {
      return;
    }
    List<Map<String, dynamic>> data = await _database!.query('records', orderBy: 'id DESC');
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
