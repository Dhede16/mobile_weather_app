import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Daftar dulu di https://openweathermap.org/api untuk dapat API key gratis
const String kApiKey = '108e432ad82b9ca4f479bdae84cb671f';

void main() {
  runApp(const CuacaApp());
}

class CuacaApp extends StatelessWidget {
  const CuacaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Cuaca',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CuacaPage(),
    );
  }
}

class CuacaPage extends StatefulWidget {
  const CuacaPage({super.key});

  @override
  State<CuacaPage> createState() => _CuacaPageState();
}

class _CuacaPageState extends State<CuacaPage> {
  final TextEditingController _kotaController = TextEditingController(
    text: 'Samarinda',
  );

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _dataCuaca;

  @override
  void initState() {
    super.initState();
    debugPrint('CuacaPage dimulai');
    _ambilDataCuaca();
  }

  @override
  void dispose() {
    _kotaController.dispose();
    super.dispose();
  }

  Future<void> _ambilDataCuaca() async {
    final String kota = _kotaController.text.trim();
    if (kota.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final Uri url = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      <String, String>{
        'q': kota,
        'appid': kApiKey,
        'units': 'metric',
        'lang': 'id',
      },
    );

    try {
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _dataCuaca = jsonDecode(response.body) as Map<String, dynamic>;
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage =
              'API key OpenWeather tidak valid. Periksa atau ganti kApiKey.';
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Kota tidak ditemukan.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal mengambil data (kode ${response.statusCode}).';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengambil data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aplikasi Cuaca')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kotaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama kota',
                    ),
                    onSubmitted: (_) => _ambilDataCuaca(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _ambilDataCuaca,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_dataCuaca != null && !_isLoading) _buildHasilCuaca(),
          ],
        ),
      ),
    );
  }

  Widget _buildHasilCuaca() {
    final String namaKota = _dataCuaca!['name'] ?? '-';
    final double suhu = (_dataCuaca!['main']['temp'] as num).toDouble();
    final double terasaSeperti =
    (_dataCuaca!['main']['feels_like'] as num).toDouble();
    final int kelembapan = _dataCuaca!['main']['humidity'] as int;
    final String deskripsi = _dataCuaca!['weather'][0]['description'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(namaKota, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('${suhu.toStringAsFixed(1)}°C',
                style: Theme.of(context).textTheme.displaySmall),
            Text(deskripsi),
            const SizedBox(height: 8),
            Text('Terasa seperti: ${terasaSeperti.toStringAsFixed(1)}°C'),
            Text('Kelembapan: $kelembapan%'),
          ],
        ),
      ),
    );
  }
}