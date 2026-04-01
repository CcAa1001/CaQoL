import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrQuest extends StatefulWidget {
  final List<String> expectedValues;
  final VoidCallback onSuccess;

  const QrQuest({
    super.key,
    required this.expectedValues,
    required this.onSuccess,
  });

  @override
  State<QrQuest> createState() => _QrQuestState();
}

class _QrQuestState extends State<QrQuest> {
  final MobileScannerController _controller = MobileScannerController(torchEnabled: false);
  String? _error;
  bool _completed = false;
  bool _torchEnabled = false;
  late final String _selectedValue;

  @override
  void initState() {
    super.initState();
    final options = widget.expectedValues
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    options.shuffle();
    _selectedValue = options.isEmpty ? '' : options.first;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_completed) return;

    final scannedValue = capture.barcodes.first.rawValue?.trim() ?? '';
    if (scannedValue.isEmpty) return;

    if (_selectedValue.isEmpty || scannedValue == _selectedValue) {
      _completed = true;
      widget.onSuccess();
      return;
    }

    setState(() {
      _error = 'That QR code does not match the one registered for this alarm.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Scan the registered QR code',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedValue.isEmpty
                ? 'This alarm does not have a saved QR yet, so any detected code will pass.'
                : 'Point your camera at the selected code to dismiss the alarm.',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          if (widget.expectedValues.where((item) => item.trim().isNotEmpty).length > 1) ...[
            const SizedBox(height: 10),
            Text(
              'Today\'s random target: ${widget.expectedValues.indexOf(_selectedValue) + 1} of ${widget.expectedValues.where((item) => item.trim().isNotEmpty).length}',
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _handleDetect,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24, width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orangeAccent, width: 3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  await _controller.toggleTorch();
                  if (!mounted) return;
                  setState(() => _torchEnabled = !_torchEnabled);
                },
                icon: Icon(_torchEnabled ? Icons.flashlight_off : Icons.flashlight_on),
                label: Text(_torchEnabled ? 'Flashlight off' : 'Flashlight on'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Hold the QR inside the frame.',
            style: TextStyle(
              color: _error == null ? Colors.white60 : Colors.redAccent,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class QrScannerScreen extends StatefulWidget {
  final String title;
  final String description;

  const QrScannerScreen({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(torchEnabled: false);
  bool _didReturn = false;
  bool _torchEnabled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_didReturn) return;

    final value = capture.barcodes.first.rawValue?.trim() ?? '';
    if (value.isEmpty) return;

    _didReturn = true;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.description,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: MobileScanner(
                  controller: _controller,
                  onDetect: _handleDetect,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await _controller.toggleTorch();
                if (!mounted) return;
                setState(() => _torchEnabled = !_torchEnabled);
              },
              icon: Icon(_torchEnabled ? Icons.flashlight_off : Icons.flashlight_on),
              label: Text(_torchEnabled ? 'Flashlight off' : 'Flashlight on'),
            ),
            const SizedBox(height: 12),
            const Text(
              'The first detected QR code will be saved automatically.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

