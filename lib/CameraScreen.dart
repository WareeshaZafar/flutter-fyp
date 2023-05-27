import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late List<XFile> _capturedImages;
  final _picker = ImagePicker();
  PageController _pageController = PageController(initialPage: 0);
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _capturedImages = [];
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _initializeCamera();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    setState(() {
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      _controller.initialize().then((_) {
        setState(() {});
      });
    });
  }

  Future<void> _captureImage() async {
    if (!_controller.value.isInitialized) {
      return;
    }
    try {
      await _controller.setFlashMode(FlashMode.off); // Disable flash
      final image = await _controller.takePicture();
      setState(() {
        _capturedImages.add(image);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1200,
        imageQuality: 85,
      );
      setState(() {
        _capturedImages.addAll(pickedFiles.map((file) => XFile(file.path)));
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _capturedImages.removeAt(index);
      if (_capturedImages.isEmpty) {
        _pageController.jumpToPage(0); // Move back to the first page if no more images are available
      }
    });
  }

  Widget _buildImagePreview(int index) {
    return Center(
      child: Stack(
        children: [
          Image.file(
            File(_capturedImages[index].path),
            fit: BoxFit.contain,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _deleteImage(index),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendImagesToServer(List<File> imageFiles) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading Images'),
          content: Text('Please wait while the images are being uploaded...'),
        );
      },
    );

    var request = http.MultipartRequest('POST', Uri.parse('http://104.46.120.239:5000/upload'));

    for (var i = 0; i < imageFiles.length; i++) {
      var file = imageFiles[i];
      request.files.add(await http.MultipartFile.fromPath('images', file.path));
    }

    var response = await request.send();
    Navigator.pop(context); // Close the dialog

    if (response.statusCode == 200) {
      // Files uploaded successfully
      // Handle the response, which should be the .obj file
      final objFileBytes = await response.stream.toBytes();
      // Save or process the objFileBytes as desired
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Images Uploaded'),
            content: Text('The images were successfully uploaded.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Error uploading files
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> _uploadImages() async {
    setState(() {
      _isUploading = true;
    });

    await sendImagesToServer(_capturedImages.cast<File>());

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.6, // Adjust the height as needed
              child: Stack(
                children: [
                  _controller.value.isInitialized
                      ? AspectRatio(
                    aspectRatio: 1 / 1,
                    child: CameraPreview(_controller),
                  )
                      : Container(),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _pickImages,
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                              minimumSize: const Size(40, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Icon(
                              Icons.photo_library,
                              size: 44,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _captureImage,
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                              minimumSize: const Size(40, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 44,
                            ),
                          ),
                          if (_capturedImages.isNotEmpty)
                            ElevatedButton(
                              onPressed: _isUploading ? null : _uploadImages,
                              style: ElevatedButton.styleFrom(
                                primary: Colors.black,
                                minimumSize: const Size(40, 60),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Icon(
                                Icons.cloud_upload,
                                size: 44,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_capturedImages.isNotEmpty)
              Expanded(
                child: Container(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _capturedImages.length,
                    itemBuilder: (context, index) {
                      return _buildImagePreview(index);
                    },
                  ),
                ),
              )
            else
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Selected photos will be displayed here',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
