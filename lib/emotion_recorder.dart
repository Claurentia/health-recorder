import 'package:flutter/material.dart';

class EmotionRecorder extends StatefulWidget {
  const EmotionRecorder({super.key});

  @override
  _EmotionRecorderState createState() => _EmotionRecorderState();
}

class _EmotionRecorderState extends State<EmotionRecorder> {
  String? selectedEmoji;

  static const List<String> emojis = [
    "😀", "😊", "😢", "🤢", "😎", "😡", "😐", "😰", "😴", "😕",
    "🥰", "😍", "🤔", "😘", "😬", "😓", "😌", "🤐", "😶", "😜",
    "🤯", "😝", "🥳", "🤗"
  ];

  static List<Map<String, dynamic>> mockData = [
    {
      "emoji": "😀",
      "datetime": DateTime.now().subtract(const Duration(hours: 1))
    },
    {
      "emoji": "😴",
      "datetime": DateTime.now().subtract(const Duration(days: 1))
    },
    //... other mock data, to be populated in the next app state management assignment
  ];

  void _onEmojiTap(BuildContext context, String emoji) {
    // For now, show a simple snackbar and print on console on tap
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You selected $emoji'),
        duration: const Duration(seconds: 1),
      ),
    );
    print('You selected $emoji');
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
          ),
          itemCount: emojis.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedEmoji = emojis[index];
                });
                _onEmojiTap(context, emojis[index]);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(emojis[index],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF333333),
        title: const Text('Emotion Recorder',
          style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Text('Your Mood Yesterday',
                          style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('😴', style: TextStyle(fontSize: 24)),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Text(' Most Picked Mood ',
                          style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('🙂', style: TextStyle(fontSize: 24)),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('How are you feeling today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10,),
          Center(
            child: Text(selectedEmoji ?? 'Your mood today',
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _showEmojiPicker,
              child: const Text('Select Mood'),
            ),
          ),
          const SizedBox(height: 50),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mockData.length,
              itemBuilder: (context, index) {
                var item = mockData[index];
                return ListTile(
                  leading: Text(item["emoji"],
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text("Selected on: ${item["datetime"].toString()}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}