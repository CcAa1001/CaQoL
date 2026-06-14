import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/qr_service.dart';
import '../../theme/app_theme.dart';

class QrManagerScreen extends StatefulWidget {
  const QrManagerScreen({super.key});

  @override
  State<QrManagerScreen> createState() => _QrManagerScreenState();
}

class _QrManagerScreenState extends State<QrManagerScreen> {
  final _qrService = QrService();
  late Map<String, String> _savedQrs;

  @override
  void initState() {
    super.initState();
    _loadQrs();
  }

  void _loadQrs() {
    setState(() {
      _savedQrs = _qrService.getAll();
    });
  }

  Future<void> _scanNewQr() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission required to scan QR code')),
      );
      return;
    }

    if (!mounted) return;
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _QrScannerView()),
    );

    if (code != null && mounted) {
      _showSaveDialog(code);
    }
  }

  Future<void> _showSaveDialog(String code) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Save QR Code', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter a name for this QR code (e.g. Bathroom Sink)', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintText: 'QR Name',
                hintStyle: const TextStyle(color: Colors.white30),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Save', style: TextStyle(color: AppTheme.neonCyan)),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await _qrService.save(name, code);
      _loadQrs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Saved QR Codes', style: TextStyle(color: Colors.white)),
      ),
      body: _savedQrs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code, size: 64, color: Colors.white30),
                  const SizedBox(height: 16),
                  const Text('No saved QR codes', style: TextStyle(color: Colors.white50)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _scanNewQr,
                    icon: const Icon(Icons.add),
                    label: const Text('Scan New QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._savedQrs.entries.map((e) => Card(
                      color: AppTheme.surface,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.qr_code_2, color: AppTheme.neonCyan),
                        title: Text(e.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('Data: ${e.value}', style: const TextStyle(color: Colors.white50), maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.danger),
                          onPressed: () async {
                            await _qrService.delete(e.key);
                            _loadQrs();
                          },
                        ),
                      ),
                    )),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _scanNewQr,
                  icon: const Icon(Icons.add),
                  label: const Text('Scan New QR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
    );
  }
}

class _QrScannerView extends StatefulWidget {
  const _QrScannerView();

  @override
  State<_QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<_QrScannerView> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Scan QR to Save', style: TextStyle(color: Colors.white)),
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              Navigator.pop(context, barcode.rawValue);
              break;
            }
          }
        },
      ),
    );
  }
}
