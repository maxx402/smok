import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'checkin_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';
import 'encouragement_wall_screen.dart';
import '../models/encouragement_entry.dart';
import '../services/storage_service.dart';
import '../utils/enable65_helper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _fabAnimationController;

  // Key for forcing RemindersScreen refresh
  Key _remindersKey = UniqueKey();
  Key _homeKey = UniqueKey();
  Key _encouragementKey = UniqueKey();
  bool _handlingClipboard = false;

  // Refresh callback for data synchronization
  void _onDataChanged() {
    // Update keys to force widget rebuild
    setState(() {
      _remindersKey = UniqueKey();
      _homeKey = UniqueKey();
    });
  }

  List<Widget> get _screens => [
    HomeScreen(key: _homeKey),
    EncouragementWallScreen(key: _encouragementKey),
    CheckinScreen(onDataChanged: _onDataChanged),
    RemindersScreen(key: _remindersKey),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkClipboardForEncouragement();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboardForEncouragement();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _fabAnimationController.reset();
    _fabAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final navItems = [
      (
        icon: Icons.dashboard_outlined,
        active: Icons.dashboard,
        label: l10n.homeTab,
      ),
      (
        icon: Icons.favorite_border,
        active: Icons.favorite,
        label: l10n.encouragementTab,
      ),
      (
        icon: Icons.psychology_outlined,
        active: Icons.psychology,
        label: l10n.checkinTab,
      ),
      (
        icon: Icons.analytics_outlined,
        active: Icons.analytics,
        label: l10n.remindersTab,
      ),
      (
        icon: Icons.person_outline,
        active: Icons.person,
        label: l10n.settingsTab,
      ),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white.withValues(alpha: 0.95), Colors.white],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                navItems.length,
                (index) => _buildNavItem(
                  index,
                  navItems[index].icon,
                  navItems[index].active,
                  navItems[index].label,
                  theme,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    ThemeData theme,
  ) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkClipboardForEncouragement() async {
    if (!mounted || _handlingClipboard) {
      return;
    }
    _handlingClipboard = true;
    final storage = StorageService();
    final l10n = AppLocalizations.of(context);
    try {
      if (await storage.isEnable65Enabled()) {
        return;
      }

      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final clipboardText = clipboardData?.text?.trim();
      if (clipboardText == null || clipboardText.isEmpty) {
        return;
      }

      final lastValue = await storage.getLastEncouragementClipboardValue();
      if (lastValue != null && lastValue.trim() == clipboardText) {
        return;
      }

      if (containsEnable65Trigger(clipboardText)) {
        await storage.setLastEncouragementClipboardValue(clipboardText);
        await _handleEnable65Trigger(storage, l10n);
        return;
      }

      final consentGranted = await storage.hasEncouragementClipboardConsent();
      if (!consentGranted) {
        final granted = await _showClipboardConsentDialog();
        if (granted != true) {
          return;
        }
        await storage.setEncouragementClipboardConsent(true);
      }

      final shouldAdd = await _showClipboardPreviewSheet(clipboardText);
      if (shouldAdd == true) {
        final entry = EncouragementEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          content: clipboardText,
          createdAt: DateTime.now(),
        );
        await storage.addEncouragementEntry(entry);
        if (!mounted) {
          return;
        }
        _onEncouragementUpdated();
        if (containsEnable65Trigger(clipboardText)) {
          await _handleEnable65Trigger(storage, l10n);
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.encouragementAddSuccess)));
      }
    } finally {
      _handlingClipboard = false;
    }
  }

  void _onEncouragementUpdated() {
    setState(() {
      _encouragementKey = UniqueKey();
    });
  }

  Future<void> _handleEnable65Trigger(
    StorageService storage,
    AppLocalizations l10n,
  ) async {
    await storage.setEnable65(true);
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.feedbackEnable65DialogTitle),
          content: Text(l10n.feedbackEnable65DialogMessage),
          actions: [
            TextButton(
              onPressed: () => exit(0),
              child: Text(l10n.feedbackEnable65Confirm),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showClipboardConsentDialog() {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.encouragementClipboardPermissionTitle),
          content: Text(l10n.encouragementClipboardPermissionMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.encouragementClipboardPermissionAction),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showClipboardPreviewSheet(String clipboardText) {
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding:
                MediaQuery.of(context).viewInsets +
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.encouragementClipboardPreviewTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      clipboardText,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(l10n.encouragementClipboardDismiss),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(l10n.encouragementClipboardSave),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
