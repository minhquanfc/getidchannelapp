import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: "MyFont"
      ),
      home: const MyHomePage(title: 'Get ID channel YouTube'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String content = '';
  TextEditingController _textEditingController = TextEditingController();
  String data = '';
  String data_name = '';
  bool isLoading = false;

  bool checkUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  Future<void> _fetchHtmlData(String url) async {
    if (!checkUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link channel worng!')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    final response = await http.get(Uri.parse(url));
    final document = parse(response.body);
    final element = document.querySelector('meta[itemprop="identifier"]');
    final name = document.querySelector('link[itemprop="name"]');
    String namechannel = name?.attributes['content'] ?? '';
    String idchannel = element?.attributes['content'] ?? '';
    if (idchannel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not find id channel!'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
    setState(() {
      data_name = namechannel;
      data = idchannel;
      isLoading = false;
    });
  }

  void _copyToClipboard() {
    String textFieldText = _textEditingController.text;
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 10),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: double.infinity),
                child: ElevatedButton(
                  onPressed: () {
                    _fetchHtmlData(_textEditingController.text);
                  },
                  child: const Text("Get ID"),
                  style: const ButtonStyle(
                      maximumSize: MaterialStatePropertyAll<Size>(
                          Size(double.infinity, 50))),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Visibility(
                visible: data.isNotEmpty,
                child: Column(
                  children: [
                    Text(
                      "Channel: $data_name",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    Text(
                      "ID Channel: $data",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _copyToClipboard();
                      },
                      child: const Text('Copy'),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll<Color>(Colors.orangeAccent)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading) Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
