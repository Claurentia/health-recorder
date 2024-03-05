import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './auth_gate.dart';

class LeaderboardPage extends StatelessWidget {

  Widget LeaderboardRank() {
    return Center(
      child: Text('Welcome to the Leaderboard!'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LeaderboardRank();
        } else {
          return Center(
            child: ElevatedButton(
              child: Text("Sign In to View Leaderboard"),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AuthGate()),
                );
              },
            ),
          );
        }
      },
    );
  }
}