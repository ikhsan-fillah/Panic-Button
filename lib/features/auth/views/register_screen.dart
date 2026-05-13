import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  final AuthController _controller = Get.find();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Akun Baru')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Isi data dirimu',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                const Text('Data ini akan digunakan untuk identifikasi laporan',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 28),
                _buildField(controller: _nameCtrl, label: 'Nama Lengkap', icon: Icons.person_outline,
                    validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null),
                const SizedBox(height: 14),
                _buildField(controller: _emailCtrl, label: 'Email', icon: Icons.email_outlined,
                    type: TextInputType.emailAddress,
                    validator: (v) => !v!.contains('@') ? 'Email tidak valid' : null),
                const SizedBox(height: 14),
                _buildField(controller: _phoneCtrl, label: 'Nomor Telepon', icon: Icons.phone_outlined,
                    type: TextInputType.phone,
                    validator: (v) => v!.length < 10 ? 'Nomor tidak valid' : null),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppTheme.textMuted),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v!.length < 6 ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password',
                    prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textMuted),
                  ),
                  validator: (v) => v != _passCtrl.text ? 'Password tidak cocok' : null,
                ),
                const SizedBox(height: 28),
                Obx(() => _controller.errorMessage.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_controller.errorMessage.value,
                            style: const TextStyle(color: AppTheme.danger, fontSize: 13)))
                    : const SizedBox.shrink()),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    onPressed: _controller.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _controller.register(
                                name: _nameCtrl.text.trim(),
                                email: _emailCtrl.text.trim(),
                                password: _passCtrl.text,
                                phone: _phoneCtrl.text.trim(),
                              );
                            }
                          },
                    child: _controller.isLoading.value
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Daftar'),
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textMuted),
      ),
      validator: validator,
    );
  }
}
