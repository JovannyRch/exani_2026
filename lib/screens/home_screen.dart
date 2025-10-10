import 'package:examen_vial_edomex_app_2025/const/const.dart';
import 'package:examen_vial_edomex_app_2025/data/data.dart';
import 'package:examen_vial_edomex_app_2025/screens/exam_screen.dart';
import 'package:examen_vial_edomex_app_2025/screens/guide_screen.dart';
import 'package:examen_vial_edomex_app_2025/screens/pdf_viewer_screen.dart';
import 'package:examen_vial_edomex_app_2025/services/admob_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdMobService.createBannerAd();
    _bannerAd!.load().then((_) {
      setState(() {
        _isBannerAdReady = true;
      });
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "Examen Víal Edomex",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(context, "Guía", Icons.menu_book, Colors.blue, () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GuideScreen(allQuestions: questions),
                      ),
                    );
                  }),
                  _buildCard(context, "Examen", Icons.quiz, Colors.green, () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ExamScreen(allQuestions: questions),
                      ),
                    );
                  }),
                  _buildCard(
                    context,
                    "Descargar guía en PDF",
                    Icons.picture_as_pdf,
                    Colors.red,
                    () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PdfViewerScreen(pdfUrl: PDF_URL),
                        ),
                      );
                    },
                  ),
                  /* _buildCard(context, "Progreso", Icons.bar_chart, Colors.orange, () {
                    // Navegar a Estadísticas
                  }),
                  _buildCard(context, "Ajustes", Icons.settings, Colors.grey, () {
                    // Navegar a Configuración
                  }), */
                ],
              ),
            ),
          ),
          // Banner publicitario
          if (_isBannerAdReady && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
