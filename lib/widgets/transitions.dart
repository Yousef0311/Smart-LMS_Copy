import 'package:flutter/material.dart';

// انتقال مع تأثير التلاشي
class FadePageRoute extends PageRouteBuilder {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

// انتقال مع تأثير الانزلاق من اليمين إلى اليسار
class SlidePageRoute extends PageRouteBuilder {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

// انتقال مع تأثير التكبير
class ScalePageRoute extends PageRouteBuilder {
  final Widget page;

  ScalePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeInOut;
            var scaleTween =
                Tween(begin: 0.5, end: 1.0).chain(CurveTween(curve: curve));
            var opacityTween =
                Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

            return ScaleTransition(
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation.drive(opacityTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

// انتقال مع تدوير وتكبير للصفحة
class RotationScalePageRoute extends PageRouteBuilder {
  final Widget page;

  RotationScalePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeInOut;
            var scaleAnimation = Tween(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: curve))
                .animate(animation);
            var rotateAnimation = Tween(begin: 0.0, end: 2 * 3.14159 * 0.25)
                .chain(CurveTween(curve: curve))
                .animate(animation);

            return FadeTransition(
              opacity: animation,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(scaleAnimation.value, scaleAnimation.value)
                  ..rotateZ(rotateAnimation.value),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
}
