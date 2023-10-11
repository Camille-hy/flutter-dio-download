import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Download',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'File Download'),
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
  TextEditingController url = TextEditingController();
  double _progress = 0.0;
  bool _downloading = false;

  Future openFile({required String url, String? fileName}) async {
    final name = fileName ?? url.split('/').last;
    final file = await downloadFile(url, name);

    if (file == null) return;

    print('Path: ${file.path}');

    OpenFile.open(file.path);
  }

  Future<File?> downloadFile(String url, String name) async {
    final appStorage = await getExternalStorageDirectory();
    // final appStorage = await getTemporaryDirectory();
    // final appStorage = await getApplicationDocumentsDirectory();
    // String dirPath = '${appStorage!.path}/new_directory';
    // Directory newDirectory = Directory(dirPath);

    // if (!newDirectory.existsSync()) {
    //   newDirectory.createSync();
    // }

    // final file = File('${newDirectory.path}/$name');

    final file = File('${appStorage!.path}/$name');
    print(file);

    try {
      await Dio().download(url, file.path,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          setState(() {
            _progress = received / total;
          });
        }
      });
      return file;
    } catch (e) {
      return null;
    }

    // try {
    //   // await newDirectory.create();
    //   final response = await Dio().get(url,
    //       options: Options(
    //         responseType: ResponseType.bytes,
    //         followRedirects: false,
    //       ), onReceiveProgress: (received, total) {
    //     if (total != -1) {
    //       setState(() {
    //         _progress = received / total;
    //       });
    //     }
    //   });

    //   print('Response data length: ${response.data.length}');

    //   final raf = file.openSync(mode: FileMode.write);
    //   raf.writeFromSync(response.data);
    //   await raf.close();
    //   print('File downloaded and saved at: ${file.path}');
    //   return file;
    // } catch (e) {
    //   return null;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Download file',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: url,
                decoration: const InputDecoration(label: Text('URL')),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _downloading = true;
                  _progress = 0.0;
                });

                final status = await Permission.storage.request();
                if (status.isGranted) {
                  await openFile(url: url.text);
                } else {
                  print('Permission denied');
                }

                setState(() {
                  _downloading = false;
                  _progress = 0.0;
                });
              },
              child: Text(
                'Download',
                style: TextStyle(fontSize: 20),
              ),
            ),
            if (_downloading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LinearProgressIndicator(
                  value: _progress,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
