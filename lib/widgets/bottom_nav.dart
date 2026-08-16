import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pet_provider.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/activities_screen.dart';
import '../screens/history_screen.dart';
import '../screens/garden_screen.dart';

class AppShell extends StatefulWidget {
  final int initialIndex;
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  static const _screens = [
    HomeScreen(),
    ActivitiesScreen(),
    HistoryScreen(),
    GardenScreen(),
  ];

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.self_improvement_rounded, label: 'Activities'),
    (icon: Icons.auto_stories_rounded, label: 'History'),
    (icon: Icons.park_rounded, label: 'Garden'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.headerBg,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length, (i) {
              final selected = i == _index;
              final item = _items[i];
              return GestureDetector(
                onTap: () => setState(() => _index = i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.mint : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        size: 22,
                        color: selected ? AppColors.textDark : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? AppColors.textDark : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Shared top app bar used on every tab.
PreferredSizeWidget buildMelloAppBar(BuildContext context) {
  final provider = context.watch<PetProvider>();
  final petName = provider.pet?.petName ?? 'My Pet';
  
  return AppBar(
    titleSpacing: 16,
    title: Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.mintSoft,
          child: Icon(Icons.pets_rounded, color: AppColors.mintDark, size: 20),
        ),
        const SizedBox(width: 10),
        const Text(
          "Mello",
          style: TextStyle(
            color: AppColors.mintDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ],
    ),
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.settings_rounded),
      ),
    ],
  );
}
