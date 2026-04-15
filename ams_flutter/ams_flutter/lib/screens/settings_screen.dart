// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard(context: context, title: 'System Settings', children: [
            SwitchListTile(
              value: app.darkMode,
              onChanged: (_) => app.toggleDarkMode(),
              title: const Text('Dark Mode',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: const Text('Switch between light and dark theme',
                  style: TextStyle(fontSize: 12)),
              secondary: Icon(app.darkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ]),
          const SizedBox(height: 12),
          _sectionCard(context: context, title: 'Data Overview', children: [
            ListTile(
              leading: const Icon(Icons.people_rounded),
              title: Text('${app.students.length} Students',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_rounded),
              title: Text('${app.attendanceRecords.length} Attendance Records',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ]),
          const SizedBox(height: 12),
          _sectionCard(context: context, title: 'About', children: [
            const ListTile(
              leading: Icon(Icons.school_rounded),
              title: Text('AMS – Attendance Master Scholar',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text('Version 1.0.0 · Flutter',
                  style: TextStyle(fontSize: 12)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ]),
          const SizedBox(height: 12),
          _sectionCard(
            context: context,
            title: 'Danger Zone',
            titleColor: const Color(0xFFEF4444),
            children: [
              ListTile(
                leading:
                    const Icon(Icons.restore_rounded, color: Color(0xFFEF4444)),
                title: const Text('Factory Reset',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: const Text('Restore sample data',
                    style: TextStyle(fontSize: 12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                trailing: TextButton(
                  onPressed: () => _showResetDialog(context),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444)),
                  child: const Text('Reset', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    Color? titleColor,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: titleColor ??
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Factory Reset', style: TextStyle(fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Restore all sample data. Type "RESET" to confirm.',
                  style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Type RESET',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: ctrl.text == 'RESET'
                  ? () {
                      context.read<AppProvider>().factoryReset();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('✓ Reset to factory defaults'),
                            behavior: SnackBarBehavior.floating),
                      );
                    }
                  : null,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
