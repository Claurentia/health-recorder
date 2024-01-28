import 'package:flutter/material.dart';

class DietRecorder extends StatefulWidget {
  const DietRecorder({super.key});

  @override
  _DietRecorderState createState() => _DietRecorderState();
}

class _DietRecorderState extends State<DietRecorder> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _calController = TextEditingController();

  static List<Map<String, dynamic>> mockData = [
    {"food": "Apple", "quantity": "95", "datetime": DateTime.now().subtract(const Duration(hours: 2))},
    {"food": "Sandwich", "quantity": "250", "datetime": DateTime.now().subtract(const Duration(hours: 5))},
    {"food": "Salad", "quantity": "100", "datetime": DateTime.now().subtract(const Duration(days: 1))},
    // ... other mock data, to be populated in the next app state management assignment
  ];

  void _onRecordTap(BuildContext context) {
    String item = _itemController.text;
    String cal = _calController.text;
    print('Log: Item - $item \t Calories - $cal');

    // add the new record to mock data - to do in next app state management assignment

    // clear the text fields after adding
    _itemController.clear();
    _calController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          },
        child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF333333),
          title: const Text('Diet Recorder',
            style: TextStyle(color: Colors.white),),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 10),
                            Icon(Icons.fastfood, color: Colors.white),
                            SizedBox(width: 15),
                            Expanded(
                              child: Text('Calories Gained Yesterday',
                                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 15),
                            Text('1200 cal',
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 24, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                    ),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF008080),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 10),
                            Icon(Icons.trending_up, color: Colors.white),
                            SizedBox(width: 15),
                            Expanded(
                              child: Text('Avg. Calories Gained This Week',
                                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 15),
                            Text('1500 cal',
                              style: TextStyle(fontSize: 24, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                    ),
                    const SizedBox(height: 20),
                    const Text('What did you eat today?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _itemController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Food Item',
                        hintText: 'Enter what you ate',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _calController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Calories',
                        hintText: 'Enter the amount of calories',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // this button will add another set of text field to record diet item
                            // to do in the next app state management assignment
                            print('Tapped: button to add another food item');
                          },
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _onRecordTap(context),
                        child: const Text('Record Diet'),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('Diet History',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                      ),
                    ),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        itemCount: mockData.length,
                        itemBuilder: (context, index) {
                          var item = mockData[index];
                          return ListTile(
                            leading: const Icon(Icons.fastfood),
                            title: Text("${item['food']} - ${item['quantity']} cal"),
                            subtitle: Text("Recorded on: ${item['datetime'].toString()}"),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ),
        )
      )
    );
  }

  @override
  void dispose() {
    _itemController.dispose();
    _calController.dispose();
    super.dispose();
  }
}
