import 'package:another_flushbar/flushbar.dart';
import 'package:easy_markdown_editor/dialogs/file_name.dart';
import 'package:easy_markdown_editor/utils/ad_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';
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

  String _path;
  String _extension;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;
  String fileName = "file";
  bool shareable = false;

  BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady = false;
  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          this._interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              handleClick('Save File');
            },
          );

          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }
  Future<void> _openFileExplorer() async {
    if (_pickingType != FileType.CUSTOM || _hasValidMime) {
      try {
        if (_multiPick) {
          _path = null;
        } else {
          _path = await FilePicker.getFilePath(
              type: _pickingType, fileExtension: _extension);
        }
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;
      setState(() {
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _textEditingController = TextEditingController();
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    print(_isBannerAdReady);
    _bannerAd.load();
    _loadInterstitialAd();
  }

  void updateText(String text) {
    setState(() {
      this.text = text;
    });
  }

  Future<void> setFileName(String fname) async{
    setState(() {
      fileName = fname;
      shareable = true;
    });
    if (fileName.isNotEmpty){
      await FileUtils.saveToFile(fileName, text);
      Flushbar(
        messageText: Text(
          "Saved at: ${await FileUtils.localPath}/$fileName.md",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Montserrat",
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
            color: Colors.white,
          ),
        ),
        duration: Duration(seconds: 3),
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Colors.black,
      )..show(context);
    }else{
      Flushbar(
        messageText: Text(
          "Please provide a valid file name.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Montserrat",
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
            color: Colors.white,
          ),
        ),
        duration: Duration(seconds: 1),
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Colors.black,
      )..show(context);
    }
  }
  void share() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return FileNameDialog(save: setFileName,);
        });
    if (shareable){
      File testFile = new File("${await FileUtils.localPath}/$fileName.md");
      if (!await testFile.exists()) {
        Flushbar(
          messageText: Text(
            "Error, file not found.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Montserrat",
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
              color: Colors.white,
            ),
          ),
          duration: Duration(seconds: 1),
          flushbarStyle: FlushbarStyle.FLOATING,
          margin: EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(8),
          backgroundColor: Colors.black,
        )..show(context);
      }
      else{
        ShareExtend.share(testFile.path, "file");
      }
    }
    setState(() {
      shareable = false;
    });


  }
  @override
  void dispose() {
    _bannerAd.dispose();
    _interstitialAd.dispose();
    super.dispose();
  }
  Future<void> handleClick(String value) async {
    print(_isBannerAdReady);
    switch (value) {
      case 'Open File':
        await _openFileExplorer();
        final file =  File(_path);
        String fileContents = await file.readAsString();
        updateText(fileContents);
        _textEditingController.text = text;
        break;
      case 'Save File':
         showDialog(
            context: context,
            builder: (BuildContext context) {
              return FileNameDialog(save: setFileName,);
            });


        break;
      case 'Share File':
        share();
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_isInterstitialAdReady) {
            _interstitialAd?.show();
          } else {
            handleClick('Save File');
          }

        }
        ,
        child: const Icon(Icons.save),
        backgroundColor: Colors.black,
      ),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.share,
            ),
            iconSize: 20,
            color: Colors.black,
            splashColor: Colors.black,
            onPressed: () {
              handleClick('Share File');
            },
          ),
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
      body: FutureBuilder<void>(
        future: _initGoogleMobileAds(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot){
        return Column(
          children: [
            if (_isBannerAdReady)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
            Expanded(
              child: TabBarView(controller: _controller, children: [
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
            ),

          ],
        );},
      ),
    );
  }
}
