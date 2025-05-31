import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tech_media/res/fonts.dart';

class DocumentScannerScreen extends StatefulWidget {
  @override
  _DocumentScannerScreenState createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  List<File> scannedImages = [];
  String title = ''; // Declare title variable
  String note = ''; // Declare note variable

  Future<void> _scanDocument() async {
    List<String>? scannedDocsPaths = await CunningDocumentScanner.getPictures();
    if (scannedDocsPaths != null && scannedDocsPaths.isNotEmpty) {
      List<File> scannedDocs = scannedDocsPaths.map((path) => File(path)).toList();
      setState(() {
        scannedImages.addAll(scannedDocs);
      });
    }
  }

  Future<void> showSavePdfDialog(BuildContext context) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String? fileName;
    String? description;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          scrollable: true,
          title: Center(
            child: Text(
              'Save PDF',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  cursorColor: Colors.black87,
                  style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'File Name',
                    labelStyle: TextStyle(color: Colors.black87),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87, width: 2.0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.5)),
                    ),
                  ),
                  onChanged: (value) {
                    fileName = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a file name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  cursorColor: Colors.black87,
                  style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.black87),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87, width: 2.0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.5)),
                    ),
                  ),
                  onChanged: (value) {
                    description = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop(); // Close the dialog
                  _generatePDF(fileName!, description!, scannedImages);
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular),
              ),
            ),
          ],
        );
      },
    );
  }


  Future<void> _downloadPDF() async {
    if (scannedImages.isNotEmpty) {
      await showSavePdfDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No scanned documents available')),
      );
    }
  }

  Future<void> checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        var result = await Permission.storage.request();
        if (result.isGranted) {
          print('Storage permission granted');
        } else {
          print('Storage permission denied');
        }
      } else {
        print('Storage permission already granted');
      }
    } else if (Platform.isIOS) {
      print('iOS platform detected');
    }
  }

  Future<void> _generatePDF(String title, String note, List<File> images) async {
    checkAndRequestPermissions();
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(note, style: pw.TextStyle(fontSize: 16)),
            ],
          );
        },
      ),
    );

    for (var imageFile in scannedImages) {
      Uint8List imageData = await imageFile.readAsBytes();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pw.MemoryImage(imageData)),
            );
          },
        ),
      );
    }
    print('Generating PDF...');

    String? outputPath = await FilePicker.platform.getDirectoryPath();
    if (outputPath != null) {
      String filePath = '$outputPath/$title.pdf';
      File file = File(filePath);
      if (file.existsSync()) {
        bool? saveBoth = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              title: Text('File Exists'),
              content: Text(
                  'A file with the name $title.pdf already exists. Do you want to overwrite it or save both?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(false); // Return false for overwrite
                    await file.writeAsBytes(await pdf.save());
                    print('PDF saved to: $filePath');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          title: Text('PDF Saved'),
                          content: Text('$title was saved at $filePath'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Optionally add more actions after closing the dialog
                              },
                              child: Text('OK',  style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Overwrite', style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true); // Return true for save both
                    int fileNumber = 1;
                    while (file.existsSync()) {
                      filePath = '$outputPath/${title} ($fileNumber).pdf';
                      file = File(filePath);
                      fileNumber++;
                    }
                    await file.writeAsBytes(await pdf.save());
                    print('PDF saved to: $filePath');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          title: Text('PDF Saved'),
                          content: Text('$title was saved at $filePath'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK', style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Save Both', style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular)),
                ),
              ],
            );
          },
        );

        if (saveBoth == null) {
          print('User cancelled saving the PDF');
        }
      } else {
        await file.writeAsBytes(await pdf.save());
        print('PDF saved to: $filePath');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text('PDF Saved'),
              content: Text('$title was saved at $filePath'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Optionally add more actions after closing the dialog
                  },
                  child: Text('OK',  style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular)),
                ),
              ],
            );
          },
        );
      }
    } else {
      print('User cancelled the file picker');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Scanner',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        actions: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: CupertinoColors.white, // Background color of the container
            ),
            child: IconButton(
              icon: Icon(Icons.document_scanner_rounded, color: Colors.pink, size: 20,),
              onPressed: _scanDocument,
              tooltip: 'Scan Document',
            ),
          ),
          SizedBox(width: 5),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: CupertinoColors.white, // Background color of the container
            ),
            child: IconButton(
              icon: Icon(Icons.file_download_rounded, color: Colors.teal, size: 22,),
              onPressed: _downloadPDF,
              tooltip: 'Download as PDF',
            ),
          ),
          SizedBox(width: 15)
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: scannedImages.isNotEmpty
                ? ReorderableListView.builder(
              itemCount: scannedImages.length,
              itemBuilder: (context, index) {
                return buildCard(scannedImages[index], index);
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final File item = scannedImages.removeAt(oldIndex);
                  scannedImages.insert(newIndex, item);
                });
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.document_scanner_outlined,
                    size: 80,
                    color: Colors.black26,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Scanned documents\n'
                          '    will appear here',
                      style: TextStyle(fontSize: 18, color: Colors.black26),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(File imageFile, int index) {
    return Card(
      key: ValueKey(imageFile), // Add a key to each card for reordering
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          _showFullImage(imageFile);
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.file(imageFile, height: 200),
              SizedBox(height: 16),
              Text(
                'Scanned Document ${index + 1}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        scannedImages.removeAt(index);
                      });
                    },
                    icon: Icon(Icons.delete_rounded, size: 22, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImage(File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: Image.file(imageFile),
        );
      },
    );
  }

  void main() {
    runApp(MaterialApp(
      home: DocumentScannerScreen(),
    ));
  }
}
