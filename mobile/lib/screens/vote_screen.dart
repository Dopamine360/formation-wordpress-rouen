import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/session_service.dart';
import 'vote_receipt_screen.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  static const routeName = '/vote';

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  String? _selectedOption;
  bool _isSubmitting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final referendum = ModalRoute.of(context)!.settings.arguments as ReferendumSummaryModel?;
    final session = context.watch<SessionService>();
    final api = context.read<ApiClient>();

    return Scaffold(
      appBar: AppBar(title: Text(referendum?.title ?? 'Vote')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choisissez votre option :'),
            const SizedBox(height: 12),
            RadioListTile<String>(
              value: 'option_oui',
              groupValue: _selectedOption,
              title: const Text('Oui'),
              onChanged: (value) => setState(() => _selectedOption = value),
            ),
            RadioListTile<String>(
              value: 'option_non',
              groupValue: _selectedOption,
              title: const Text('Non'),
              onChanged: (value) => setState(() => _selectedOption = value),
            ),
            const Spacer(),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            FilledButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (_selectedOption == null) {
                        setState(() => _error = 'Veuillez sélectionner une option');
                        return;
                      }
                      setState(() {
                        _isSubmitting = true;
                        _error = null;
                      });
                      try {
                        final receipt = await api.submitVote(
                          session.accessToken ?? '',
                          VoteSubmitPayload(
                            referendumId: referendum?.id ?? '',
                            c1: 'ciphertext-part1',
                            c2: 'ciphertext-part2',
                            proofCommitment: 'proof',
                            merkleLeaf: 'merkle-leaf',
                            clientTimestamp: DateTime.now().toUtc().toIso8601String(),
                            nonce: 'nonce-placeholder',
                            signature: 'signature-placeholder',
                          ),
                        );
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          VoteReceiptScreen.routeName,
                          arguments: receipt,
                        );
                      } catch (e) {
                        setState(() {
                          _error = e.toString();
                        });
                      } finally {
                        setState(() {
                          _isSubmitting = false;
                        });
                      }
                    },
              icon: const Icon(Icons.send),
              label: _isSubmitting ? const Text('Envoi...') : const Text('Soumettre mon vote'),
            ),
          ],
        ),
      ),
    );
  }
}
