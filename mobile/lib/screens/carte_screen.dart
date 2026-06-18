import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/operateur_map.dart';
import '../services/carte_service.dart';
import '../theme/colors.dart';

class CarteScreen extends StatefulWidget {
  const CarteScreen({super.key});

  @override
  State<CarteScreen> createState() => _CarteScreenState();
}

class _CarteScreenState extends State<CarteScreen> {
  final _carteService = CarteService();
  final _mapController = MapController();
  late Future<List<OperateurMap>> _future;
  Position? _userPosition;
  int _selectedRadius = 5;

  @override
  void initState() {
    super.initState();
    _future = _carteService.getOperateursMap();
    _requestLocation();
  }

  Future<void> _requestLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (!mounted) return;
      setState(() => _userPosition = pos);
      _mapController.move(LatLng(pos.latitude, pos.longitude), 11);
    } catch (_) {}
  }

  void _recenter() {
    if (_userPosition != null) {
      _mapController.move(
          LatLng(_userPosition!.latitude, _userPosition!.longitude), 11);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OperateurMap>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
                color: QarneaColors.vertSapin, strokeWidth: 2),
          );
        }
        if (snap.hasError) {
          return Center(
            child: Text(
              snap.error.toString(),
              style: const TextStyle(
                  fontFamily: 'HostGrotesk', color: QarneaColors.textLight),
            ),
          );
        }
        return Stack(
          children: [
            _MapView(
              operateurs: snap.data!,
              mapController: _mapController,
              userPosition: _userPosition,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _TopOverlay(
                selectedRadius: _selectedRadius,
                onRadiusSelected: (r) => setState(() => _selectedRadius = r),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 24,
              child: _RecenterButton(onTap: _recenter),
            ),
          ],
        );
      },
    );
  }
}

// ── Map item (cluster or individual pin) ──────────────────────────────────────

class _MapItem {
  final OperateurMap? op;
  final int count;
  final double lat;
  final double lng;

  _MapItem.pin(OperateurMap o)
      : op = o,
        count = 1,
        lat = o.lat,
        lng = o.lng;

  _MapItem.cluster({
    required this.count,
    required this.lat,
    required this.lng,
  }) : op = null;

  _MapItem._shifted({
    required this.op,
    required this.count,
    required this.lat,
    required this.lng,
  });

  _MapItem withPosition(double newLat, double newLng) =>
      _MapItem._shifted(op: op, count: count, lat: newLat, lng: newLng);

  bool get isCluster => op == null;
}

// ── Map ───────────────────────────────────────────────────────────────────────

class _MapView extends StatefulWidget {
  final List<OperateurMap> operateurs;
  final MapController mapController;
  final Position? userPosition;

  const _MapView({
    required this.operateurs,
    required this.mapController,
    this.userPosition,
  });

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> with SingleTickerProviderStateMixin {
  static const int _maxVisible = 20;
  static const int _minClusterSize = 3;

  late AnimationController _animController;
  List<_MapItem> _items = const [];
  double _currentZoom = 6.0;
  StreamSubscription<MapEvent>? _sub;
  Timer? _debounce;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      value: 1.0,
      duration: const Duration(milliseconds: 180),
    );
    _sub = widget.mapController.mapEventStream.listen(_scheduleRefresh);
    // Refresh initial une fois la carte rendue
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleRefresh());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _animController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  void _scheduleRefresh([MapEvent? _]) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _doRefresh);
  }

  Future<void> _doRefresh() async {
    if (_isRefreshing || !mounted) return;
    _isRefreshing = true;
    try {
      final newItems = _compute();
      await _animController.animateTo(0.0,
          duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
      if (!mounted) return;
      setState(() {
        _items = newItems;
        try { _currentZoom = widget.mapController.camera.zoom; } catch (_) {}
      });
      await _animController.animateTo(1.0,
          duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
    } finally {
      _isRefreshing = false;
    }
  }

  List<_MapItem> _compute() {
    try {
      final camera = widget.mapController.camera;
      final center = camera.center;
      final inBounds = widget.operateurs
          .where((op) => camera.visibleBounds.contains(LatLng(op.lat, op.lng)))
          .toList();
      final clustered = _cluster(inBounds, camera.zoom);
      clustered.sort((a, b) => _dist(a, center).compareTo(_dist(b, center)));
      return _declutter(clustered.take(_maxVisible).toList());
    } catch (_) {
      return const [];
    }
  }

  // Écarte les items superposés (même position à ~10m près) en cercle
  List<_MapItem> _declutter(List<_MapItem> items) {
    // Regroupe les items par position arrondie à 0.0001° (~10m)
    final Map<String, List<int>> byPos = {};
    for (int i = 0; i < items.length; i++) {
      final key =
          '${(items[i].lat * 10000).round()},${(items[i].lng * 10000).round()}';
      byPos.putIfAbsent(key, () => []).add(i);
    }

    final result = List<_MapItem>.from(items);
    for (final indices in byPos.values) {
      if (indices.length < 2) continue;
      // Rayon de ~200m en degrés (corrigé pour la longitude à la latitude de la France)
      const latRadius = 0.0018;
      final lngRadius = latRadius / cos(items[indices.first].lat * pi / 180);
      for (int i = 0; i < indices.length; i++) {
        final angle = (2 * pi * i) / indices.length;
        final orig = items[indices[i]];
        result[indices[i]] = orig.withPosition(
          orig.lat + latRadius * sin(angle),
          orig.lng + lngRadius * cos(angle),
        );
      }
    }
    return result;
  }

  List<_MapItem> _cluster(List<OperateurMap> ops, double zoom) {
    // Cellule ~30km à zoom 9, divise par 2 à chaque niveau de zoom
    final cellSize = max(0.01, 0.3 / pow(2.0, zoom - 9.0));
    final Map<String, List<OperateurMap>> cells = {};
    for (final op in ops) {
      final key = '${(op.lng / cellSize).floor()},${(op.lat / cellSize).floor()}';
      cells.putIfAbsent(key, () => []).add(op);
    }
    final result = <_MapItem>[];
    for (final group in cells.values) {
      if (group.length < _minClusterSize) {
        result.addAll(group.map(_MapItem.pin));
      } else {
        final lat = group.map((o) => o.lat).reduce((a, b) => a + b) / group.length;
        final lng = group.map((o) => o.lng).reduce((a, b) => a + b) / group.length;
        result.add(_MapItem.cluster(count: group.length, lat: lat, lng: lng));
      }
    }
    return result;
  }

  double _dist(_MapItem item, LatLng center) {
    final dlat = item.lat - center.latitude;
    final dlng = (item.lng - center.longitude) * cos(item.lat * pi / 180);
    return sqrt(dlat * dlat + dlng * dlng);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: const MapOptions(
        initialCenter: LatLng(46.8, 2.3),
        initialZoom: 6,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.qarnea.mobile_qarnea',
        ),
        // Marqueur de position toujours visible (pas de fade)
        if (widget.userPosition != null)
          MarkerLayer(markers: [
            Marker(
              point: LatLng(widget.userPosition!.latitude,
                  widget.userPosition!.longitude),
              width: 14,
              height: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: QarneaColors.vertCitron,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
                ),
              ),
            ),
          ]),
        // Clusters et épingles avec fade in/out
        AnimatedBuilder(
          animation: _animController,
          builder: (context, _) => Opacity(
            opacity: _animController.value,
            child: MarkerLayer(
              markers: _items.map(_buildItemMarker).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Marker _buildItemMarker(_MapItem item) {
    if (item.isCluster) {
      return Marker(
        point: LatLng(item.lat, item.lng),
        width: 52,
        height: 52,
        child: GestureDetector(
          onTap: () => widget.mapController.move(
            LatLng(item.lat, item.lng),
            (_currentZoom + 2).clamp(0, 18),
          ),
          child: _ClusterBadge(count: item.count),
        ),
      );
    }
    return _buildPinMarker(item.op!);
  }

  Marker _buildPinMarker(OperateurMap op) {
    final emoji = _productEmoji(op.produitsCertifies);
    return Marker(
      point: LatLng(op.lat, op.lng),
      width: 40,
      height: 48,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () => _showBottomSheet(op),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: op.inscritQarnea
                      ? QarneaColors.vertSapin
                      : const Color(0xFFCFCCC9),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            CustomPaint(
              size: const Size(8, 5),
              painter: _PinTipPainter(
                color: op.inscritQarnea
                    ? QarneaColors.vertSapin
                    : const Color(0xFFCFCCC9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(OperateurMap op) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OperateurSheet(operateur: op),
    );
  }
}

// ── Cluster badge ─────────────────────────────────────────────────────────────

class _ClusterBadge extends StatelessWidget {
  final int count;
  const _ClusterBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    final size = count < 10 ? 36.0 : count < 50 ? 44.0 : 52.0;
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: QarneaColors.vertSapin,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: QarneaColors.vertSapin.withAlpha(90),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'HostGrotesk',
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _PinTipPainter extends CustomPainter {
  final Color color;
  const _PinTipPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Top overlay ───────────────────────────────────────────────────────────────

class _TopOverlay extends StatelessWidget {
  final int selectedRadius;
  final ValueChanged<int> onRadiusSelected;

  const _TopOverlay(
      {required this.selectedRadius, required this.onRadiusSelected});

  static const _radiusOptions = [5, 10, 15, 20];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withAlpha(230),
            Colors.white.withAlpha(150),
            Colors.white.withAlpha(0),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 39,
                decoration: BoxDecoration(
                  color: QarneaColors.vertSapin,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 39,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color(0xFFCFCCC9)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Rechercher...',
                          style: TextStyle(
                            fontFamily: 'HostGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: Color(0x4D000000),
                            letterSpacing: -0.28,
                          ),
                        ),
                      ),
                      Icon(Icons.search,
                          size: 16, color: Color(0x4D000000)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 39,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _radiusOptions.length,
              separatorBuilder: (context, i) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final r = _radiusOptions[i];
                final isSelected = r == selectedRadius;
                final label = r <= 10 ? '$r km' : '+$r km';
                return GestureDetector(
                  onTap: () => onRadiusSelected(r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? QarneaColors.vertSapin
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'HostGrotesk',
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w300,
                        color: isSelected
                            ? Colors.white
                            : QarneaColors.vertSapin,
                        letterSpacing: -0.28,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recenter button ───────────────────────────────────────────────────────────

class _RecenterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RecenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 51,
        height: 51,
        decoration: BoxDecoration(
          color: QarneaColors.vertSapin,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.my_location_rounded,
            color: Colors.white, size: 26),
      ),
    );
  }
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class _OperateurSheet extends StatelessWidget {
  final OperateurMap operateur;
  const _OperateurSheet({required this.operateur});

  @override
  Widget build(BuildContext context) {
    final op = operateur;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: QarneaColors.blanc,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  op.raisonSociale,
                  style: const TextStyle(
                    fontFamily: 'OpenSauceTwo',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: QarneaColors.vertSapin,
                  ),
                ),
              ),
              if (op.inscritQarnea)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: QarneaColors.vertSapin,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Sur Qarnea',
                    style: TextStyle(
                      fontFamily: 'HostGrotesk',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          if (op.ville != null) ...[
            const SizedBox(height: 4),
            Text(
              op.ville!,
              style: const TextStyle(
                fontFamily: 'HostGrotesk',
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: QarneaColors.textLight,
              ),
            ),
          ],
          if (op.produitsCertifies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: op.produitsCertifies
                  .take(5)
                  .map(
                    (p) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCEFD6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        p,
                        style: const TextStyle(
                          fontFamily: 'HostGrotesk',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D6A2D),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: op.inscritQarnea
                      ? QarneaColors.vertSapin
                      : QarneaColors.vertCitron,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                op.inscritQarnea
                    ? 'Producteur inscrit sur Qarnea'
                    : 'Opérateur Agence Bio — non inscrit',
                style: const TextStyle(
                  fontFamily: 'HostGrotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: QarneaColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _productEmoji(List<String> produits) {
  if (produits.isEmpty) return '🌱';
  final nom = produits.first.toLowerCase();
  if (nom.contains('légume') || nom.contains('maraîch') || nom.contains('legume')) return '🥬';
  if (nom.contains('fruit')) return '🍎';
  if (nom.contains('jus')) return '🧃';
  if (nom.contains('lait') || nom.contains('crèm') || nom.contains('fromage')) return '🥛';
  if (nom.contains('viande') || nom.contains('boeuf') || nom.contains('porc')) return '🥩';
  if (nom.contains('miel') || nom.contains('ruche') || nom.contains('apicul')) return '🍯';
  if (nom.contains('eau')) return '💧';
  if (nom.contains('oeuf') || nom.contains('œuf')) return '🥚';
  if (nom.contains('volaille') || nom.contains('poulet') || nom.contains('avicul')) return '🐓';
  if (nom.contains('vin') || nom.contains('vigne') || nom.contains('alcool')) return '🍷';
  if (nom.contains('céréale') || nom.contains('blé') || nom.contains('grain')) return '🌾';
  return '🌱';
}
