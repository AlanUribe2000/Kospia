import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/screens/home_screen.dart';

/// Pantalla de arranque que reproduce el video de intro (la animacion del logo
/// armandose) desde el frame 0. Al terminar el video, o si falla la carga,
/// navega automaticamente a la pantalla principal.
///
/// El fondo es el lila de marca, igual que el splash nativo, para que el
/// arranque se perciba como una sola pieza continua: lila -> video -> app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset('assets/videos/Intro.mp4');
    _controller = controller;
    controller.addListener(_checkVideoFinished);

    try {
      await controller.initialize();
      if (!mounted) return;
      await controller.setLooping(false);
      // Arranca la animacion apenas el video esta listo, desde el frame 0.
      await controller.play();
      setState(() {});
    } catch (_) {
      // Si el video no se puede cargar, continuar directo a la app.
      _goToHome();
    }
  }

  void _checkVideoFinished() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;
    final finished =
        duration > Duration.zero &&
        position >= duration &&
        !controller.value.isPlaying;

    if (finished) _goToHome();
  }

  void _goToHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  void dispose() {
    _controller?.removeListener(_checkVideoFinished);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final videoReady = controller != null && controller.value.isInitialized;

    // Fondo violeta constante durante todo el splash: mismo tono que el splash
    // nativo (segundo 0). Al no cambiar de color ni mostrar una flor extra
    // antes del video, no hay saltos de color ni de tamano: el video aparece
    // sobre el mismo violeta y la transicion se percibe continua.
    return GestureDetector(
      // Permite saltar la intro tocando la pantalla.
      onTap: _goToHome,
      child: Container(
        color: AppColors.brandViolet,
        alignment: Alignment.center,
        child: AnimatedOpacity(
          // El video hace fade-in suave cuando esta listo; hasta entonces solo
          // se ve el violeta, identico al splash nativo.
          opacity: videoReady ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: videoReady
              // Video cuadrado (1440x1440): AspectRatio (equivale a
              // BoxFit.contain) lo muestra completo y sin deformar.
              ? AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
