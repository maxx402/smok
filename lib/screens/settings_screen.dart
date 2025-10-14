import 'dart:io';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';
import '../models/user_settings.dart';
import '../models/user_feedback.dart';
import '../utils/enable65_helper.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserSettings? _userSettings;
  bool _isLoading = false;
  bool _isSubmittingFeedback = false;

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _dailyExpenseController = TextEditingController();
  final TextEditingController _dailyCigarettesController =
      TextEditingController();
  final TextEditingController _smokingYearsController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _dailyExpenseController.dispose();
    _dailyCigarettesController.dispose();
    _smokingYearsController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadUserSettings() async {
    final settings = await StorageService().getUserSettings();
    if (mounted) {
      setState(() {
        _userSettings = settings;
        _nicknameController.text = settings.nickname ?? '';
        _dailyExpenseController.text = settings.dailyExpense.toString();
        _dailyCigarettesController.text = settings.dailyCigarettes.toString();
        _smokingYearsController.text = settings.smokingYears.toString();
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_userSettings == null) return;

    setState(() => _isLoading = true);

    final updatedSettings = _userSettings!.copyWith(
      nickname: _nicknameController.text.isNotEmpty
          ? _nicknameController.text
          : null,
      dailyExpense:
          double.tryParse(_dailyExpenseController.text) ??
          _userSettings!.dailyExpense,
      dailyCigarettes:
          int.tryParse(_dailyCigarettesController.text) ??
          _userSettings!.dailyCigarettes,
      smokingYears:
          int.tryParse(_smokingYearsController.text) ??
          _userSettings!.smokingYears,
    );

    await StorageService().saveUserSettings(updatedSettings);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _userSettings = updatedSettings;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).save),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _submitFeedback() async {
    final l10n = AppLocalizations.of(context);
    final content = _feedbackController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.feedbackEmptyError),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmittingFeedback = true);

    final shouldEnable65 = containsEnable65Trigger(content);

    try {
      await StorageService().saveUserFeedback(
        UserFeedbackEntry(content: content),
      );

      if (shouldEnable65) {
        await StorageService().setEnable65(true);
      }

      if (!mounted) return;

      setState(() => _isSubmittingFeedback = false);
      _feedbackController.clear();

      if (shouldEnable65) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(l10n.feedbackEnable65DialogTitle),
              content: Text(l10n.feedbackEnable65DialogMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: Text(l10n.feedbackEnable65Confirm),
                ),
              ],
            );
          },
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.feedbackSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _isSubmittingFeedback = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.feedbackFailure),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (_userSettings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.settingsTab,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton(
              onPressed: _isLoading ? null : _saveSettings,
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.save,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.colorScheme.primary.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                l10n.personalInfo,
                [
                  _buildTextField(
                    controller: _nicknameController,
                    label: l10n.nickname,
                    hint: '输入昵称',
                    prefixIcon: Icons.person_outline,
                  ),
                ],
                theme,
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 24),
              _buildSection(
                l10n.smokingInfo,
                [
                  _buildTextField(
                    controller: _dailyExpenseController,
                    label: l10n.dailyExpense,
                    hint: '20.0',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _dailyCigarettesController,
                    label: l10n.dailyCigarettes,
                    hint: '20',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.smoking_rooms_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _smokingYearsController,
                    label: l10n.smokingYears,
                    hint: '1',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.calendar_today_outlined,
                  ),
                ],
                theme,
                icon: Icons.analytics_rounded,
              ),
              const SizedBox(height: 24),
              _buildSection(
                l10n.notifications,
                [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Opacity(
                      opacity: 0.5,
                      child: SwitchListTile(
                        title: Row(
                          children: [
                            Text(
                              l10n.enableNotifications,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                '正在开发中',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '接收戒烟提醒和鼓励消息',
                          style: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                        value: false,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: null,
                      ),
                    ),
                  ),
                ],
                theme,
                icon: Icons.notifications_active_rounded,
              ),
              const SizedBox(height: 24),
              _buildSection(
                l10n.feedbackSectionTitle,
                [
                  Text(
                    l10n.feedbackDescription,
                    style: TextStyle(
                      color: Colors.grey.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeedbackField(hint: l10n.feedbackPlaceholder),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSubmittingFeedback ? null : _submitFeedback,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isSubmittingFeedback
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              l10n.submitFeedback,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
                theme,
                icon: Icons.feedback_rounded,
              ),
              const SizedBox(height: 24),
              _buildSection(
                '关于',
                [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.policy_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text(
                        '隐私政策',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '查看我们如何保护您的隐私',
                        style: TextStyle(
                          color: Colors.grey.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                theme,
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Widget> children,
    ThemeData theme, {
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: Colors.grey.withValues(alpha: 0.6),
                  size: 20,
                )
              : null,
          labelStyle: TextStyle(
            color: Colors.grey.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: prefixIcon != null ? 12 : 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackField({required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: _feedbackController,
        minLines: 3,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
