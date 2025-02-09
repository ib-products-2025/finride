// lib/utils/animation_helper.dart

import 'package:flutter/material.dart';

class FadeSlideTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeSlideTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
  });

  @override
  State<FadeSlideTransition> createState() => _FadeSlideTransitionState();
}

class _FadeSlideTransitionState extends State<FadeSlideTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
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
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

class ScaleInTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const ScaleInTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
  });

  @override
  State<ScaleInTransition> createState() => _ScaleInTransitionState();
}

class _ScaleInTransitionState extends State<ScaleInTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

// Staggered list animation wrapper
class StaggeredListAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration delay;
  final double itemSlideDistance;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 400),
    this.delay = const Duration(milliseconds: 0),
    this.itemSlideDistance = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < children.length; i++)
          FadeSlideTransition(
            duration: itemDuration,
            delay: Duration(milliseconds: delay.inMilliseconds + (i * 100)),
            child: children[i],
          ),
      ],
    );
  }
}