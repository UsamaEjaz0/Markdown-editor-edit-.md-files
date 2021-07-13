import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  TextEditingController _textEditingController;
  String text = "";

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _textEditingController = TextEditingController();
  }

  void updateText(String text) {
    setState(() {
      this.text = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text(
          "Markdown",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          unselectedLabelColor: Colors.black,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black,
          ),
          controller: _controller,
          tabs: [
            Tab(
              child: Icon(Icons.code),
            ),
            Tab(
              child: Icon(Icons.visibility),
            )
          ],
        ),
      ),
      body: TabBarView(controller: _controller, children: [
        Container(
          margin: EdgeInsets.all(20),
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: _textEditingController,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: "Write Markdown here..."),
            onChanged: (String text) {
              updateText(text);
            },
          ),
        ),
        Container(
          margin: EdgeInsets.all(20),
          child: Markdown(data: text),
        ),
      ]),
    );
  }
}
