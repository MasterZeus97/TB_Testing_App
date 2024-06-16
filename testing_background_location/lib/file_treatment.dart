import 'dart:developer';
import 'dart:io';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class CounterStorage {
  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/counter.txt');
  }

  Future<int> readFile() async {
    try {
      final file = await localFile;

      // Read the file
      final contents = await file.readAsString();

      log("readFile: $contents");

      return 1;
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<bool> deleteFile() async{
    try {
      final file = await localFile;

      log("deleteFile");

      file.delete();
      log("file deleted");
      writeStartMeasure();
      log("new new file created");
      readFile();
      log("readFile done");
      return true;
    } catch (e) {
      return false;
    }

  }

  Future<File> writeLatLong(double lat, double long, int distSinceLast) async {
    final file = await localFile;

    String formattedDate = _getFormattedDate();

    // Write the file
    return file.writeAsString('$lat,$long,$distSinceLast,$formattedDate\n', mode: FileMode.append);
  }

  Future<File> writeStartMeasure() async {
    final file = await localFile;

    DateTime now = DateTime.now();
    String formattedDate = now.toString();

    String platform = Platform.operatingSystem;



    // Write the file
    return file.writeAsString('\n\nStarting new measure on $platform: $formattedDate\n\nlat,long,distSinceLast,month,day,hour,minute,second\n', mode: FileMode.append);
  }

  Future<File> writeStopMeasure() async {
    final file = await localFile;

    DateTime now = DateTime.now();
    String formattedDate = now.toString();

    // Write the file
    return file.writeAsString('\n\nStopping measure: $formattedDate\n\n', mode: FileMode.append);
  }


  Future<void> sendEmail() async {
    log("sendEmail1");

    final path = await localPath;
    String filepath = ('$path/counter.txt');
    var tmp = File('$path/counter.txt');
    log("testing");
    log(filepath);

    List<String> attachments = [tmp.path];

    var value = await readFile();
    log("value: $value");
    Email email = Email(
      body: value.toString(),
      subject: 'Email subject',
      recipients: ['thibault.seem@heig-vd.ch'],
      cc: ['seemth1310@gmail.com'],
      attachmentPaths: attachments,
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  String _getFormattedDate() {
    DateTime date = DateTime.now();
    int month = date.month;
    int day = date.day;
    int hour = date.hour;
    int minute = date.minute;
    int second = date.second;

    return "$month,$day,$hour,$minute,$second";
  }
}