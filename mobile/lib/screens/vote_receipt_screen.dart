import 'package:flutter/material.dart';

import '../models/models.dart';

class VoteReceiptScreen extends StatelessWidget {
  const VoteReceiptScreen({super.key});

  static const routeName = '/vote-receipt';

  @override
  Widget build(BuildContext context) {
    final receipt = ModalRoute.of(context)!.settings.arguments as VoteReceiptModel?;

    return Scaffold(
      appBar: AppBar(title: const Text('Reçu de vote')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: receipt == null
            ? const Text('Aucun reçu disponible')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Votre bulletin a été enregistré.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Identifiant de vote : \n${receipt.voteId}'),
                  const SizedBox(height: 8),
                  Text('Racine Merkle : \n${receipt.merkleRoot}'),
                  const SizedBox(height: 8),
                  const Text('Chemin Merkle :'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: receipt.merklePath.length,
                      itemBuilder: (context, index) => Text(receipt.merklePath[index]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Conservez ces informations pour vérifier votre vote.'),
                ],
              ),
      ),
    );
  }
}
