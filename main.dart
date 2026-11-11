import 'package:flutter/material.dart';

void main() {
  runApp(const AplikasiMahasiswa());
}

// MODEL DATA MAHASISWA
class Mahasiswa {
  final String nim;
  final String nama;
  final String prodi;

  Mahasiswa({required this.nim, required this.nama, required this.prodi});
}

// APLIKASI UTAMA
class AplikasiMahasiswa extends StatelessWidget {
  const AplikasiMahasiswa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Data Mahasiswa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HalamanDaftar(),
    );
  }
}

// HALAMAN DAFTAR MAHASISWA
class HalamanDaftar extends StatefulWidget {
  const HalamanDaftar({super.key});

  @override
  State<HalamanDaftar> createState() => _HalamanDaftarState();
}

class _HalamanDaftarState extends State<HalamanDaftar> {
  // DATA AWAL MAHASISWA
  final List<Mahasiswa> _daftar = [
    Mahasiswa(
      nim: '2601002',
      nama: 'Budi Santoso',
      prodi: 'Pendidikan Teknologi Informasi',
    ),
    Mahasiswa(
      nim: '2601003',
      nama: 'Dewi Lestari',
      prodi: 'Pendidikan Teknologi Informasi',
    ),
    Mahasiswa(
      nim: '2601004',
      nama: 'Andi Pratama',
      prodi: 'Pendidikan Teknologi Informasi',
    ),
  ];

  // MENAMPILKAN PESAN
  void _info(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), behavior: SnackBarBehavior.floating),
    );
  }

  // CREATE: TAMBAH MAHASISWA
  Future<void> _tambah() async {
    final hasil = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(builder: (context) => FormMahasiswa(daftar: _daftar)),
    );

    if (hasil == null) return;

    setState(() {
      _daftar.add(hasil);
    });

    _info('Data mahasiswa berhasil ditambahkan');
  }

  // UPDATE: UBAH MAHASISWA BERDASARKAN NIM
  Future<void> _ubah(Mahasiswa mahasiswaLama) async {
    final hasil = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FormMahasiswa(daftar: _daftar, awal: mahasiswaLama),
      ),
    );

    if (hasil == null) return;

    final index = _daftar.indexWhere((m) => m.nim == mahasiswaLama.nim);

    if (index == -1) return;

    setState(() {
      _daftar[index] = hasil;
    });

    _info('Data mahasiswa berhasil diperbarui');
  }

  // DELETE: HAPUS MAHASISWA
  Future<void> _hapus(Mahasiswa mahasiswa) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus '
            '${mahasiswa.nama} (${mahasiswa.nim})?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (yakin == true) {
      setState(() {
        _daftar.removeWhere((m) => m.nim == mahasiswa.nim);
      });

      _info('Data mahasiswa berhasil dihapus');
    }
  }

  // READ: MENAMPILKAN DAFTAR
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Data Mahasiswa (${_daftar.length})'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: _daftar.isEmpty
          ? const Center(
              child: Text('Belum ada data', style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _daftar.length,
              itemBuilder: (context, index) {
                final m = _daftar[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      child: Text(
                        m.nama.isNotEmpty ? m.nama[0].toUpperCase() : '?',
                      ),
                    ),

                    title: Text(
                      m.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NIM: ${m.nim}'),
                          Text('Prodi: ${m.prodi}'),
                        ],
                      ),
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Ubah',
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _ubah(m),
                        ),
                        IconButton(
                          tooltip: 'Hapus',
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _hapus(m),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambah,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Mahasiswa'),
      ),
    );
  }
}

// FORM TAMBAH DAN UBAH MAHASISWA
class FormMahasiswa extends StatefulWidget {
  final List<Mahasiswa> daftar;
  final Mahasiswa? awal;

  const FormMahasiswa({super.key, required this.daftar, this.awal});

  @override
  State<FormMahasiswa> createState() => _FormMahasiswaState();
}

class _FormMahasiswaState extends State<FormMahasiswa> {
  final _formKey = GlobalKey<FormState>();

  final _nimController = TextEditingController();
  final _namaController = TextEditingController();
  final _prodiController = TextEditingController();

  bool get _modeEdit => widget.awal != null;

  // MENGISI FORM DENGAN DATA AWAL
  @override
  void initState() {
    super.initState();

    if (_modeEdit) {
      _nimController.text = widget.awal!.nim;
      _namaController.text = widget.awal!.nama;
      _prodiController.text = widget.awal!.prodi;
    }
  }

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    _prodiController.dispose();
    super.dispose();
  }

  // MENYIMPAN DATA
  void _simpan() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final hasil = Mahasiswa(
      nim: _nimController.text.trim(),
      nama: _namaController.text.trim(),
      prodi: _prodiController.text.trim(),
    );

    Navigator.pop(context, hasil);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Ubah Data Mahasiswa' : 'Tambah Mahasiswa'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.school, size: 70, color: Colors.indigo),

              const SizedBox(height: 20),

              TextFormField(
                controller: _nimController,
                readOnly: _modeEdit,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  hintText: 'Masukkan NIM mahasiswa',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'NIM wajib diisi';
                  }

                  if (!_modeEdit) {
                    final ada = widget.daftar.any((m) => m.nim == value.trim());

                    if (ada) {
                      return 'NIM sudah terdaftar';
                    }
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _prodiController,
                decoration: const InputDecoration(
                  labelText: 'Program Studi',
                  hintText: 'Masukkan program studi',
                  prefixIcon: Icon(Icons.menu_book),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Program studi wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              FilledButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save),
                label: Text(_modeEdit ? 'Simpan Perubahan' : 'Simpan'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
