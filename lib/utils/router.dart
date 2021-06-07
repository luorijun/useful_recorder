import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouteItem {
  RouteItem({required this.name, required this.widget, List<RouteItem>? children}) {
    this.children = children ?? [];
  }

  final String name;
  final Widget Function(BuildContext context) widget;
  late final List<RouteItem> children;

  @override
  String toString() {
    return 'RouteItem{name: $name, widget: $widget, children: $children}';
  }
}

class RouterState extends ChangeNotifier {
  RouterState();

  late List<RouteItem> routes;
  late GlobalKey<NavigatorState> key;
  RouteItem? current;
  RouterState? _child;

  RouterState? get child => _child;

  set child(value) {
    _child = value;
    notifyListeners();
  }

  @override
  String toString() {
    return 'RouterState{routes: $routes, current: $current}';
  }
}

class RouterRoot extends StatelessWidget {
  const RouterRoot({
    Key? key,
    required this.child,
    required this.routes,
  }) : super(key: key);

  final List<RouteItem> routes;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = RouterState();
    state.routes = routes;

    return ChangeNotifierProvider(
      create: (context) => state,
      child: child,
    );
  }
}

class RouterNode extends StatelessWidget {
  const RouterNode(this.name, {Key? key}) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    final parent = context.read<RouterState>();
    final routes = parent.routes;

    final navigator = GlobalKey<NavigatorState>();
    return Navigator(
      key: navigator,
      onGenerateRoute: (setting) {
        if (routes.isEmpty) {
          return MaterialPageRoute(builder: (context) {
            return Container(
              color: Colors.black,
              child: const Text("空路由"),
            );
          });
        }

        final route = routes.firstWhere(
          (route) => route.name == setting.name,
          orElse: () => routes.first,
        );

        final state = RouterState();
        state.key = navigator;
        state.current = route;
        state.routes = route.children;

        Future.microtask(() {
          parent.child = state;
        });

        return MaterialPageRoute(builder: (context) {
          return ChangeNotifierProvider(
            create: (_) => state,
            child: route.widget(context),
          );
        });
      },
    );
  }
}
