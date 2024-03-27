import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_player/utils/config.dart';

class UploadTrackService {
  final TextEditingController _textController = TextEditingController();

  late File track;

  BuildContext context;

  late NavigatorState _navigator;

  late ScaffoldMessengerState _scaffoldMessenger;

  UploadTrackService(this.context) {
    _navigator = Navigator.of(context);
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      if (result.count == 1 && result.names[0]!.endsWith(".mp3")) {
        track = File(result.files.single.path!);

        return;
      }
      _closeDialog('File is not ends with .mp3');
      return;
    } else {
      _closeDialog('File hasn`t choosen');
    }
  }

  void _closeDialog(String text) {
    text != ""
        ? _scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(text),
          ))
        : null;
    _navigator.pop();
  }

  Future<void> _uploadFile() async {
    var req = http.MultipartRequest("POST", Uri.parse('${Config.URL}/upload'));
    req.files.add(await http.MultipartFile.fromPath("file", track.path));

    var res = await http.Response.fromStream(await req.send());
    if (res.statusCode == 200) {
      http.put(
          Uri.parse(
            "${Config.URL}/update/${jsonDecode(res.body)["id"]}",
          ),
          body: '{"name":"${_textController.text}"}',
          headers: {
            "Content-Type": "application/json"
          }).then(
          (value) => _closeDialog("${value.statusCode} - ${value.body}"));
    } else {
      _closeDialog("Error ${res.statusCode} - Not uploaded ");
    }
  }

  Future<void> _cancelUpload() async {
    _closeDialog("");
  }

  Future<void> showUploadDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload a file'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextButton(
                  onPressed: _pickFile,
                  child: const Text('Select'),
                ),
                TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "track name"),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _navigator.pop,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _uploadFile,
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }
}
