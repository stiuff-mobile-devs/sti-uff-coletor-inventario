import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget page;
  final bool? reverse;

  CustomPageRoute({required this.page, this.reverse = false})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final begin = (reverse ?? false)
                ? const Offset(-1.0, 0.0)
                : const Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}
