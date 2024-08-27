import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageCaptureScreen(),
    );
  }
}

class ImageCaptureScreen extends StatefulWidget {
  @override
  _ImageCaptureScreenState createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  File? _image;
  String? _apiResponse;

  // Function to pick image from camera
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  // Function to send image to API
  Future<void> _sendImageToAPI() async {
    if (_image == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://your-api-endpoint.com/upload'), // Replace with your API endpoint
    );
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      _image!.path,
    ));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      setState(() {
        _apiResponse = responseBody;
      });
    } else {
      print('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Capture Image'),
            ),
            ElevatedButton(
              onPressed: _sendImageToAPI,
              child: Text('Send to API'),
            ),
            SizedBox(height: 20),
            _apiResponse == null
                ? Text('No response yet.')
                : Text('Response: $_apiResponse'),
          ],
        ),
      ),
    );
  }
}
