import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './auth_gate.dart';
import './recording_state_provider.dart';
import './terms_conditions.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late Future<List<Map<String, dynamic>>> _leaderboardData;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _leaderboardData = fetchLeaderboardData();
  }

  Future<void> syncPoints(BuildContext context) async {
    final recordingState = Provider.of<RecordingState>(context, listen: false);
    await recordingState.syncPointsWithFirestore();
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboardData() async {
    var usersCollection = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await usersCollection.orderBy('points', descending: true).get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Are you sure you want to delete your account?"),
          content: const Text(
              "This action will delete your account and remove you from the leaderboard"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteAccountAndData(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccountAndData(BuildContext context) async {
    try {
      final FirebaseFunctions functions = FirebaseFunctions.instance;
      await functions.httpsCallable('deleteUserData').call();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Error deleting account: $e");
    }
  }

  Widget LeaderboardRank(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _leaderboardData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          final leaderboardData = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Leaderboard',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          _leaderboardData = fetchLeaderboardData();
                        });
                      },
                    ),
                  ],
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => _confirmDeleteAccount(context),
                  child: const Text('Delete My Data', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button color
                  ),
                ),
              )
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _acceptedTerms = value!;
                        });
                      },
                    ),
                    Text("I accept the"),
                    TextButton(
                      onPressed: () => _showTermsDetail(context),
                      child: Text("Terms & Conditions"),
                    ),
                  ],
                ),
                ElevatedButton(
                  child: Text("Sign In to View Leaderboard"),
                  onPressed: _acceptedTerms
                      ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AuthGate()),
                    );
                  }
                      : null,
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _showTermsDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Terms and Conditions"),
          content: SingleChildScrollView(
            child: parseTermsAndConditions(termsAndConditionsText),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  RichText parseTermsAndConditions(String text) {
    final List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'\*\*(.+?)\*\*');
    int lastMatchEnd = 0;

    for (final Match match in regExp.allMatches(text)) {
      final String leadingText = text.substring(lastMatchEnd, match.start);
      final String boldText = match.group(1)!;

      if (leadingText.isNotEmpty) {
        spans.add(TextSpan(text: leadingText));
      }
      spans.add(TextSpan(text: boldText, style: TextStyle(fontWeight: FontWeight.bold)));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(text: TextSpan(style: TextStyle(color: Colors.black), children: spans));
  }
}