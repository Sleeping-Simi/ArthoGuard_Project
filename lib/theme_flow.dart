import 'package:flutter/material.dart';

class AnimatedBlueFlow extends StatefulWidget {
  final Widget child;
  const AnimatedBlueFlow({super.key, required this.child});

  @override
  State<AnimatedBlueFlow> createState() => _AnimatedBlueFlowState();
}

class _AnimatedBlueFlowState extends State<AnimatedBlueFlow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final t = _animation.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (t * 0.5), -1.0 + (t * 0.5)),
              end: Alignment(1.0 - (t * 0.5), 1.0 - (t * 0.5)),
              colors: [
                Color.lerp(const Color(0xFFF4F8FF), const Color(0xFFE0ECFF), t)!, // Very light icy blue
                Color.lerp(const Color(0xFFE0ECFF), const Color(0xFFDBEAFE), t)!, // Soft blue
                Color.lerp(const Color(0xFFDBEAFE), const Color(0xFFBFDBFE), t)!, // Gentle blue
                Color.lerp(const Color(0xFFBFDBFE), const Color(0xFFF4F8FF), t)!, // Back to white-blue
              ],
              stops: const [0.0, 0.35, 0.70, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}