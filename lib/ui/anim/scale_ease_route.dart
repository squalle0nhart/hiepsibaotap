import 'package:flutter/material.dart';

class ScaleEaseRoute extends PageRouteBuilder {
  final Widget page;
  ScaleEaseRoute({this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
    new ScaleTransition(
        scale: new Tween<double>(
          begin: 1.5,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Interval(
              0.50,
              1.00,
              curve: Curves.easeIn,
            ),
          ),
        ),
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Interval(
                0.00,
                0.50,
                curve: Curves.linear,
              ),
            ),
          ),
          child: child,
        )),
  );
}