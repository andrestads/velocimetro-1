import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocímetro GPS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ).copyWith(surface: Colors.grey.shade100),
        useMaterial3: true,
      ),
      home: const SpeedometerScreen(),
    );
  }
}

class SpeedometerScreen extends StatefulWidget {
  const SpeedometerScreen({super.key});

  @override
  State<SpeedometerScreen> createState() => _SpeedometerScreenState();
}

class _SpeedometerScreenState extends State<SpeedometerScreen> {
  double _currentSpeedKmH = 0.0;
  double _totalDistanceKm = 0.0;
  Position? _lastPosition;
  StreamSubscription<Position>? _positionSubscription;

  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;
  double _averageSpeedKmH = 0.0;

  bool _isHudMode = false;
  bool _isServiceEnabled = false;
  LocationPermission _permissionStatus = LocationPermission.denied;
  bool _isLoading = true;

  final NumberFormat _distanceFormatter = NumberFormat('0.00', 'pt_BR');
  final NumberFormat _speedFormatter = NumberFormat('0', 'pt_BR');

  @override
  void initState() {
    super.initState();
    _initLocationService();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocationService() async {
    try {
      _isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_isServiceEnabled) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _permissionStatus = await Geolocator.checkPermission();
      if (_permissionStatus == LocationPermission.denied) {
        _permissionStatus = await Geolocator.requestPermission();
      }

      if (_permissionStatus == LocationPermission.whileInUse ||
          _permissionStatus == LocationPermission.always) {
        _startListening();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao inicializar serviço de localização: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startListening() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        if (!mounted) return;

        _startTime ??= DateTime.now();

        double newDistanceKm = 0.0;
        if (_lastPosition != null) {
          final double distanceInMeters = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          newDistanceKm = distanceInMeters / 1000.0;
        }

        setState(() {
          _currentSpeedKmH = (position.speed * 3.6).abs();
          _totalDistanceKm += newDistanceKm;
          _lastPosition = position;

          if (_startTime != null) {
            _elapsedTime = DateTime.now().difference(_startTime!);
            final double elapsedHours = _elapsedTime.inSeconds / 3600.0;
            if (elapsedHours > 0) {
              _averageSpeedKmH = _totalDistanceKm / elapsedHours;
            } else {
              _averageSpeedKmH = 0.0;
            }
          }
        });
      },
      onError: (error) {
        debugPrint('Erro no stream de posição: $error');
        setState(() {
          _currentSpeedKmH = 0.0;
          _isLoading = false;
        });
        _initLocationService();
      },
      cancelOnError: false,
    );
  }

  void _resetData() {
    setState(() {
      _currentSpeedKmH = 0.0;
      _totalDistanceKm = 0.0;
      _lastPosition = null;
      _startTime = null;
      _elapsedTime = Duration.zero;
      _averageSpeedKmH = 0.0;
    });
    _positionSubscription?.cancel();
    _startListening();
  }

  void _toggleHudMode() {
    setState(() {
      _isHudMode = !_isHudMode;
    });
  }

  Widget _buildSpeedometerBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isServiceEnabled) {
      return const Center(
        child: Text(
          'Serviço de localização desativado. Ative o GPS para usar o velocímetro.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    if (_permissionStatus == LocationPermission.denied ||
        _permissionStatus == LocationPermission.deniedForever) {
      return const Center(
        child: Text(
          'Permissão de localização negada. Conceda a permissão para continuar.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    final speedWidget = Text(
      _speedFormatter.format(_currentSpeedKmH),
      style: TextStyle(
        fontSize: _isHudMode ? 140 : 100,
        fontWeight: FontWeight.w900,
        fontFamily: 'RobotoMono',
        color:
            _isHudMode ? Colors.white : Theme.of(context).colorScheme.primary,
        height: 1.0,
      ),
    );

    final unitsWidget = Text(
      'Km/h',
      style: TextStyle(
        fontSize: _isHudMode ? 40 : 24,
        fontWeight: FontWeight.bold,
        color: _isHudMode ? Colors.white70 : Colors.black87,
      ),
    );

    final distanceWidget = _buildDataRow(
      label: 'DISTÂNCIA',
      value: _distanceFormatter.format(_totalDistanceKm),
      unit: 'km',
      isHud: _isHudMode,
    );

    final avgSpeedWidget = _buildDataRow(
      label: 'VELOCIDADE MÉDIA',
      value: _speedFormatter.format(_averageSpeedKmH),
      unit: 'km/h',
      isHud: _isHudMode,
    );

    final elapsedTimeWidget = _buildDataRow(
      label: 'TEMPO DE DESLOCAMENTO',
      value: _formatDuration(_elapsedTime),
      unit: 'h:m:s',
      isHud: _isHudMode,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [speedWidget, unitsWidget],
          ),
        ),
        const Divider(height: 1, indent: 32, endIndent: 32),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [distanceWidget, avgSpeedWidget, elapsedTimeWidget],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow({
    required String label,
    required String value,
    required String unit,
    required bool isHud,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHud ? 18 : 14,
            fontWeight: FontWeight.w600,
            color: isHud ? Colors.white54 : Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: isHud ? 48 : 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoMono',
                color:
                    isHud
                        ? Colors.white
                        : Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: TextStyle(
                fontSize: isHud ? 20 : 16,
                color: isHud ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitHours = twoDigits(duration.inHours);
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final Widget content =
        _isHudMode
            ? Transform.scale(scaleX: -1, child: _buildSpeedometerBody(context))
            : _buildSpeedometerBody(context);

    return Scaffold(
      backgroundColor:
          _isHudMode ? Colors.black : Theme.of(context).colorScheme.surface,
      body: SafeArea(child: content),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        color:
            _isHudMode ? Colors.black : Theme.of(context).colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _resetData,
              icon: Icon(
                Icons.refresh,
                color: _isHudMode ? Colors.black : Colors.red,
              ),
              label: Text(
                'RESET',
                style: TextStyle(color: _isHudMode ? Colors.black : Colors.red),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isHudMode ? Colors.white : Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _toggleHudMode,
              icon: Icon(
                _isHudMode ? Icons.fullscreen_exit : Icons.fullscreen,
                color: _isHudMode ? Colors.black : Colors.white,
              ),
              label: Text(
                _isHudMode ? 'SAIR HUD' : 'MODO HUD',
                style: TextStyle(
                  color: _isHudMode ? Colors.black : Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isHudMode
                        ? Colors.yellow
                        : Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
