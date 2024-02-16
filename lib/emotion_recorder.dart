import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './recording_state_provider.dart';
import 'floor_model/recorder_database.dart';
import 'floor_model/recorder_entity.dart';

class EmotionRecorder extends StatefulWidget {
  const EmotionRecorder({super.key});

  @override
  _EmotionRecorderState createState() => _EmotionRecorderState();
}

class _EmotionRecorderState extends State<EmotionRecorder> {
  String? selectedEmoji;
  List<EmotionRecord> emojiRecords = [];

  static const List<String> emojis = [
    "😀", "😊", "😢", "🤢", "😎", "😡", "😐", "😰", "😴", "😕",
    "🥰", "😍", "🤔", "😘", "😬", "😓", "😌", "🤐", "😶", "😜",
    "🤯", "😝", "🥳", "🤗"
  ];

  @override
  void initState() {
    super.initState();
    _loadEmojiRecords();
  }

  void _loadEmojiRecords() async {
    final database = Provider.of<RecorderDatabase>(context, listen: false);
    final records = await database.emotionRecordDao.findAllEmotionRecords();
    setState(() {
      emojiRecords = records;
    });
    _loadSelectedEmoji();
  }

  Future<void> _loadSelectedEmoji() async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final todayStr = dateFormat.format(DateTime.now());

    final database = Provider.of<RecorderDatabase>(context, listen: false);
    final lastRecord = await database.emotionRecordDao.getLastInsertedRecord();

    String newSelectedEmoji;
    if (lastRecord != null) {
      final recordDateStr = lastRecord.dateTime.split(' – ')[0];
      if (recordDateStr == todayStr) {
        newSelectedEmoji = lastRecord.emoji;
      } else {
        newSelectedEmoji = "Today's Mood";
      }
    } else {
      newSelectedEmoji = "Today's Mood";
    }

    setState(() {
      selectedEmoji = newSelectedEmoji;
    });
  }

  void _onEmojiTap(BuildContext context, String emoji) {
    setState(() {
      selectedEmoji = emoji;
    });
    int ptsEarned = Provider.of<RecordingState>(context, listen: false).recordActivity('Mood');
    EmotionRecord newRecord = EmotionRecord(emoji: emoji, dateTime: DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()), points: ptsEarned);
    _addToDB(newRecord);
  }

  void _addToDB(EmotionRecord newRecord) async {
    final database = Provider.of<RecorderDatabase>(context, listen: false);
    await database.emotionRecordDao.insertEmotionRecord(newRecord);
    _loadEmojiRecords();
  }

  void _deleteRecord(EmotionRecord record, int index) async {
    final database = Provider.of<RecorderDatabase>(context, listen: false);
    await database.emotionRecordDao.deleteEmotionRecord(record);
    _loadEmojiRecords();
    Provider.of<RecordingState>(context, listen: false).deductPoints(record.points);
  }

  void _deleteRecordConfirmation(EmotionRecord record, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this record?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRecord(record, index);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
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
                final reversedIndex = emojiRecords.length - 1 - index;
                EmotionRecord record = emojiRecords[reversedIndex];
                return ListTile(
                  leading: Text(record.emoji, style: TextStyle(fontSize: 24)),
                  title: Text('Selected on: ${record.dateTime}', style: TextStyle(fontSize: 15)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteRecordConfirmation(record, index),
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