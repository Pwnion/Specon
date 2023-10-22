import 'package:flutter/material.dart';

class AnimatedSync extends AnimatedWidget {

  final VoidCallback callback;
  final Animation<double> animation;

  const AnimatedSync(
    {Key? key,
    required this.animation,
    required this.callback}
  ): super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {

    return Transform.rotate(
      angle: animation.value,
      child: IconButton(
        icon: const Icon(Icons.sync),
        onPressed: () => callback()
      ),
    );
  }
}