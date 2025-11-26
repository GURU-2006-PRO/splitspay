import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../utils/constants.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() => _isProcessing = true);

    // Parse UPI link
    if (code.startsWith('upi://')) {
      _parseUpiLink(code);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR code. Please scan a UPI payment QR.')),
      );
      setState(() => _isProcessing = false);
    }
  }

  void _parseUpiLink(String upiLink) {
    try {
      final uri = Uri.parse(upiLink);
      final params = uri.queryParameters;
      
      double amount = params['am'] != null ? double.tryParse(params['am']!) ?? 0.0 : 0.0;
      final merchantName = params['pn'] ?? 'Unknown Merchant';
      final merchantUpiId = params['pa'] ?? '';

      if (amount <= 0) {
        // Amount missing, ask user to enter
        _showAmountDialog(upiLink, merchantName, merchantUpiId);
      } else {
        // Amount present, proceed automatically
        final paymentData = {
          'upiLink': upiLink,
          'merchantName': merchantName,
          'merchantUpiId': merchantUpiId,
          'amount': amount,
          'transactionNote': params['tn'] ?? '',
        };
        Navigator.pop(context, paymentData);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error parsing QR code: $e')),
      );
      setState(() => _isProcessing = false);
    }
  }

  void _showAmountDialog(String upiLink, String merchantName, String merchantUpiId, {double initialAmount = 0.0}) {
    final controller = TextEditingController(
      text: initialAmount > 0 ? initialAmount.toStringAsFixed(2) : '',
    );
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Enter Amount for $merchantName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (merchantUpiId.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(merchantUpiId, style: const TextStyle(color: Colors.grey)),
              ),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.currency_rupee),
                hintText: '0.00',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isProcessing = false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final enteredAmount = double.tryParse(controller.text);
              if (enteredAmount != null && enteredAmount > 0) {
                Navigator.pop(context);
                
                // Update UPI link with amount
                final baseLink = upiLink.replaceAll(RegExp(r'&am=[^&]*'), '');
                final updatedLink = '$baseLink&am=$enteredAmount';
                
                final paymentData = {
                  'upiLink': updatedLink,
                  'merchantName': merchantName,
                  'merchantUpiId': merchantUpiId,
                  'amount': enteredAmount,
                  'transactionNote': 'Payment to $merchantName',
                };
                
                Navigator.pop(context, paymentData);
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // Overlay with scanning frame
          CustomPaint(
            painter: ScannerOverlay(),
            child: Container(),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Text(
                      'Point camera at restaurant\'s UPI QR code',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Enter Manually'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Flash toggle
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              onPressed: () => cameraController.toggleTorch(),
              icon: const Icon(Icons.flash_on),
              color: Colors.white,
              iconSize: 32,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for scanner overlay
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    // Draw semi-transparent overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(12))),
      ),
      paint,
    );

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const bracketLength = 30.0;

    // Top-left
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top + bracketLength),
      Offset(scanArea.left, scanArea.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top),
      Offset(scanArea.left + bracketLength, scanArea.top),
      bracketPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(scanArea.right - bracketLength, scanArea.top),
      Offset(scanArea.right, scanArea.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top),
      Offset(scanArea.right, scanArea.top + bracketLength),
      bracketPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom - bracketLength),
      Offset(scanArea.left, scanArea.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom),
      Offset(scanArea.left + bracketLength, scanArea.bottom),
      bracketPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(scanArea.right - bracketLength, scanArea.bottom),
      Offset(scanArea.right, scanArea.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom - bracketLength),
      Offset(scanArea.right, scanArea.bottom),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
