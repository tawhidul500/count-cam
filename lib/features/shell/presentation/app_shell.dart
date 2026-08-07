import 'dart:async';

import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/features/documents/presentation/documents_screen.dart';
import 'package:clearscan/features/folders/presentation/folders_screen.dart';
import 'package:clearscan/features/home/presentation/home_screen.dart';
import 'package:clearscan/features/scanner/presentation/scanner_screen.dart';
import 'package:clearscan/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openScanner() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const ScannerScreen(),
          fullscreenDialog: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      HomeScreen(
        onScan: _openScanner,
        onDocuments: () => _selectTab(1),
      ),
      const DocumentsScreen(),
      const FoldersScreen(),
      SettingsScreen(onGoHome: () => _selectTab(0)),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Scan a document',
        child: FloatingActionButton(
          key: const Key('scan-fab'),
          onPressed: _openScanner,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.document_scanner_outlined, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNavigation(
        selectedIndex: _selectedIndex,
        onSelected: _selectTab,
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      color: AppColors.surface,
      elevation: 12,
      shadowColor: AppColors.shadow,
      notchMargin: AppSpacing.xs,
      shape: const CircularNotchedRectangle(),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _NavigationItem(
              key: const Key('home-tab'),
              label: 'Home',
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              selected: selectedIndex == 0,
              onTap: () => onSelected(0),
            ),
          ),
          Expanded(
            child: _NavigationItem(
              key: const Key('documents-tab'),
              label: 'Documents',
              icon: Icons.description_outlined,
              selectedIcon: Icons.description_rounded,
              selected: selectedIndex == 1,
              onTap: () => onSelected(1),
            ),
          ),
          const SizedBox(width: AppSpacing.display),
          Expanded(
            child: _NavigationItem(
              key: const Key('folders-tab'),
              label: 'Folders',
              icon: Icons.folder_outlined,
              selectedIcon: Icons.folder_rounded,
              selected: selectedIndex == 2,
              onTap: () => onSelected(2),
            ),
          ),
          Expanded(
            child: _NavigationItem(
              key: const Key('settings-tab'),
              label: 'Settings',
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings_rounded,
              selected: selectedIndex == 3,
              onTap: () => onSelected(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected ? AppColors.primaryDark : AppColors.textMuted;

    return InkResponse(
      onTap: onTap,
      radius: 34,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? AppColors.primarySoft : AppColors.surface,
                borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
              ),
              child: Icon(selected ? selectedIcon : icon, color: foreground, size: 22),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
