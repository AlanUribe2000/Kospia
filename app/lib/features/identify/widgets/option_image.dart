import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/powersync/powersync_config.dart';
import '../../auth/services/session_service.dart';

/// Muestra una imagen de catálogo de opción (icono de opción o foto de la
/// galería de ayuda) descargándola del backend con `GET /option-images/<id>`
/// usando el token Kospia, y cacheándola en disco para próximas aperturas.
///
/// Reutiliza el mismo patrón que [PhotoThumbnail] (SessionService +
/// http.get con Bearer + caché en getApplicationCacheDirectory()).
class OptionImage extends StatefulWidget {
  const OptionImage({
    super.key,
    required this.imageId,
    this.width = 56,
    this.height = 56,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.backgroundColor,
  });

  final String imageId;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  /// Widget a mostrar si la imagen no puede resolverse (opcional).
  final Widget? placeholder;

  /// Color de fondo neutro detrás de la imagen mientras carga o si falla.
  /// Si es null se usa [AppColors.surfaceLilac] (comportamiento original,
  /// pensado para el icono de opción). En el carrusel/visor se pasa un tono
  /// neutro para evitar que se vea el lila del tema al deslizar.
  final Color? backgroundColor;

  /// Precarga (prefetch) los bytes de la imagen en la caché del proceso sin
  /// renderizar nada, para que una visita posterior la muestre al instante
  /// (sin dejar ver el fondo mientras descarga/decodifica). Evita descargas
  /// duplicadas reutilizando la caché en memoria, la de disco y las descargas
  /// en curso. Es seguro llamarla varias veces para el mismo [imageId].
  static Future<void> prefetch(BuildContext context, String imageId) {
    return _OptionImageState._prefetch(context, imageId);
  }

  @override
  State<OptionImage> createState() => _OptionImageState();
}

class _OptionImageState extends State<OptionImage> {
  // Caché en memoria del proceso: evita re-descargar la misma imagen.
  static final Map<String, Uint8List> _memoryCache = {};

  // Descargas en curso por imageId: evita disparar la misma petición dos
  // veces (p.ej. prefetch de un vecino + render de esa misma página).
  static final Map<String, Future<Uint8List?>> _inFlight = {};

  Uint8List? _bytes;
  bool _loading = true;
  bool _failed = false;
  int _requestGeneration = 0;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(OptionImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageId != widget.imageId) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final generation = ++_requestGeneration;
    setState(() {
      _loading = true;
      _failed = false;
      _bytes = null;
    });

    final data = await _load(context, widget.imageId);
    if (!mounted || generation != _requestGeneration) return;
    setState(() {
      if (data != null) {
        _bytes = data;
      } else {
        _failed = true;
      }
      _loading = false;
    });
  }

  /// Prefetch sin estado: resuelve y cachea los bytes del [imageId] sin tocar
  /// ningún widget. Usado por [OptionImage.prefetch].
  static Future<void> _prefetch(BuildContext context, String imageId) async {
    await _load(context, imageId);
  }

  /// Resuelve los bytes de [imageId] desde (en orden) la caché en memoria, la
  /// caché en disco o el backend, deduplicando descargas en curso. Devuelve
  /// null si no se pudo obtener. Cachea el resultado en memoria y disco.
  static Future<Uint8List?> _load(BuildContext context, String imageId) {
    // 1) Caché en memoria.
    final cached = _memoryCache[imageId];
    if (cached != null) return Future.value(cached);

    // 2) Descarga/lectura en curso para este mismo id: reutilizarla.
    final existing = _inFlight[imageId];
    if (existing != null) return existing;

    // Capturar lo que necesitamos del context de forma síncrona, porque el
    // future se puede resolver cuando el widget ya no esté montado.
    final session = context.read<SessionService>();
    final future = _resolveBytes(session, imageId);
    _inFlight[imageId] = future;
    future.whenComplete(() => _inFlight.remove(imageId));
    return future;
  }

  static Future<Uint8List?> _resolveBytes(
    SessionService sessionService,
    String imageId,
  ) async {
    // 2) Caché en disco de descargas previas.
    File? cacheFile;
    try {
      cacheFile = await _cacheFileFor(imageId);
      if (await cacheFile.exists()) {
        final data = await cacheFile.readAsBytes();
        _memoryCache[imageId] = data;
        return data;
      }
    } catch (_) {
      cacheFile = null;
    }

    // 3) Descarga desde el backend y cacheo.
    try {
      final session = await sessionService.loadSession();
      if (session == null) return null;

      final response = await http.get(
        Uri.parse('${PowerSyncConfig.backendUrl}/option-images/$imageId'),
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.bodyBytes;
        _memoryCache[imageId] = data;
        try {
          await cacheFile?.writeAsBytes(data, flush: true);
        } catch (_) {
          // Si falla la escritura en caché, igual devolvemos los bytes.
        }
        return data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<File> _cacheFileFor(String imageId) async {
    final dir = await getApplicationCacheDirectory();
    final folder = Directory('${dir.path}/option-images');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return File('${folder.path}/$imageId.img');
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: _buildContent(),
      ),
    );
  }

  // Fondo neutro detrás de la imagen mientras carga o si falla. En el
  // carrusel/visor se pasa un tono neutro para que no se vea el lila del tema
  // (la "franja violeta") durante el primer deslizamiento.
  Color get _bgColor => widget.backgroundColor ?? AppColors.surfaceLilac;

  Widget _buildContent() {
    if (_loading) {
      return Container(
        color: _bgColor,
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_bytes != null) {
      return Container(
        color: _bgColor,
        child: Image.memory(
          _bytes!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          // Centrar la imagen dentro de su caja (relevante con BoxFit.contain,
          // p.ej. el icono de opción en la tarjeta del cuestionario).
          alignment: Alignment.center,
          // Evita un flash de fondo al reconstruir mostrando el frame previo
          // hasta que el nuevo esté decodificado.
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    if (widget.placeholder != null) return widget.placeholder!;
    return Container(
      width: widget.width,
      height: widget.height,
      color: _bgColor,
      child: Icon(
        _failed
            ? Icons.broken_image_rounded
            : Icons.image_not_supported_rounded,
        size: 20,
        color: AppColors.textLight,
      ),
    );
  }
}
