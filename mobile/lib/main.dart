import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/referendum_list_screen.dart';
import 'screens/vote_screen.dart';
import 'screens/vote_receipt_screen.dart';
import 'services/session_service.dart';
import 'services/api_client.dart';

void main() {
  runApp(const CivicVoteApp());
}

class CivicVoteApp extends StatelessWidget {
  const CivicVoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionService()),
        Provider(create: (_) => ApiClient()),
      ],
      child: MaterialApp(
        title: 'CivicVote',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (context) => const LoginScreen(),
          ReferendumListScreen.routeName: (context) => const ReferendumListScreen(),
          VoteScreen.routeName: (context) => const VoteScreen(),
          VoteReceiptScreen.routeName: (context) => const VoteReceiptScreen(),
        },
      ),
    );
  }
}
