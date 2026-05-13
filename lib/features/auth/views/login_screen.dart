import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  final AuthController _controller = Get.find();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withOpacity(0.15),
                        border: Border.all(color: AppTheme.primary, width: 2),
                      ),
                      child: const Icon(Icons.sos_rounded, size: 36, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    const Text('Selamat Datang',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 6),
                    const Text('Masuk ke akun Panic Button kamu',
                        style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted),
                      ),
                      validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppTheme.textMuted,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => v!.length < 6 ? 'Minimal 6 karakter' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => _controller.errorMessage.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_controller.errorMessage.value,
                          style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                    )
                  : const SizedBox.shrink()),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: _controller.isLoading.value
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _controller.login(_emailCtrl.text.trim(), _passCtrl.text);
                          }
                        },
                  child: _controller.isLoading.value
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Masuk'),
                )),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.register),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Belum punya akun? ',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Daftar sekarang',
                          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
