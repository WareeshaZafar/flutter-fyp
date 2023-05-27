import 'package:flutter/material.dart';
import 'home_page.dart';
import 'CameraScreen.dart';
import 'FileListScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photogrammetry',
      theme: ThemeData(
        primaryColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
      ),
      home: const MainApp(),
      routes: {
        '/camera': (context) => const CameraScreen(),
  
        '/fileList': (context) => FileListScreen(),
},

    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              height: 50,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 150),
                    child: Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Text(
                      'ScanCraft',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                  const Text(
                    'Turn real life objects into 3D models',
                    style: TextStyle(
                      fontSize: 18,
                      height: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    child: Image.asset(
                      'assets/material/log2.png', // Replace with your logo image path
                      height: 300,
                      width: 300,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/camera');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'New Model',
                    style: TextStyle(fontSize: 18), // Increase font size
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(180, 60), // Adjust the button size as needed
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/fileList');
                  },
                  icon: const Icon(Icons.insert_drive_file),
                  label: const Text(
                    'Existing Model',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black),
                    ),
                    minimumSize: const Size(180, 60),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
