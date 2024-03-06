import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './auth_gate.dart';
import './recording_state_provider.dart';

class LeaderboardPage extends StatelessWidget {

  Future<void> syncPoints(BuildContext context) async {
    final recordingState = Provider.of<RecordingState>(context, listen: false);
    await recordingState.syncPointsWithFirestore();
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboardData() async {
    var usersCollection = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await usersCollection.orderBy('points', descending: true).get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Widget LeaderboardRank(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchLeaderboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          final leaderboardData = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Leaderboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: leaderboardData.length > 50 ? 50 : leaderboardData.length,
                  itemBuilder: (context, index) {
                    final user = leaderboardData[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        child: Text('${index + 1}'),
                        backgroundColor: index < 3 ? Colors.yellow[700] : Colors.blue[200],
                        foregroundColor: Colors.black,
                      ),
                      title: Text(user['username'] ?? 'Anonymous'),
                      trailing: Text('${user['points']} points'),
                    );
                  },
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching leaderboard'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          syncPoints(context);
          return LeaderboardRank(context);
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