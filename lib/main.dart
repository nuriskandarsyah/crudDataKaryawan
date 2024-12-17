import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db/db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: KaryawanPage(),
    );
  }
}

class KaryawanPage extends StatefulWidget {
  @override
  _KaryawanPageState createState() => _KaryawanPageState();
}

class _KaryawanPageState extends State<KaryawanPage> {
  final dbHelper = DatabaseHelper.instance;

  final _namaController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _tanggalController = TextEditingController();

  List<Map<String, dynamic>> _karyawanList = [];
  int? _editId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKaryawan();
  }

  Future<void> _loadKaryawan() async {
    setState(() {
      _isLoading = true;
    });

    final data = await dbHelper.getAllKaryawan();
    setState(() {
      _karyawanList = data;
      _isLoading = false;
    });
  }

  Future<void> _saveKaryawan() async {
    if (_namaController.text.isEmpty ||
        _jabatanController.text.isEmpty ||
        _tanggalController.text.isEmpty) {
      _showSnackbar("Harap isi semua kolom!");
      return;
    }

    final data = {
      'nama': _namaController.text.trim(),
      'jabatan': _jabatanController.text.trim(),
      'tanggal_masuk': _tanggalController.text.trim(),
    };

    if (_editId == null) {
      // Tambahkan data baru
      await dbHelper.addKaryawan(data);
      _showSnackbar("Data berhasil ditambahkan!");
    } else {
      // Pastikan id tetap bertipe integer
      data['id'] = _editId as String;
      await dbHelper.updateKaryawan(data);
      _showSnackbar("Data berhasil diperbarui!");
    }

    _clearInput();
    _loadKaryawan();
  }

  void _clearInput() {
    _namaController.clear();
    _jabatanController.clear();
    _tanggalController.clear();
    _editId = null;
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  void _editKaryawan(Map<String, dynamic> data) {
    setState(() {
      _editId = data['id'];
      _namaController.text = data['nama'];
      _jabatanController.text = data['jabatan'];
      _tanggalController.text = data['tanggal_masuk'];
    });
  }

  void _deleteKaryawan(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus Data"),
        content: Text("Apakah Anda yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await dbHelper.deleteKaryawan(id);
      _showSnackbar("Data berhasil dihapus!");
      _loadKaryawan();
    }
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDatePicker(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Karyawan"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _buildTextField(_namaController, "Nama"),
                    SizedBox(height: 10),
                    _buildTextField(_jabatanController, "Jabatan"),
                    SizedBox(height: 10),
                    _buildDatePicker(_tanggalController, "Tanggal Masuk"),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveKaryawan,
                      child: Text(
                          _editId == null ? "Tambah Data" : "Simpan Perubahan"),
                    ),
                    Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _karyawanList.length,
                      itemBuilder: (context, index) {
                        final item = _karyawanList[index];
                        return ListTile(
                          title: Text(item['nama']),
                          subtitle: Text(
                              "${item['jabatan']} - Masuk: ${item['tanggal_masuk']}"),
                          onTap: () => _editKaryawan(item),
                          onLongPress: () => _deleteKaryawan(item['id']),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
