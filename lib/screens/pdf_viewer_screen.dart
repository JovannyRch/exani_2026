import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:examen_vial_edomex_app_2025/services/admob_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerScreen({super.key, required this.pdfUrl});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool isDownloading = false;
  double progress = 0.0;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() async {
    _interstitialAd = await AdMobService.createInterstitialAd();
    // Mostrar el anuncio intersticial después de un breve retraso
    Future.delayed(const Duration(seconds: 3), () {
      print("Mostrando intersticial");
      print(_interstitialAd);
      print(mounted);
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
      final filePath = "${dir.path}/guia_manejo.pdf";

      await Dio().download(
        widget.pdfUrl,
        filePath,
        onReceiveProgress: (count, total) {
          setState(() {
            progress = count / total;
          });
        },
      );

      setState(() {
        isDownloading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Descarga completada")));

      OpenFilex.open(filePath);
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al descargar: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Guía de estudio"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isDownloading)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadPdf,
            ),
          if (isDownloading)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircularProgressIndicator(
                value: progress,
                color: Colors.white,
              ),
            ),
        ],
      ),
      body: SfPdfViewer.asset("assets/files/guia_manejo.pdf"),
    );
  }
}
