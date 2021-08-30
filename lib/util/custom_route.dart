import 'package:flutter/material.dart';
import 'package:shopit/presentation/navigation/routes.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.name == AppRoute.ROOT) {
      return child;
    }

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class CustomRouteTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings.name == AppRoute.ROOT) {
      return child;
    }

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
