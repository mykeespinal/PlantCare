import 'dart:typed_data';

import 'package:image/image.dart' as img;

Uint8List compressRecipeImage(
  Uint8List input, {
  int maxBytes = 700 * 1024,
  int maxDimension = 1200,
}) {
  final decoded = img.decodeImage(input);
  if (decoded == null) {
    throw const FormatException(
      'El archivo seleccionado no es una imagen válida.',
    );
  }

  var width = decoded.width;
  var height = decoded.height;
  final scale = maxDimension / (width > height ? width : height);
  if (scale < 1) {
    width = (width * scale).round();
    height = (height * scale).round();
  }

  while (true) {
    final resized = width == decoded.width && height == decoded.height
        ? decoded
        : img.copyResize(
            decoded,
            width: width,
            height: height,
            interpolation: img.Interpolation.average,
          );
    for (final quality in [82, 72, 62, 52, 42, 32]) {
      final compressed = img.encodeJpg(resized, quality: quality);
      if (compressed.lengthInBytes <= maxBytes) return compressed;
    }
    if (width <= 320 && height <= 320) {
      throw const FormatException(
        'No se pudo comprimir la imagen por debajo de 700 KB. '
        'Selecciona una imagen más pequeña.',
      );
    }
    width = (width * 0.75).round().clamp(1, width).toInt();
    height = (height * 0.75).round().clamp(1, height).toInt();
  }
}
