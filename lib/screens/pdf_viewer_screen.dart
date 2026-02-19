import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:exani/services/admob_service.dart';
import 'package:exani/services/purchase_service.dart';
import 'package:exani/theme/app_theme.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfAssetPath;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfAssetPath,
    this.title = 'Guía en PDF',
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool isDownloading = false;
  double progress = 0.0;
  bool downloadComplete = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() async {
    // Skip interstitial for Pro users
    if (PurchaseService().isProUser) return;
    _interstitialAd = await AdMobService.createInterstitialAd();
    Future.delayed(const Duration(seconds: 3), () {
      if (_interstitialAd != null && mounted) {
        AdMobService.showInterstitialAd(_interstitialAd);
      }
    });
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> _downloadPdf() async {
    setState(() {
      isDownloading = true;
      progress = 0.0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = widget.pdfAssetPath.split('/').last;
      final filePath = "${dir.path}/$fileName";

      // Copy from asset to downloads directory
      final byteData = await DefaultAssetBundle.of(
        context,
      ).load(widget.pdfAssetPath);
      final bytes = byteData.buffer.asUint8List();
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Simulate progress for UX
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (mounted) setState(() => progress = i / 100);
      }

      setState(() {
        isDownloading = false;
        downloadComplete = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  '¡Descarga completada!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      OpenFilex.open(filePath);
    } catch (e) {
      setState(() => isDownloading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text('Error al descargar: $e')),
              ],
            ),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isDownloading)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  color: AppColors.primary,
                  backgroundColor: AppColors.progressTrack,
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    downloadComplete
                        ? Icons.download_done_rounded
                        : Icons.download_rounded,
                    key: ValueKey(downloadComplete),
                    color:
                        downloadComplete
                            ? AppColors.primary
                            : AppColors.textPrimary,
                  ),
                ),
                onPressed: _downloadPdf,
              ),
            ),
        ],
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: SfPdfViewer.asset(widget.pdfAssetPath),
      ),
    );
  }
}
