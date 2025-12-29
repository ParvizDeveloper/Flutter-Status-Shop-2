import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../base/local_storage.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../base/translation.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _uid;

  bool _editing = false;
  bool _saving = false;
  bool _loading = true;

  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _cityController = TextEditingController();

  String _email = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // ================= AUTH-SAFE LOAD =================

  Future<void> _loadUserData() async {
    if (!_loading) return;

    try {
      _uid = await ApiService.uid();

      if (_uid == null) {
        await _forceLogout();
        return;
      }

      final data = await ApiService.getUser(_uid!);

      if (data == null || data.isEmpty) {
        await _forceLogout();
        return;
      }

      if (!mounted) return;

      setState(() {
        _nameController.text = data['name'] ?? '';
        _companyController.text = data['company'] ?? '';
        _positionController.text = data['position'] ?? '';
        _cityController.text = data['city'] ?? '';
        _email = data['email'] ?? '';
        _phone = data['phone'] ?? '';
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Profile fatal auth error: $e');
      await _forceLogout();
    }
  }

  // ================= FORCE LOGOUT =================

  Future<void> _forceLogout() async {
    await ApiService.logout();
    await LocalStorage.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  // ================= SAVE =================

  Future<void> _saveChanges() async {
    if (_uid == null) return;

    setState(() => _saving = true);

    final ok = await ApiService.updateUser(_uid!, {
      'name': _nameController.text.trim(),
      'company': _companyController.text.trim(),
      'position': _positionController.text.trim(),
      'city': _cityController.text.trim(),
    });

    if (!ok) {
      await _forceLogout();
      return;
    }

    if (!mounted) return;

    setState(() {
      _editing = false;
      _saving = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(tr(context, 'saved'))));
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFE53935);

    return Consumer<LanguageProvider>(
      builder: (context, lp, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: true,
            title: Text(
              tr(context, 'profile'),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: redColor),
                )
              : _content(context),
        );
      },
    );
  }

  Widget _content(BuildContext context) {
    const redColor = Color(0xFFE53935);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ================= TOP =================
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage:
                    AssetImage('assets/images/profile_avatar.png'),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text
                          : tr(context, 'user'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.logout, color: Colors.grey),
                onPressed: _forceLogout,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _sectionTitle(tr(context, 'personal_data')),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _editableField(tr(context, 'name'), _nameController),
              _editableField(tr(context, 'company'), _companyController),
              _editableField(tr(context, 'position'), _positionController),
              _editableField(tr(context, 'city'), _cityController),
              _readonlyField(tr(context, 'phone'), _phone),
              _readonlyField('Email', _email),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (_editing)
          _saving
              ? const Center(
                  child: CircularProgressIndicator(color: redColor),
                )
              : ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: redColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(tr(context, 'save')),
                ),

        const SizedBox(height: 24),

        _sectionTitle(tr(context, 'settings')),

        _settingItem(
          Icons.shopping_bag_outlined,
          tr(context, 'my_orders'),
          onTap: () => Navigator.pushNamed(context, '/my_orders'),
        ),

        // ✅ НАШИ ФИЛИАЛЫ
        _settingItem(
          Icons.location_on_outlined,
          tr(context, 'locations'),
          onTap: () => Navigator.pushNamed(context, '/locations'),
        ),

        _settingItem(
          Icons.lock_outline,
          tr(context, 'privacy'),
        ),

        _settingItem(
          Icons.language_outlined,
          tr(context, 'language'),
          onTap: _showLanguageModal,
        ),

        _settingItem(
          Icons.help_outline,
          tr(context, 'help'),
        ),
      ],
    );
  }

  // ================= UI HELPERS =================

  void _showLanguageModal() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final lp = Provider.of<LanguageProvider>(context, listen: false);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Русский'),
              onTap: () {
                lp.setLocale('ru');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("O'zbekcha"),
              onTap: () {
                lp.setLocale('uz');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                lp.setLocale('en');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      );

  Widget _editableField(
      String label, TextEditingController controller) {
    return ListTile(
      title: Text(label),
      subtitle: _editing
          ? TextField(controller: controller)
          : Text(controller.text.isNotEmpty ? controller.text : '—'),
      trailing: !_editing
          ? IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.redAccent),
              onPressed: () => setState(() => _editing = true),
            )
          : null,
    );
  }

  Widget _readonlyField(String label, String value) => ListTile(
        title: Text(label),
        subtitle: Text(value),
        enabled: false,
      );

  Widget _settingItem(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) =>
      Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(icon, color: Colors.redAccent),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      );
}
