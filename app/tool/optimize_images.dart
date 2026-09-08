// Optimiza las imágenes del catálogo: redimensiona a máx 1920px (lado largo)
// y recomprime a JPEG calidad 85%, manteniendo el mismo nombre de archivo.
//
// Lee de   assets/images/Catalogs/
// Escribe  assets/images/Catalogs_optimized/   (los originales quedan intactos)
//
// Uso:  dart run tool/optimize_images.dart
//
// No modifica nada del proyecto: solo genera una carpeta paralela para revisar.

import 'dart:io';
import 'package:image/image.dart' as img;

const String srcDir = 'assets/images/Catalogs';
const String dstDir = 'assets/images/Catalogs_optimized';
const int maxSide = 1920; // lado más largo en px
const int jpegQuality = 85;

Future<void> main() async {
  final src = Directory(srcDir);
  if (!src.existsSync()) {
    stderr.writeln(
      'No existe la carpeta $srcDir (¿estás corriendo desde la raíz del proyecto?)',
    );
    exitCode = 1;
    return;
  }

  final dst = Directory(dstDir);
  if (dst.existsSync()) {
    dst.deleteSync(recursive: true);
  }
  dst.createSync(recursive: true);

  int count = 0;
  int errors = 0;
  int origBytes = 0;
  int newBytes = 0;
  final sw = Stopwatch()..start();

  final files = src.listSync(recursive: true).whereType<File>().where((f) {
    final ext = f.path.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png');
  }).toList();

  stdout.writeln('Procesando ${files.length} imágenes...\n');

  for (final file in files) {
    // ruta relativa dentro de Catalogs -> misma ruta dentro de Catalogs_optimized
    final rel = file.path.substring(src.path.length + 1);
    final outPath = '${dst.path}${Platform.pathSeparator}$rel';
    final outFile = File(outPath);
    outFile.parent.createSync(recursive: true);

    final bytes = file.readAsBytesSync();
    origBytes += bytes.length;

    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        stderr.writeln('  ! No se pudo decodificar: $rel (se copia tal cual)');
        outFile.writeAsBytesSync(bytes);
        newBytes += bytes.length;
        errors++;
        continue;
      }

      img.Image resized = decoded;
      final longSide = decoded.width >= decoded.height
          ? decoded.width
          : decoded.height;
      if (longSide > maxSide) {
        if (decoded.width >= decoded.height) {
          resized = img.copyResize(
            decoded,
            width: maxSide,
            interpolation: img.Interpolation.average,
          );
        } else {
          resized = img.copyResize(
            decoded,
            height: maxSide,
            interpolation: img.Interpolation.average,
          );
        }
      }

      final encoded = img.encodeJpg(resized, quality: jpegQuality);

      // Si optimizar no reduce peso (imágenes ya chicas/comprimidas),
      // conservamos el original para no empeorar nada.
      if (encoded.length >= bytes.length) {
        outFile.writeAsBytesSync(bytes);
        newBytes += bytes.length;
        count++;
        final kb = (bytes.length / 1024).round();
        stdout.writeln('  (original)  ${kb}KB  $rel');
        continue;
      }

      outFile.writeAsBytesSync(encoded);
      newBytes += encoded.length;
      count++;

      final origKb = (bytes.length / 1024).round();
      final newKb = (encoded.length / 1024).round();
      stdout.writeln(
        '  ${resized.width}x${resized.height}  ${origKb}KB -> ${newKb}KB  $rel',
      );
    } catch (e) {
      stderr.writeln('  ! Error en $rel: $e (se copia tal cual)');
      outFile.writeAsBytesSync(bytes);
      newBytes += bytes.length;
      errors++;
    }
  }

  sw.stop();
  final origMb = (origBytes / (1024 * 1024));
  final newMb = (newBytes / (1024 * 1024));
  final saved = origMb > 0 ? (100 * (origMb - newMb) / origMb) : 0;

  stdout.writeln('\n===============================================');
  stdout.writeln('Imágenes procesadas : $count  (errores/copias: $errors)');
  stdout.writeln('Peso original       : ${origMb.toStringAsFixed(1)} MB');
  stdout.writeln('Peso optimizado     : ${newMb.toStringAsFixed(1)} MB');
  stdout.writeln('Reducción           : ${saved.toStringAsFixed(1)} %');
  stdout.writeln(
    'Tiempo              : ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(1)} s',
  );
  stdout.writeln('Salida en           : $dstDir');
  stdout.writeln('===============================================');
}
