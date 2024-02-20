import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './recording_state_provider.dart';
import './appLocalizations.dart';
import 'floor_model/recorder_database.dart';
import 'floor_model/recorder_entity.dart';
import 'main.dart';

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

    String? newSelectedEmoji;
    if (lastRecord != null) {
      final recordDateStr = lastRecord.dateTime.split(' – ')[0];
      if (recordDateStr == todayStr) {
        newSelectedEmoji = lastRecord.emoji;
      }
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
    final AppLocalizations localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyApp.of(context)!.useMaterialDesign
        ? AlertDialog(
            title: Text(localizations.translate('confirmDeleteTitle')),
            content: Text(localizations.translate('confirmDeleteContent')),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(localizations.translate('cancel')),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteRecord(record, index);
                },
                child: Text(localizations.translate('delete'), style: const TextStyle(color: Colors.red)),
              ),
            ],
          )
        : CupertinoAlertDialog(
          title: Text(localizations.translate('confirmDeleteTitle')),
          content: Text(localizations.translate('confirmDeleteContent')),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.translate('cancel')),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRecord(record, index);
              },
              child: Text(localizations.translate('delete'), style: const TextStyle(color: CupertinoColors.destructiveRed)),
            ),
          ],
        );
      },
    );
  }

  void _showEmojiPicker() {
    if (MyApp.of(context)!.useMaterialDesign) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return _buildEmojiPickerGrid();
        },
      );
    } else {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height / 3,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: _buildEmojiPickerGrid(),
            ),
          );
        },
      );
    }
  }

  Widget _buildEmojiPickerGrid() {
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
            child: Text(emojis[index], style: const TextStyle(fontSize: 24)),
          ),
        );
      },
    );
  }

  Widget _buildEmojiRecordsList() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return ListView.builder(
      itemCount: emojiRecords.length,
      itemBuilder: (context, index) {
        final reversedIndex = emojiRecords.length - 1 - index;
        EmotionRecord record = emojiRecords[reversedIndex];

        if (MyApp.of(context)!.useMaterialDesign) {
          return ListTile(
            leading: Text(record.emoji, style: TextStyle(fontSize: 24)),
            title: Text('${localizations.translate('selectedOn')} ${record.dateTime}', style: TextStyle(fontSize: 15)),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRecordConfirmation(record, index),
            ),
          );
        } else {
          // Cupertino style
          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(record.emoji, style: TextStyle(fontSize: 24)),
                  Flexible(
                    child: Text('${localizations.translate('selectedOn')} ${record.dateTime}', style: TextStyle(fontSize: 15)),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed),
                    onPressed: () => _deleteRecordConfirmation(record, index),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool isMaterialDesign = MyApp.of(context)!.useMaterialDesign;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(localizations.translate('feelingToday'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10,),
          Center(
            child: Text(selectedEmoji ?? localizations.translate('yourMoodToday'),
              key: const Key('yourMoodTodayKey'),
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: isMaterialDesign
            ? ElevatedButton(
              onPressed: _showEmojiPicker,
              child: Text(localizations.translate('selectMood')),
            )
            : CupertinoButton(
              onPressed: _showEmojiPicker,
              child: Text(localizations.translate('selectMood')),
              color: CupertinoColors.activeBlue,
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(localizations.translate('moodHistory'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _buildEmojiRecordsList(),
          ),
        ],
      ),
    );
  }
}