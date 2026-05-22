import 'package:flutter/material.dart';

class QrCodeWidget extends StatelessWidget {
  final String data;
  const QrCodeWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      color: Colors.white,
      child: const Center(
        child: Text('QR Code Placeholder'),
      ),
    );
  }
}
