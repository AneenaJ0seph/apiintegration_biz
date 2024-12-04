import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SecondPage extends StatefulWidget {
  final String companyName;
  final String contactPerson;
  final String email;
  final String phone;
  final String address;

  const SecondPage({
    required this.companyName,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  File? _uploadedFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickFile() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _uploadedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    final String url = 'https://apib2b-production.up.railway.app/api/business_users/';
    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['company_name'] = widget.companyName
      ..fields['contact_person'] = widget.contactPerson
      ..fields['email'] = widget.email
      ..fields['phone'] = widget.phone
      ..fields['address'] = widget.address;

    if (_uploadedFile != null) {
      request.files.add(await http.MultipartFile.fromPath('uploaded_file', _uploadedFile!.path));
    }

    try {
      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign Up Successful!')),
        );
        Navigator.pop(context); // Navigate back to the first page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up - Step 2")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Upload a File",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Center(
              child: _uploadedFile != null
                  ? Column(
                children: [
                  Image.file(_uploadedFile!, width: 200, height: 200, fit: BoxFit.cover),
                  SizedBox(height: 8.0),
                  Text("File: ${_uploadedFile!.path.split('/').last}"),
                ],
              )
                  : Text("No file selected"),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text("Pick File"),
            ),
            SizedBox(height: 32.0),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submitForm,
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
