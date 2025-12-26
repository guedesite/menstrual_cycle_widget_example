import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconOpacityAnimation;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartOpacityAnimation;
  late Animation<double> _screenFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    // Animation de l'icône (apparaît et reste visible jusqu'à 0.4)
    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
      ),
    );

    _iconOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    // Animation du cœur (apparaît à la fin, grandit, puis disparaît)
    _heartScaleAnimation = Tween<double>(begin: 0.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _heartOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 20.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.95, curve: Curves.linear),
      ),
    );

    // Animation de fondu final de tout l'écran
    _screenFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 200), () {
          widget.onComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B9D),
              Color(0xFFFFC3E0),
              Color(0xFFFFE5F0),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _screenFadeAnimation.value,
              child: Stack(
                children: [
                  // Icône principale
                  Center(
                    child: Opacity(
                      opacity: _iconOpacityAnimation.value,
                      child: Transform.scale(
                        scale: _iconScaleAnimation.value,
                        child: Container(
                          width: 200,
                          height: 200,

                          child: ClipRRect(
                            child: Image.asset(
                              'assets/icon/icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Cœur animé par-dessus
                  Center(
                    child: Opacity(
                      opacity: _heartOpacityAnimation.value,
                      child: Transform.scale(
                        scale: _heartScaleAnimation.value,
                        child: CustomPaint(
                          size: const Size(200, 200),
                          painter: HeartPainter(
                            color: Colors.white.withOpacity(0.95),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class HeartPainter extends CustomPainter {
  final Color color;

  HeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Dessiner un cœur
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, height * 0.35);

    // Courbe gauche du cœur
    path.cubicTo(
      width / 2,
      height * 0.25,
      width * 0.2,
      height * 0.1,
      width * 0.2,
      height * 0.3,
    );

    // Bas gauche du cœur
    path.cubicTo(
      width * 0.2,
      height * 0.5,
      width / 2,
      height * 0.7,
      width / 2,
      height * 0.9,
    );

    // Bas droit du cœur
    path.cubicTo(
      width / 2,
      height * 0.7,
      width * 0.8,
      height * 0.5,
      width * 0.8,
      height * 0.3,
    );

    // Courbe droite du cœur
    path.cubicTo(
      width * 0.8,
      height * 0.1,
      width / 2,
      height * 0.25,
      width / 2,
      height * 0.35,
    );

    canvas.drawPath(path, paint);

    // Ajouter une ombre douce
    final shadowPaint = Paint()
      ..color = Colors.pink.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(HeartPainter oldDelegate) => false;
}
