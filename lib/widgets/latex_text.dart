import 'package:flutter/material.dart';

/// Widget simplificado que renderiza texto con soporte básico de fórmulas matemáticas.
///
/// Detecta expresiones matemáticas rodeadas por $ y las muestra con formato especial.
/// Para una implementación completa de LaTeX, se necesitaría una librería compatible.
///
/// Ejemplo de uso:
/// ```dart
/// LatexText(
///   'Resuelve: x² + 5x + 6 = 0',
///   style: TextStyle(fontSize: 16),
/// )
/// ```
class LatexText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const LatexText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // Convertir notación LaTeX básica a Unicode cuando sea posible
    final processedText = _processLatexToUnicode(text);

    return Text(
      processedText,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Convierte sintaxis LaTeX común a caracteres Unicode
  String _processLatexToUnicode(String input) {
    var result = input;

    // Remover delimitadores $ si existen
    result = result.replaceAll(RegExp(r'\$\$'), '');
    result = result.replaceAll(r'$', '');

    // Convertir comandos LaTeX comunes a Unicode
    final conversions = {
      // Símbolos matemáticos
      r'\times': '×',
      r'\div': '÷',
      r'\pm': '±',
      r'\approx': '≈',
      r'\neq': '≠',
      r'\leq': '≤',
      r'\geq': '≥',
      r'\pi': 'π',
      r'\alpha': 'α',
      r'\beta': 'β',
      r'\gamma': 'γ',
      r'\Delta': 'Δ',
      r'\infty': '∞',
      r'\sum': '∑',
      r'\prod': '∏',
      r'\int': '∫',

      // Fracciones simples (solo las más comunes)
      r'\frac{1}{2}': '½',
      r'\frac{1}{3}': '⅓',
      r'\frac{2}{3}': '⅔',
      r'\frac{1}{4}': '¼',
      r'\frac{3}{4}': '¾',
      r'\frac{1}{5}': '⅕',
      r'\frac{2}{5}': '⅖',
      r'\frac{3}{5}': '⅗',
      r'\frac{4}{5}': '⅘',
      r'\frac{1}{8}': '⅛',

      // Exponentes comunes
      r'^2': '²',
      r'^3': '³',
    };

    conversions.forEach((latex, unicode) {
      result = result.replaceAll(latex, unicode);
    });

    // Convertir exponentes numéricos: ^0 → ⁰, ^1 → ¹, etc.
    final superscriptMap = {
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹',
    };

    superscriptMap.forEach((digit, superscript) {
      result = result.replaceAll('^$digit', superscript);
    });

    // Convertir subíndices numéricos: _0 → ₀, _1 → ₁, etc.
    final subscriptMap = {
      '0': '₀',
      '1': '₁',
      '2': '₂',
      '3': '₃',
      '4': '₄',
      '5': '₅',
      '6': '₆',
      '7': '₇',
      '8': '₈',
      '9': '₉',
    };

    subscriptMap.forEach((digit, subscript) {
      result = result.replaceAll('_$digit', subscript);
    });

    // Convertir \text{...} simplemente removiendo el comando
    result = result.replaceAllMapped(
      RegExp(r'\\text\{([^}]+)\}'),
      (match) => match.group(1) ?? '',
    );

    // Limpiar comandos LaTeX restantes que no pudimos convertir
    // (esto es para evitar mostrar \sqrt, \frac, etc.)
    result = result.replaceAll(RegExp(r'\\[a-zA-Z]+'), '');
    result = result.replaceAll(RegExp(r'[{}]'), '');

    return result;
  }
}
