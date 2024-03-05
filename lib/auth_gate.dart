import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:hw1/leaderboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pop(context);
              }),
            ],
            footerBuilder: (context, action) => const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'By signing in, you agree to our terms and conditions.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            sideBuilder: (context, shrinkOffset) => Container(
              color: Color(0xFFC4F3F8),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('lib/assets/hrecorder.png'),
                ),
              ),
            ),
          );
        } else {
          return LeaderboardPage();
        }
      },
    );
  }
}