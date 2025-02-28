import 'package:flutter/material.dart';

import 'login_screen.dart';

class AnimatedLoginScreen extends StatefulWidget {
  const AnimatedLoginScreen({super.key});

  @override
  _AnimatedLoginScreenState createState() => _AnimatedLoginScreenState();
}

class _AnimatedLoginScreenState extends State<AnimatedLoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _backgroundAnimation = ColorTween(
            begin: Colors.blueGrey[900], end: Colors.blueGrey[700])
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundAnimation.value,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const LoginScreen(),
              ),
            ),
          ),
        );
      },
    );
  }
}
