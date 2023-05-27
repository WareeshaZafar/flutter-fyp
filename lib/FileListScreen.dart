import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;

import 'home_page.dart';

class FileListScreen extends StatefulWidget {
  @override
  _FileListScreenState createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  List<String> fileNames = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadModelFiles();
  }

  Future<void> loadModelFiles() async {
    String manifestContent = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> manifestMap = json.decode(manifestContent);

    List<String> assets = manifestMap.keys
        .where((String key) => key.contains('assets/material/'))
        .toList();

    List<String> fileNames = assets.map((String asset) {
      String fileName = path.basename(asset);
      return fileName;
    }).where((fileName) => fileName.endsWith('.obj')).toList();

    setState(() {
      this.fileNames = fileNames;
    });
  }

  List<String> get filteredFileNames {
    return fileNames.where((fileName) {
      return fileName.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by filename',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFileNames.length,
              itemBuilder: (context, index) {
                final fileName = filteredFileNames[index];
                return ListTile(
                  leading: Icon(Icons.insert_drive_file),
                  title: Text(fileName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(fileName: fileName),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
