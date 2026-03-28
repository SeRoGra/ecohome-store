import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _userCtrl   = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _loading     = false;
  bool _obscure     = true;
  String? _errorMsg;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMsg = null; });
    try {
      await context.read<AuthProvider>().login(
        _userCtrl.text.trim(),
        _passCtrl.text,
      );
    } catch (e) {
      setState(() { _errorMsg = 'Usuario o contraseña incorrectos'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2ECC71).withOpacity(.3)),
                  ),
                  child: const Icon(Icons.eco, color: Color(0xFF2ECC71), size: 36),
                ),
                const SizedBox(height: 20),
                const Text(
                  'EcoHome Store',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ingresa con tu cuenta',
                  style: TextStyle(color: Color(0xFF8B949E), fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF30363D)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_errorMsg != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xffff454510),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xffff454530)),
                            ),
                            child: Text(
                              _errorMsg!,
                              style: const TextStyle(color: Color(0xFFFF7171), fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildField(
                          controller: _userCtrl,
                          label: 'Usuario',
                          hint: 'ventas_admin',
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: _passCtrl,
                          label: 'Contraseña',
                          hint: '••••••••',
                          obscure: _obscure,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF8B949E),
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: const Color(0xFF0D1117),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D1117)),
                                )
                              : const Text('Iniciar sesión'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Cuentas de prueba: ventas_admin / logistica_op / soporte_01\nContraseña: password123',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8B949E), fontSize: 11),
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
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFC9D1D9), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Color(0xFFC9D1D9), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF8B949E)),
            filled: true,
            fillColor: const Color(0xFF0D1117),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF30363D)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF30363D)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2ECC71)),
            ),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
