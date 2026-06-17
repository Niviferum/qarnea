import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/scan_service.dart';
import '../theme/colors.dart';
import '../theme/transitions.dart';
import 'scan_result_screen.dart';

/// Embedded barcode scanner view (camera preview + viewfinder mask),
/// designed to sit inside the consumer marketplace's bottom-nav IndexedStack.
class ConsumerScannerView extends StatefulWidget {
  final bool isActive;

  const ConsumerScannerView({super.key, required this.isActive});

  @override
  State<ConsumerScannerView> createState() => _ConsumerScannerViewState();
}

class _ConsumerScannerViewState extends State<ConsumerScannerView> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
    ],
  );

  final _scanService = ScanService();
  bool _handlingDetection = false;
  bool _isLoading = false;

  @override
  void didUpdateWidget(covariant ConsumerScannerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _handlingDetection = false;
      _controller.start();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_handlingDetection || capture.barcodes.isEmpty) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    _handlingDetection = true;
    _controller.stop();
    setState(() => _isLoading = true);

    try {
      final result = await _scanService.scanProduct(code);
      if (!mounted) return;
      await Navigator.of(context).push(fadeRoute(ScanResultScreen(result: result)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _handlingDetection = false;
        if (widget.isActive) _controller.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final viewfinderSize = w * 0.77;
        final viewfinderRect = Rect.fromLTWH(
          (w - viewfinderSize) / 2,
          h * 0.18,
          viewfinderSize,
          viewfinderSize,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            if (widget.isActive)
              MobileScanner(controller: _controller, onDetect: _onDetect)
            else
              Container(color: QarneaColors.vertSapin),
            ClipPath(
              clipper: _OutsideViewfinderClipper(viewfinderRect, 30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.white.withAlpha(77)),
              ),
            ),
            CustomPaint(
              painter: _ViewfinderCornersPainter(
                rect: viewfinderRect,
                radius: 30,
                color: QarneaColors.vertSapin,
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: QarneaColors.vertCitron,
                  strokeWidth: 3,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OutsideViewfinderClipper extends CustomClipper<Path> {
  final Rect viewfinder;
  final double radius;

  _OutsideViewfinderClipper(this.viewfinder, this.radius);

  @override
  Path getClip(Size size) {
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()
      ..addRRect(RRect.fromRectAndRadius(viewfinder, Radius.circular(radius)));
    return Path.combine(PathOperation.difference, full, hole);
  }

  @override
  bool shouldReclip(covariant _OutsideViewfinderClipper oldClipper) =>
      oldClipper.viewfinder != viewfinder || oldClipper.radius != radius;
}

class _ViewfinderCornersPainter extends CustomPainter {
  final Rect rect;
  final double radius;
  final Color color;
  static const _segmentLength = 28.0;
  static const _strokeWidth = 6.0;

  _ViewfinderCornersPainter({
    required this.rect,
    required this.radius,
    required this.color,
  });

  /// Draws one rounded corner bracket.
  /// [corner] is the rect corner point; [sx]/[sy] are +1/-1 indicating which
  /// direction (along x/y) the straight segments extend away from the corner.
  void _drawCorner(Canvas canvas, Paint paint, Offset corner, double sx, double sy) {
    final center = Offset(corner.dx + sx * radius, corner.dy + sy * radius);
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = sy > 0 ? -1.5707963267948966 : 1.5707963267948966; // -90° or 90°
    final sweepAngle = (sx * sy > 0 ? -1 : 1) * 1.5707963267948966; // ±90°

    final path = Path()
      ..moveTo(corner.dx + sx * (radius + _segmentLength), corner.dy)
      ..lineTo(corner.dx + sx * radius, corner.dy)
      ..arcTo(arcRect, startAngle, sweepAngle, false)
      ..lineTo(corner.dx, corner.dy + sy * (radius + _segmentLength));

    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawCorner(canvas, paint, rect.topLeft, 1, 1);
    _drawCorner(canvas, paint, rect.topRight, -1, 1);
    _drawCorner(canvas, paint, rect.bottomLeft, 1, -1);
    _drawCorner(canvas, paint, rect.bottomRight, -1, -1);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderCornersPainter oldDelegate) =>
      oldDelegate.rect != rect;
}
