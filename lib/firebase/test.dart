import 'package:flutter/material.dart';
import 'package:specon/firebase/store.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page'),
      ),
      body: Center(
          child: ElevatedButton(
        onPressed: () async {
          Map<String, dynamic> res = await fetchData();

          Map<String, dynamic> list =
              await getUserByEmail('jerrya@outlook.com.au');
          print("he");
          print(list);
          print("hi");
          print(res);
        },
        child: Text('Fetch Data'),
      )),
    );
  }
}
