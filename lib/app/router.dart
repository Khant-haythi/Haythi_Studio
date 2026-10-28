import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../features/inventory/presentation/pages/inventory_screen.dart';
import '../features/orders/presentation/pages/orders_screen.dart';
import '../features/settings/presentation/pages/more_screen.dart';
import '../features/settings/presentation/pages/settings_screen.dart';
import 'navigation/main_shell.dart';

abstract final class AppRoutes {
  static const home = '/home';
  static const inventory = '/inventory';
  static const orders = '/orders';
  static const more = '/more';
  static const settings = '/more/settings';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.inventory,
              builder: (context, state) => const InventoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.orders,
              builder: (context, state) => const OrdersScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.more,
              builder: (context, state) => const MoreScreen(),
              routes: [
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
