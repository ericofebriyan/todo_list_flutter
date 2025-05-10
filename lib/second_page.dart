import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final List<Map<String, String>> _schedules = [];
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String? schedulesString = prefs.getString('schedules');
    if (schedulesString != null) {
      setState(() {
        _schedules.addAll(
            List<Map<String, String>>.from(jsonDecode(schedulesString)));
      });
    }
  }

  Future<void> _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('schedules', jsonEncode(_schedules));
  }

  void _addSchedule() {
    if (_titleController.text.isNotEmpty && _selectedDate != null) {
      setState(() {
        _schedules.add({
          'title': _titleController.text,
          'date': _selectedDate.toString().split(' ')[0], // hanya ambil tanggal
        });
        _titleController.clear();
        _selectedDate = null;
      });
      _saveSchedules();
    } else {
      _showErrorDialog();
    }
  }

  void _removeSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
    _saveSchedules();
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Input Tidak Lengkap'),
        content: const Text('Harap isi judul dan pilih tanggal.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Jadwal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambah Jadwal',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Jadwal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showDatePicker,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Pilih Tanggal'),
                  ),
                ),
              ],
            ),
            if (_selectedDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Tanggal dipilih: ${_selectedDate!.toString().split(' ')[0]}',
                  style: theme.textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, // ✅ bikin tombol full width
              child: ElevatedButton(
                onPressed: _addSchedule,
                child: const Text('Tambah Jadwal'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Daftar Jadwal',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _schedules.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada jadwal',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _schedules.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final schedule = _schedules[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(schedule['title']!,
                              style: theme.textTheme.bodyLarge),
                          subtitle: Text('Tanggal: ${schedule['date']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeSchedule(index),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
