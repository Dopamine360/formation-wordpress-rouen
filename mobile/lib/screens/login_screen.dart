import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/session_service.dart';
import 'referendum_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _referendumController = TextEditingController();
  final _otpController = TextEditingController();

  LoginChallenge? _challenge;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _referendumController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final api = context.read<ApiClient>();
    try {
      final challenge = await api.login(LoginPayload(
        email: _emailController.text.trim(),
        referendumId: _referendumController.text.trim(),
        clientNonce: 'client-nonce',
        signature: 'signature-placeholder',
      ));
      setState(() {
        _challenge = challenge;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_challenge == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final api = context.read<ApiClient>();
    final session = context.read<SessionService>();
    try {
      final tokens = await api.verifyOtp(VerifyOtpPayload(
        challengeId: _challenge!.challengeId,
        otpCode: _otpController.text.trim(),
        deviceInfo: {'platform': Theme.of(context).platform.name},
      ));
      session.storeTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
      session.selectReferendum(_referendumController.text.trim());
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, ReferendumListScreen.routeName);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion votant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value != null && value.contains('@') ? null : 'Email invalide',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referendumController,
                decoration: const InputDecoration(labelText: 'ID référendum'),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Champ requis',
              ),
              const SizedBox(height: 24),
              if (_challenge == null)
                FilledButton.icon(
                  onPressed: _isLoading ? null : _requestOtp,
                  icon: const Icon(Icons.lock_open),
                  label: _isLoading ? const Text('Envoi...') : const Text('Recevoir le code OTP'),
                )
              else ...[
                TextFormField(
                  controller: _otpController,
                  decoration: const InputDecoration(labelText: 'Code OTP'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _verifyOtp,
                  icon: const Icon(Icons.verified_user),
                  label: _isLoading ? const Text('Vérification...') : const Text('Valider'),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
