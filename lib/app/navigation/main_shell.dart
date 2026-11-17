import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  int get _selectedNavigationIndex {
    return switch (navigationShell.currentIndex) {
      0 => 0,
      1 => 1,
      2 => 3,
      3 => 4,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _CharmNavigationBar(
        selectedIndex: _selectedNavigationIndex,
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline, size: 32),
            selectedIcon: Icon(Icons.add_circle, size: 32),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            label: 'More',
          ),
        ],
      ),
    );
  }

  void _onDestinationSelected(BuildContext context, int navigationIndex) {
    if (navigationIndex == 2) {
      _showAddMenu(context);
      return;
    }

    final branchIndex =
        navigationIndex > 2 ? navigationIndex - 1 : navigationIndex;

    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Wrap(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: Text(
                    'What would you like to add?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                _AddMenuTile(
                  icon: Icons.diamond_outlined,
                  title: 'Add Material',
                  onTap: () {
                    final router = GoRouter.of(context);
                    Navigator.pop(context);
                    router.push('/materials/new');
                  },
                ),
                _AddMenuTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Add Product',
                  onTap: () {
                    final router = GoRouter.of(context);
                    Navigator.pop(context);
                    router.push('/products/new');
                  },
                ),
                _AddMenuTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Create Order',
                  onTap: () => Navigator.pop(context),
                ),
                _AddMenuTile(
                  icon: Icons.person_add_outlined,
                  title: 'Add Customer',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CharmNavigationBar extends StatelessWidget {
  const _CharmNavigationBar(
      {required this.selectedIndex,
      required this.onDestinationSelected,
      required this.destinations});

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = Duration(milliseconds: reduceMotion ? 0 : 300);
    final pink = dark ? const Color(0xFFE3A9B6) : const Color(0xFF8F4B5C);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF30252F) : const Color(0xFFFFF0F4),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
              color: dark ? const Color(0xFF59404F) : const Color(0xFFFFDCE7)),
          boxShadow: [
            BoxShadow(
                color: pink.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
            children: List.generate(destinations.length, (index) {
          final item = destinations[index];
          final selected = selectedIndex == index;
          final add = index == 2;
          return Expanded(
              child: Semantics(
            selected: selected,
            button: true,
            label: item.label,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onDestinationSelected(index),
                child: Tooltip(
                  message: item.label,
                  excludeFromSemantics: true,
                  child: ExcludeSemantics(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        AnimatedContainer(
                          duration: duration,
                          curve: Curves.easeOutCubic,
                          width: add ? 48 : 48,
                          height: add ? 44 : 32,
                          transform: Matrix4.translationValues(
                              0, add ? -4 : (selected ? -2 : 0), 0),
                          decoration: BoxDecoration(
                            gradient: add
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                        Color(0xFFA65E70),
                                        Color(0xFF8F4B5C)
                                      ])
                                : null,
                            color: add
                                ? null
                                : selected
                                    ? (dark
                                        ? const Color(0xFF60394F)
                                        : const Color(0xFFFFD9E6))
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(add ? 18 : 14),
                            boxShadow: add
                                ? [
                                    BoxShadow(
                                        color: pink.withValues(alpha: 0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4))
                                  ]
                                : null,
                          ),
                          child: AnimatedScale(
                            scale: selected ? 1.08 : 1,
                            duration: duration,
                            child: IconTheme(
                                data: IconThemeData(
                                    size: add ? 29 : 23,
                                    color: add
                                        ? Colors.white
                                        : selected
                                            ? pink
                                            : (dark
                                                ? const Color(0xFFCBB6C3)
                                                : const Color(0xFF8F7884))),
                                child: add
                                    ? item.icon
                                    : selected
                                        ? (item.selectedIcon ?? item.icon)
                                        : item.icon),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: duration,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected || add
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected || add
                                  ? pink
                                  : (dark
                                      ? const Color(0xFFCBB6C3)
                                      : const Color(0xFF8F7884))),
                          child: Text(item.label, maxLines: 1),
                        ),
                      ])),
                ),
              ),
            ),
          ));
        })),
      ),
    );
  }
}

class _AddMenuTile extends StatelessWidget {
  const _AddMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
