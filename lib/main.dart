import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');

    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  void initState() {
    super.initState();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Download'),
        ),
        body: Container(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () async {
              final status = await Permission.storage.request();
              if (!status.isGranted) {
                // ignore: avoid_print
                print('Permission Denied');
              } else {
                final exterdir = await getExternalStorageDirectory();

                // ignore: unused_local_variable
                final task = await FlutterDownloader.enqueue(
                  url:
                      'http://192.168.43.109/flutter/public/api/download/result/16218332462Y2JH6EowPr5rTJegYuoAI5nsxoVx5/1',
                  savedDir: exterdir == null ? 'dowload' : exterdir.path,
                  fileName: 'result.pdf',
                  showNotification: true,
                  openFileFromNotification: true,
                );
              }
            },
            child: const Text('Click'),
          ),
        ),
      ),
    );
  }
}
