import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../trip/presentation/providers/trip_provider.dart';

class QrScannerPage extends ConsumerStatefulWidget {
  final String userId;

  const QrScannerPage({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends ConsumerState<QrScannerPage> {
  final MobileScannerController controller = MobileScannerController();

  bool _isScanning = false;
  bool _isTorchOn = false;
  bool _isDetected = false;

  String? _extractInviteCode(String raw) {
    if (raw.startsWith('TRVL-')) return raw;

    final uri = Uri.tryParse(raw);
    if (uri != null) {
      for (final segment in uri.pathSegments) {
        if (segment.startsWith('TRVL-')) return segment;
      }
      final queryCode = uri.queryParameters['code'];
      if (queryCode != null && queryCode.startsWith('TRVL-')) {
        return queryCode;
      }
    }

    final match = RegExp(r'TRVL-[A-Za-z0-9]+').firstMatch(raw);
    return match?.group(0);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String code) async {
    setState(() => _isDetected = true);
    HapticFeedback.heavyImpact();

    final trip = await ref
        .read(tripControllerProvider.notifier)
        .joinTripByCode(code, widget.userId);

    if (!mounted) return;

    if (trip != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'joined_trip',
              params: {'id': trip.id},
            ),
          ),
        ),
      );

      // 🔥 navegación directa sin pop
      context.go('/trip/${trip.id}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('invalid_invite_code')),
          backgroundColor: Colors.red,
        ),
      );

      // permitir reintento
      setState(() {
        _isScanning = false;
        _isDetected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    const size = 250.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // CAMERA
          MobileScanner(
            controller: controller,
            onDetect: (barcodeCapture) {
              if (_isScanning) return;

              final barcode = barcodeCapture.barcodes.first;
              final raw = barcode.rawValue;
              if (raw == null) return;

              final code = _extractInviteCode(raw);

              if (code == null) {
                HapticFeedback.vibrate();
                return;
              }

              _isScanning = true;

              _handleScan(code);
            },
          ),

          // MÁSCARA
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                    child:
                        Container(color: Colors.black.withValues(alpha: 0.6))),
                SizedBox(
                  height: size,
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                              color: Colors.black.withValues(alpha: 0.6))),
                      const SizedBox(width: size),
                      Expanded(
                          child: Container(
                              color: Colors.black.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                Expanded(
                    child:
                        Container(color: Colors.black.withValues(alpha: 0.6))),
              ],
            ),
          ),

          // FRAME
          Center(
            child: SizedBox(
              width: size,
              height: size,
              child: _ScannerFrame(isDetected: _isDetected),
            ),
          ),

          // TEXTO
          Align(
            alignment: const Alignment(0, 0.35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isDetected
                      ? context.tr('code_detected')
                      : context.tr('point_at_qr'),
                  style: TextStyle(
                    color: _isDetected ? Colors.green : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!_isDetected) ...[
                  const SizedBox(height: 6),
                  Text(
                    context.tr('code_format_hint'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // BACK
          Positioned(
            top: paddingTop + 10,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          // FLASH
          Positioned(
            top: paddingTop + 10,
            right: 20,
            child: IconButton(
              icon: Icon(
                _isTorchOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: () async {
                await controller.toggleTorch();
                setState(() => _isTorchOn = !_isTorchOn);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerFrame extends StatefulWidget {
  final bool isDetected;

  const _ScannerFrame({required this.isDetected});

  @override
  State<_ScannerFrame> createState() => _ScannerFrameState();
}

class _ScannerFrameState extends State<_ScannerFrame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.isDetected ? Colors.green : Colors.white,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.isDetected
                ? [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Align(
              alignment: Alignment(0, -1 + (_controller.value * 2)),
              child: Container(
                height: 2,
                width: double.infinity,
                color: widget.isDetected
                    ? Colors.green
                    : Colors.white.withValues(alpha: 0.7),
              ),
            );
          },
        ),
      ],
    );
  }
}
