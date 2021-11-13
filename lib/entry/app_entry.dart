import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First News',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'First News Top'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title = 'First News...'}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: const <Widget>[
          ListTile(
            leading: Icon(Icons.add_a_photo),
            title: Text("News Item 1"),
          ),
          ListTile(
            leading: Icon(Icons.computer),
            title: Text("News Item 2"),
          ),
          ListTile(
            leading: Icon(Icons.mobile_screen_share),
            title: Text("News Item 3"),
          ),
        ],
      ),
    );
  }
}
