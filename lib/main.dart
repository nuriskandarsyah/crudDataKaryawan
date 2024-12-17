import 'package:flutter/material.dart';
import 'db/db_helper.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keep Notes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  _loadNotes() async {
    final notes = await _databaseHelper.getAllNotes();
    setState(() {
      _notes = notes;
    });
  }

  _showNoteDialog([int? id, String title = '', String content = '']) {
    final _titleController = TextEditingController(text: title);
    final _contentController = TextEditingController(text: content);
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Tambah Note' : 'Edit Note'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Judul'),
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Isi Note'),
                maxLength: 1000,
                maxLines: null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                String title = _titleController.text;
                String content = _contentController.text;

                if (id == null) {
                  await _databaseHelper.addNote(title, date, content);
                } else {
                  await _databaseHelper.updateNote(id, title, date, content);
                }
                _loadNotes();
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Note'),
          content: Text('Apakah Anda yakin ingin menghapus note ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await _databaseHelper.deleteNote(id);
                _loadNotes();
                Navigator.of(context).pop();
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  String _formatContent(String content) {
    return content.length > 10 ? content.substring(0, 10) + '...' : content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Notes',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red),
      body: _notes.isEmpty
          ? Center(child: Text('Belum ada catatan'))
          : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3 / 2,
              ),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                var note = _notes[index];
                return Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      _showNoteDialog(
                        note['id'],
                        note['title'],
                        note['content'],
                      );
                    },
                    onLongPress: () {
                      _showDeleteDialog(note['id']);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${note['date']}',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _formatContent(note['content']),
                            style: TextStyle(fontSize: 14),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
