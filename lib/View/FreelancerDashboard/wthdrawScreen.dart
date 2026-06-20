import 'package:flutter/material.dart';

class WithdrawFundsScreen extends StatefulWidget {
  const WithdrawFundsScreen({super.key});

  @override
  State<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends State<WithdrawFundsScreen> {
  final TextEditingController _upiController = TextEditingController(
    text: 'student.name@upi',
  );
  final TextEditingController _amountController = TextEditingController(
    text: '500.00',
  );
  bool _isVerified = false;

  @override
  void dispose() {
    _upiController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Withdraw Funds',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // UPI ID Section
              const Text(
                'UPI ID',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _upiController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isVerified = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('UPI ID verified successfully'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4D67),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Verify',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Withdrawal Amount Section
              const Text(
                'Withdrawal Amount (₹)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 32),

              // QR Code Section
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Scan to Pay (UPI)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A quick way to get your funds. Ensure your\nUPI app is ready.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3E50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomPaint(painter: QRCodePainter()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Security Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, size: 20, color: Colors.grey[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your withdrawal is secured by CampusBridge encrypted payment system.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Confirm Withdrawal Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isVerified
                          ? () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: const Text('Withdrawal Initiated'),
                                    content: Text(
                                      'Your withdrawal of ₹${_amountController.text} has been initiated to ${_upiController.text}',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8B5FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text(
                    'Confirm Withdrawal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom QR Code Painter (simplified pattern)
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    final blockSize = size.width / 10;

    // Create a simple QR-like pattern
    final pattern = [
      [1, 1, 1, 0, 1, 0, 1, 1, 1, 0],
      [1, 0, 1, 0, 0, 1, 0, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 1, 0, 1],
      [0, 0, 0, 1, 0, 1, 0, 0, 0, 0],
      [1, 1, 0, 0, 1, 1, 0, 1, 1, 0],
      [0, 1, 1, 0, 0, 1, 1, 0, 1, 1],
      [1, 0, 1, 1, 0, 0, 1, 1, 0, 0],
      [1, 1, 0, 1, 1, 0, 0, 1, 1, 1],
      [0, 1, 0, 0, 1, 1, 1, 0, 1, 0],
      [1, 0, 1, 1, 0, 1, 0, 1, 0, 1],
    ];

    for (int i = 0; i < pattern.length; i++) {
      for (int j = 0; j < pattern[i].length; j++) {
        if (pattern[i][j] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              j * blockSize,
              i * blockSize,
              blockSize * 0.9,
              blockSize * 0.9,
            ),
            paint,
          );
        }
      }
    }

    // Draw corner squares
    final cornerPaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Top-left corner
    canvas.drawRect(
      Rect.fromLTWH(0, 0, blockSize * 3, blockSize * 3),
      cornerPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(blockSize, blockSize, blockSize, blockSize),
      paint,
    );

    // Top-right corner
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - blockSize * 3,
        0,
        blockSize * 3,
        blockSize * 3,
      ),
      cornerPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - blockSize * 2,
        blockSize,
        blockSize,
        blockSize,
      ),
      paint,
    );

    // Bottom-left corner
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height - blockSize * 3,
        blockSize * 3,
        blockSize * 3,
      ),
      cornerPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        blockSize,
        size.height - blockSize * 2,
        blockSize,
        blockSize,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
