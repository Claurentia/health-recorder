import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './recording_state_provider.dart';

class EmotionRecorder extends StatefulWidget {
  const EmotionRecorder({super.key});

  @override
  _EmotionRecorderState createState() => _EmotionRecorderState();
}

class _EmotionRecorderState extends State<EmotionRecorder> {
  String? selectedEmoji;
  List<EmojiRecord> emojiRecords = [];

  String pickedMoodYesterday = "No record";
  String mostPickedMood = "No record";

  @override
  void initState() {
    super.initState();
    updateMoodSummary();
  }

  static const List<String> emojis = [
    "😀", "😊", "😢", "🤢", "😎", "😡", "😐", "😰", "😴", "😕",
    "🥰", "😍", "🤔", "😘", "😬", "😓", "😌", "🤐", "😶", "😜",
    "🤯", "😝", "🥳", "🤗"
  ];

  void _onEmojiTap(BuildContext context, String emoji) {
    setState(() {
      selectedEmoji = emoji;
      emojiRecords.insert(0, EmojiRecord(emoji, DateTime.now()));
      updateMoodSummary();
    });
    Provider.of<RecordingState>(context, listen: false).recordActivity('Mood');
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

  void updateMoodSummary() {
    // Calculate the picked mood yesterday
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day).subtract(Duration(days: 1));

    List<EmojiRecord> yesterdayRecords = emojiRecords.where((record) {
      return record.dateTime.year == yesterday.year &&
          record.dateTime.month == yesterday.month &&
          record.dateTime.day == yesterday.day;
    }).toList();

    if (yesterdayRecords.isNotEmpty) {
      Map<String, int> moodFrequency = {};

      for (var record in yesterdayRecords) {
        moodFrequency[record.emoji] = (moodFrequency[record.emoji] ?? 0) + 1;
      }

      String mostFrequentMood = moodFrequency.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      pickedMoodYesterday = mostFrequentMood;
    } else {
      pickedMoodYesterday = "No record";
    }

    // Calculate the most picked mood
    Map<String, int> moodCount = {};

    for (var record in emojiRecords) {
      moodCount[record.emoji] = (moodCount[record.emoji] ?? 0) + 1;
    }

    if (moodCount.isNotEmpty) {
      mostPickedMood = moodCount.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    setState(() {});
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
                  child: Column(
                    children: [
                      const Text('Your Mood Yesterday',
                          style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(pickedMoodYesterday,
                        style: TextStyle(
                          fontSize: pickedMoodYesterday == "No record" ? 14 : 24,
                          color: pickedMoodYesterday == "No record" ? Colors.white : Colors.black,),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(' Most Picked Mood ',
                          style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(mostPickedMood,
                        style: TextStyle(
                          fontSize: mostPickedMood == "No record" ? 14 : 24,
                          color: mostPickedMood == "No record" ? Colors.white : Colors.black,),
                      ),
                      const SizedBox(height: 5),
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
              key: const Key('yourMoodTodayKey'),
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
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Mood History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              key: const Key('moodHistoryList'),
              itemCount: emojiRecords.length,
              itemBuilder: (context, index) {
                EmojiRecord record = emojiRecords[index];
                return ListTile(
                  leading: Text(record.emoji, style: TextStyle(fontSize: 24)),
                  title: Text(
                      'Selected on: ${DateFormat('yyyy-MM-dd – kk:mm').format(record.dateTime)}'
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EmojiRecord {
  String emoji;
  DateTime dateTime;

  EmojiRecord(this.emoji, this.dateTime);
}