import 'package:flutter/material.dart';
import 'package:exani/theme/app_theme.dart';
import 'package:exani/widgets/latex_text.dart';

/// Widget reutilizable para renderizar imágenes de contenido (preguntas, opciones, explicaciones).
/// Soporta tanto assets locales como URLs remotas.
class ContentImage extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final double borderRadius;
  final BoxFit fit;

  const ContentImage({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.borderRadius = 12,
    this.fit = BoxFit.contain,
  });

  bool get _isRemote =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: height ?? 250,
          maxWidth: width ?? double.infinity,
        ),
        child: _isRemote ? _buildNetworkImage() : _buildAssetImage(),
      ),
    );
  }

  Widget _buildAssetImage() {
    return Image.asset(
      imagePath,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildNetworkImage() {
    return Image.network(
      imagePath,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingPlaceholder(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildLoadingPlaceholder(ImageChunkEvent progress) {
    final percentage =
        progress.expectedTotalBytes != null
            ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
            : null;
    return Container(
      height: height ?? 120,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: AppColors.progressTrack,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: CircularProgressIndicator(
          value: percentage,
          strokeWidth: 2,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: height ?? 80,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_rounded, color: AppColors.red, size: 28),
            SizedBox(height: 4),
            Text(
              'Imagen no disponible',
              style: TextStyle(fontSize: 11, color: AppColors.red),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para renderizar una lista de imágenes (stemImages, explanationImages)
class ContentImageGallery extends StatelessWidget {
  final List<String> images;
  final double imageHeight;
  final double spacing;
  final double borderRadius;

  const ContentImageGallery({
    super.key,
    required this.images,
    this.imageHeight = 180,
    this.spacing = 12,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return Center(
        child: ContentImage(
          imagePath: images.first,
          height: imageHeight,
          borderRadius: borderRadius,
        ),
      );
    }

    // Múltiples imágenes: scroll horizontal
    return SizedBox(
      height: imageHeight + 8,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          return ContentImage(
            imagePath: images[index],
            height: imageHeight,
            width: imageHeight * 1.2,
            borderRadius: borderRadius,
          );
        },
      ),
    );
  }
}

/// Widget para renderizar una opción que puede tener imagen
class OptionContent extends StatelessWidget {
  final String text;
  final String? imagePath;
  final TextStyle? textStyle;
  final double imageHeight;

  const OptionContent({
    super.key,
    required this.text,
    this.imagePath,
    this.textStyle,
    this.imageHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    if (!hasImage) {
      return LatexText(
        text.replaceAll('[br]', '\n'),
        style:
            textStyle ??
            TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.4),
      );
    }

    // Con imagen: imagen arriba, texto abajo
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ContentImage(
          imagePath: imagePath!,
          height: imageHeight,
          borderRadius: 8,
        ),
        if (text.isNotEmpty) ...[
          const SizedBox(height: 8),
          LatexText(
            text.replaceAll('[br]', '\n'),
            style:
                textStyle ??
                TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
          ),
        ],
      ],
    );
  }
}
