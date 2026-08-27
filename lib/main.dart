import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aplikasi_cuaca/style.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const CuacaApp());
}

class CuacaApp extends StatelessWidget {
  const CuacaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Cuaca',
      theme: orangeWhiteTheme,
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
        'appid': dotenv.isInitialized ? (dotenv.env['OPW_API_KEY'] ?? '') : '',
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

  String _getWeatherAsset(String? icon, String? mainCondition) {
    if (icon != null && icon.isNotEmpty) {
      switch (icon) {
        case '01d':
          return 'assets/01_sunny.png';
        case '01n':
          return 'assets/15_crescent_moon_star.png';
        case '02d':
          return 'assets/02_partly_cloudy_1.png';
        case '02n':
          return 'assets/08_cloudy_night.png';
        case '03d':
        case '04d':
          return 'assets/03_sunny_cloud.png';
        case '03n':
        case '04n':
          return 'assets/08_cloudy_night.png';
        case '09d':
        case '09n':
          return 'assets/09_rain_drops.png';
        case '10d':
          return 'assets/04_light_rain_diagonal.png';
        case '10n':
          return 'assets/12_rain_dots.png';
        case '11d':
        case '11n':
          return 'assets/07_thunderstorm_1.png';
        case '13d':
        case '13n':
          return 'assets/05_snow_cloud.png';
        case '50d':
        case '50n':
          return 'assets/16_foggy_cloud.png';
      }
    }

    final main = (mainCondition ?? '').toLowerCase();
    if (main.contains('rain')) return 'assets/04_light_rain_diagonal.png';
    if (main.contains('drizzle')) return 'assets/09_rain_drops.png';
    if (main.contains('thunder')) return 'assets/07_thunderstorm_1.png';
    if (main.contains('snow')) return 'assets/05_snow_cloud.png';
    if (main.contains('cloud')) return 'assets/03_sunny_cloud.png';
    if (main.contains('fog') || main.contains('mist') || main.contains('haze')) {
      return 'assets/16_foggy_cloud.png';
    }
    return 'assets/01_sunny.png';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aplikasi Cuaca',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kotaController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama kota...',
                      labelText: 'Nama kota',
                      prefixIcon: const Icon(Icons.location_city, color: Colors.orange),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _ambilDataCuaca(),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(14),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _ambilDataCuaca,
                    child: const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: CircularProgressIndicator(),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_dataCuaca != null && !_isLoading) _buildHasilCuaca(),
          ],
        ),
      ),
    );
  }

  Widget _buildHasilCuaca() {
    final String namaKota = _dataCuaca!['name'] ?? '-';
    final String? country = _dataCuaca!['sys']?['country'];
    final double suhu = (_dataCuaca!['main']['temp'] as num).toDouble();
    final double terasaSeperti =
        (_dataCuaca!['main']['feels_like'] as num).toDouble();
    final int kelembapan = _dataCuaca!['main']['humidity'] as int;
    final num? windSpeed = _dataCuaca!['wind']?['speed'];
    
    final weatherList = _dataCuaca!['weather'] as List?;
    final String icon = (weatherList != null && weatherList.isNotEmpty)
        ? (weatherList[0]['icon'] ?? '')
        : '';
    final String mainCondition = (weatherList != null && weatherList.isNotEmpty)
        ? (weatherList[0]['main'] ?? '')
        : '';
    final String rawDeskripsi = (weatherList != null && weatherList.isNotEmpty)
        ? (weatherList[0]['description'] ?? '')
        : '-';
    final String deskripsi = _capitalize(rawDeskripsi);
    final String assetPath = _getWeatherAsset(icon, mainCondition);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withAlpha(50), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Assets Cuaca di Bagian Atas Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                assetPath,
                width: 130,
                height: 130,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.cloud,
                  size: 100,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Keterangan Cuaca di Bagian Bawah
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.orange, size: 20),
                const SizedBox(width: 4),
                Text(
                  country != null ? '$namaKota, $country' : namaKota,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Suhu
            Text(
              '${suhu.toStringAsFixed(1)}°C',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Colors.orange,
              ),
            ),

            // Deskripsi Cuaca
            Text(
              deskripsi,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),

            const Divider(color: Color(0xFFEEEEEE), thickness: 1.2),
            const SizedBox(height: 16),

            // Detail Keterangan Tambahan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  icon: Icons.thermostat,
                  label: 'Terasa seperti',
                  value: '${terasaSeperti.toStringAsFixed(1)}°C',
                ),
                _buildInfoItem(
                  icon: Icons.water_drop,
                  label: 'Kelembapan',
                  value: '$kelembapan%',
                ),
                if (windSpeed != null)
                  _buildInfoItem(
                    icon: Icons.air,
                    label: 'Angin',
                    value: '$windSpeed m/s',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }
}