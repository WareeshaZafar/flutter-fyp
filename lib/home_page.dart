import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  final String fileName;

  HomePage({required this.fileName});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Object? material;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    String assetPath = 'assets/material/${widget.fileName}';
    material = Object(fileName: assetPath);
    setState(() {});
  }

  Future<void> exportModel() async {
    // Save the model file to the device's temporary directory
    String assetPath = 'assets/material/${widget.fileName}';
    final appDir = await getTemporaryDirectory();
    final tempFilePath = '${appDir.path}/${widget.fileName}';
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    await File(tempFilePath).writeAsBytes(bytes);

    // Share the model file using the share plugin
    await Share.shareFiles(
      [tempFilePath],
      text: 'Check out this 3D model!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: exportModel,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Cube(
                onSceneCreated: (Scene scene) {
                  if (material != null) {
                    scene.world.add(material!);
                    scene.camera.zoom = 10;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
