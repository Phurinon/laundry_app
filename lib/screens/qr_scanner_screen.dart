import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:laundry_app/models/theme.dart';

class QRScannerScreen extends StatefulWidget {
  final String machineId;

  const QRScannerScreen({super.key, required this.machineId});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
  );

  final TextEditingController _mockInputController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _mockInputController.dispose();
    super.dispose();
  }

  void _handleScanResult(String code) {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    // Check if the scanned code corresponds to the machine ID
    // Note: in a real app, the QR code might contain a URL or JSON.
    // For this mock, we simply expect the machineId as a string.
    Navigator.pop(context, code);
  }

  void _handleMockSubmit() {
    final text = _mockInputController.text.trim();
    if (text.isNotEmpty) {
      _handleScanResult(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'สแกน QR หน้าเครื่อง',
          style: GoogleFonts.prompt(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                  case TorchState.unavailable:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                  case TorchState.auto:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                switch (state.cameraDirection) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                  case CameraFacing.external:
                  case CameraFacing.unknown:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? rawValue = barcode.rawValue;
                if (rawValue != null) {
                  _handleScanResult(rawValue);
                  break;
                }
              }
            },
          ),
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primary, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Scan Instructions
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Text(
              'หันกล้องไปที่ QR Code หน้าเครื่องซักผ้า',
              textAlign: TextAlign.center,
              style: GoogleFonts.prompt(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          // Mock Input Bottom Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.developer_mode, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'สำหรับทดสอบ (Mock Input)',
                        style: GoogleFonts.prompt(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'รหัสเครื่องที่ถูกต้องสำหรับการจองนี้คือ: ${widget.machineId}',
                          style: GoogleFonts.prompt(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        color: AppTheme.primary,
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.machineId),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('คัดลอกรหัสเครื่องแล้ว'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _mockInputController,
                          decoration: InputDecoration(
                            hintText:
                                'ป้อนรหัสเครื่อง (เช่น ${widget.machineId})...',
                            hintStyle: GoogleFonts.prompt(
                              color: AppTheme.neutral400,
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: AppTheme.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: GoogleFonts.prompt(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _handleMockSubmit,
                          icon: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                          ),
                          tooltip: 'ยืนยันรหัส',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            ),
        ],
      ),
    );
  }
}
