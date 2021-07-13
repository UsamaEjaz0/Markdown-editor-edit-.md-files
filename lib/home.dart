import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'utils/file_utils.dart';
import 'dart:io';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  TabController _controller;
  TextEditingController _textEditingController;
  String text = "";

  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;

  Future<void> _openFileExplorer() async {
    if (_pickingType != FileType.CUSTOM || _hasValidMime) {
      setState(() => _loadingPath = true);
      try {
        if (_multiPick) {
          _path = null;
          _paths = await FilePicker.getMultiFilePath(
              type: _pickingType, fileExtension: _extension);
        } else {
          _paths = null;
          _path = await FilePicker.getFilePath(
              type: _pickingType, fileExtension: _extension);
        }
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;
      setState(() {
        _loadingPath = false;
        _fileName = _path != null
            ? _path.split('/').last
            : _paths != null ? _paths.keys.toString() : '...';
      });
    }
  }

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
  Future<void> handleClick(String value) async {
    switch (value) {
      case 'Open File':
        await _openFileExplorer();
        final file =  File(_path);
        String fileContents = await file.readAsString();
        updateText(fileContents);
        _textEditingController.text = text;
        break;
      case 'Save File':
        FileUtils.saveToFile("Mark", 'First Test');
        print("Saved");
        break;
      case 'Share File':
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton(
        onPressed: () async {


        }
        ,
        child: const Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black,),
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Open File', 'Save File', 'Share File'}.map((String choice) {
                return PopupMenuItem<String>(

                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
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
          child: Markdown(data: text, selectable: true),
        ),
      ]),
    );
  }
}
