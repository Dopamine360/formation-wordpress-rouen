import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/session_service.dart';
import 'vote_screen.dart';

class ReferendumListScreen extends StatefulWidget {
  const ReferendumListScreen({super.key});

  static const routeName = '/referendums';

  @override
  State<ReferendumListScreen> createState() => _ReferendumListScreenState();
}

class _ReferendumListScreenState extends State<ReferendumListScreen> {
  late Future<List<ReferendumSummaryModel>> _futureReferendums;

  @override
  void initState() {
    super.initState();
    _futureReferendums = _loadReferendums();
  }

  Future<List<ReferendumSummaryModel>> _loadReferendums() {
    final session = context.read<SessionService>();
    final api = context.read<ApiClient>();
    return api.listReferendums(session.accessToken ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Référendums'),
      ),
      body: FutureBuilder<List<ReferendumSummaryModel>>(
        future: _futureReferendums,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ' + snapshot.error.toString()));
          }
          final referendums = snapshot.data ?? [];
          if (referendums.isEmpty) {
            return const Center(child: Text('Aucun scrutin disponible'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: referendums.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final referendum = referendums[index];
              return Card(
                child: ListTile(
                  title: Text(referendum.title),
                  subtitle: Text('Statut: ' + referendum.status),
                  trailing: const Icon(Icons.how_to_vote),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      VoteScreen.routeName,
                      arguments: referendum,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
