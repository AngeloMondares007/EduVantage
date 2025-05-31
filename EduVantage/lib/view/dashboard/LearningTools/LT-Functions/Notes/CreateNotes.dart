import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../../../res/components/CircularProgress.dart';
import '../../../../../utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;


class CreateNotesScreen extends StatefulWidget {
  @override
  _CreateNotesScreenState createState() => _CreateNotesScreenState();
}

class _CreateNotesScreenState extends State<CreateNotesScreen> {
  final CollectionReference classCollection =
  FirebaseFirestore.instance.collection('Notes');
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String note = '';
  Color selectedColor = Colors.blue;

  // Declare FirebaseAuth instance and userUID
  final auth = FirebaseAuth.instance;
  String userUID = "";

  List<File> _images = [];
  final picker = ImagePicker();

  List<String> imageUrls = []; // Add this variable to store image URLs
  List<String> existingImageUrls = [];

  List<String> _extractLinkText(String text) {
    // Regular expression to match links
    RegExp linkRegex = RegExp(r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+');

    // Find all links in the text
    Iterable<RegExpMatch> matches = linkRegex.allMatches(text);

    // Extract and return link texts
    return matches.map((match) => match.group(0) ?? '').toList();
  }

  @override
  void initState() {
    super.initState();
    fetchUserUID();
    checkAndRequestPermissions();
    // Initialize timezone data
    tz.initializeTimeZones();
  }

  Future<void> fetchUserUID() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      setState(() {
        userUID = currentUser.uid;
      });
    }
  }

  Future<void> uploadImagesToStorage() async {
    try {
      final storage = FirebaseStorage.instance;
      for (int i = 0; i < _images.length; i++) {
        File imageFile = _images[i];
        String imageName = 'image_$i'; // You can use a unique name for each image
        Reference ref = storage.ref().child('images/$imageName');
        await ref.putFile(imageFile);
        print('Image $i uploaded to Firebase Storage');
      }
    } catch (e) {
      print('Error uploading images to Firebase Storage: $e');
    }
  }


  Future _pickImage() async {
    final pickedFile = await
    picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
        print('Added image');
      });
    } else {
      print('No image selected');
    }
  }

  void deleteImageUI(int index) async {
    try {
      // Remove image URL from the list
      setState(() {
        _images.removeAt(index);
      });

    } catch (e) {
      print('Error deleting image: $e');
      // Show an error message or handle error notification
      Utils.toastMessage('Error deleting image');
    }
  }

  void _showFullImageUI(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _images[index],
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        // Request storage permission
        var result = await Permission.storage.request();
        if (result.isGranted) {
          // Permission granted, proceed with your logic
          print('Storage permission granted');
        } else {
          // Permission denied, handle accordingly (e.g., show a message)
          print('Storage permission denied');
        }
      } else {
        // Permission already granted, proceed with your logic
        print('Storage permission already granted');
      }
    } else if (Platform.isIOS) {
      // Handle iOS permissions if needed
      print('iOS platform detected');
    }
  }

  Future<void> generatePDF(String title, String note) async {
    checkAndRequestPermissions();
    final pdf = pw.Document();

    // Add title and description to PDF
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

    // Add images to PDF (assuming _images is a list of File objects)
    for (var imageFile in _images) {
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

    // Add existing image URLs to PDF
    for (var imageUrl in existingImageUrls) {
      try {
        http.Response response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          Uint8List imageData = response.bodyBytes;
          pdf.addPage(
            pw.Page(
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Image(pw.MemoryImage(imageData)),
                );
              },
            ),
          );
        } else {
          print('Failed to load image from URL: $imageUrl');
        }
      } catch (e) {
        print('Error loading image from URL: $imageUrl, Error: $e');
      }
    }

    // Let the user pick a file location
    String? outputPath = await FilePicker.platform.getDirectoryPath();
    if (outputPath != null) {
      // Construct the file path with the selected directory and file name
      String filePath = '$outputPath/$title.pdf';
      File file = File(filePath);
      if (file.existsSync()) {
        // If the file already exists, ask the user whether to overwrite or save both
        bool? saveBoth = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text('File Exists'),
              content: Text('A file with the name $title.pdf already exists. Do you want to overwrite it or save both?'),
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
                                // Optionally add more actions after closing the dialog
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
        // Write the PDF to the file
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
                  child: Text('OK', style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular)),
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

  void changeColor(Color color) {
    setState(() => selectedColor = color);
  }

  Color getTextColor(Color backgroundColor) {
    // Calculate the luminance of the background color
    double luminance = backgroundColor.computeLuminance();
    // Set text color based on luminance
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Color getHintTextColor(Color backgroundColor) {
    // Calculate the luminance of the background color
    double luminance = backgroundColor.computeLuminance();
    // Set hint text color based on luminance
    return luminance > 0.5 ? Colors.black54 : Colors.white70;
  }

  Color getLinkContainer(Color backgroundColor) {
    // Calculate the luminance of the background color
    double luminance = backgroundColor.computeLuminance();
    // Set hint text color based on luminance
    return luminance > 0.5 ? Colors.white : Colors.black;
  }

  Future<bool> showNotificationPrompt() {
    Completer<bool> completer = Completer<bool>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Do you want to be notified for this note?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          backgroundColor: Color(0xFFe5f3fd),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                completer.complete(false);
                Utils.toastMessage('Note ${title} is saved without notification');
              },
              style: ButtonStyle(textStyle: WidgetStateTextStyle.resolveWith((states) => TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular, fontSize: 15))),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                completer.complete(true);
              },
              style: ButtonStyle(textStyle: WidgetStateTextStyle.resolveWith((states) => TextStyle(color: Colors.black87, fontFamily: AppFonts.alatsiRegular, fontSize: 15))),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    return completer.future;
  }

  Future<void> showDateTimePicker() async {
    DateTime? selectedDate = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              // Modify the color and shape of the time picker
              colorScheme: ColorScheme.light(
                  primary: Colors.blue, // Change the primary color
                  onPrimary: Colors.white, // Change the text color
                  secondary: Colors.blue,
                  onSecondary: Colors.white
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue, // Change the button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        // Combine selectedDate and selectedTime into a single DateTime object
        DateTime selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        // Schedule notification for selectedDateTime
        scheduleNotification(selectedDateTime);
      }
    }
  }

  void scheduleNotification(DateTime dateTime) {
    saveClassData(dateTime);
    Utils.toastMessage('Note ${title} will be notified at ${dateTime}');
    print('Notification scheduled for: $dateTime');
  }

  @override
  Widget build(BuildContext context) {

    Color linkColor = getLinkContainer(selectedColor);
    Color textColor = getTextColor(selectedColor);
    Color hintTextColor = getHintTextColor(selectedColor);

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: false,
        title: Text("Add Note",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold,)),
        backgroundColor: selectedColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: CupertinoColors.white, // Background color of the container
            ),
            child: IconButton(
              icon: Icon(Icons.picture_as_pdf_rounded, size: 20, color: Colors.deepPurple,),
              onPressed: () {
                if (title.isEmpty || note.isEmpty) {
                 Utils.toastMessage("PDF can only be generated if title and note are not empty");
                } else {
                  generatePDF(title, note);
                  print('Pdf button pressed');
                }
              },
            ),

          ),
          SizedBox(width: 5,),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: CupertinoColors.white, // Background color of the container
            ),
            child: IconButton(
              icon: Icon(CupertinoIcons.photo_fill_on_rectangle_fill, size: 18, color: Colors.blue,),
              onPressed: () {
                _pickImage();
                print('Image button pressed');
              },
            ),
          ),
          SizedBox(width: 5,),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: CupertinoColors.white, // Background color of the container
            ),
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: Text(
                        'Pick a color',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: MaterialColorPicker(
                        selectedColor: selectedColor,
                        onColorChange: (Color color) {
                          changeColor(color);
                        },
                        onBack: () {},
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Perform any additional actions if needed
                          },
                          child: Text(
                            'Select',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppFonts.alatsiRegular,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(
                Icons.color_lens, // Use the icon of your choice, such as Icons.color_lens
                color: Colors.teal,
              ),
            ),
          ),

SizedBox(width: 5),

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: CupertinoColors.white, // Background color of the container
            ),
            child: IconButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() == true) {
                  bool notify = await showNotificationPrompt();
                  if (notify) {
                    showDateTimePicker();
                  } else {
                    saveClassData(null);
                  }
                }
              },
              icon: Icon(
                Icons.save_as_rounded,
                color: Colors.red,
                size: 20,
              ),
              tooltip: 'Save', // Optional tooltip for the icon
            ),
          ),

          SizedBox(width: 15,)
        ],
      ),


      backgroundColor: selectedColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    cursorColor: textColor,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(
                          fontSize: 24, color: hintTextColor),
                      border: InputBorder.none,
                      errorStyle: TextStyle(
                        color: textColor, // Set the color for validation error text
                      ),
                    ),
                    style: TextStyle(fontSize: 24, color: textColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        title = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    cursorColor: textColor,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Note',
                      hintStyle: TextStyle(
                          fontSize: 18,
                          color: hintTextColor,
                          fontWeight: FontWeight.normal),
                      border: InputBorder.none,
                      errorStyle: TextStyle(
                        color: textColor, // Set the color for validation error text
                      ),
                    ),
                    style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.normal),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a note';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        note = value;
                      });
                    },
                  ),
                ),
                if (_images.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Container(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Show full-size image when tapped
                                      _showFullImageUI(index);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Image.file(
                                        _images[index],
                                        height: 200,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 15,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Remove image from Firebase Storage and UI
                                        deleteImageUI(index);
                                      },
                                      child: Icon(Icons.close, color: Colors.red, size: 20),
                                    ),
                                  ),
                                ]
                            );

                          },
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 25),
                Visibility(
                  visible: _containsLink(note), // Check if the text contains a link
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: textColor, // Background color of the container
                    ),
                    child: Column(
                      children: [
                        // Add your text widget here
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Links:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: linkColor, // Color of the text
                              ),
                            ),
                          ),
                        ),
                        // Add SizedBox for spacing
                        SizedBox(height: 10),
                        // Add your ListView.separated widget for links
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _extractLinkText(note).length,
                          separatorBuilder: (context, index) => SizedBox(height: 10), // Add more vertical space between links
                          itemBuilder: (context, index) {
                            String linkText = _extractLinkText(note)[index];
                            return GestureDetector(
                              onTap: () async {
                                if (await launch(linkText)) {
                                  await launch(linkText);
                                } else {
                                  throw 'Could not launch $linkText';
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8), // Add vertical padding around the link text
                                child: RichText(
                                  text: TextSpan(
                                    text: linkText,
                                    style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _containsLink(String text) {
    // Use a regular expression to check if the text contains a link
    final RegExp linkRegex = RegExp(r'http[s]?:\/\/\S+');
    return linkRegex.hasMatch(text);
  }

  Future<String> getUserName(String userUID) async {
    try {
      DatabaseEvent snapshot = await FirebaseDatabase.instance
          .ref('User')
          .child(userUID)
          .once();

      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> userData = snapshot.snapshot.value as Map;
        String userName = userData['userName']; // Assuming 'userName' is the key for the user's name
        return userName;
      } else {
        return ''; // Return an empty string if user data is not found
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return ''; // Return an empty string in case of an error
    }
  }

  void saveClassData(DateTime? notificationDateTime) async {

    ProgressDialog.show(context, message: 'Saving...', icon: Icons.save_as_rounded);

    // Upload new images to Firebase Storage
    await uploadImagesToStorage();

    // Concatenate new image URLs with existing ones
    List<String> updatedImageUrls = await getImageUrls();
    updatedImageUrls.addAll(existingImageUrls); // Assuming existingImageUrls is a list of URLs for old images


    Map<String, dynamic> data = {
      'title': title,
      'note': note,
      'backgroundColor': selectedColor.value.toRadixString(16),
      'userUID': userUID,
      'imageUrls': updatedImageUrls,
    };

    if (notificationDateTime != null) {
      data['notificationDateTime'] = notificationDateTime;
    }

    classCollection
        .add(data)
        .then((documentReference) {
      print('Note added to Firestore');
    })
        .catchError((error) {
      print('Error adding note to Firestore: $error');
    });
    FirebaseFirestore.instance.collection('ActivityLogs').add({
    "title": "Note Added",
    "activity": '${await getUserName(userUID)} added a note "${title}"',
    "timestamp": Timestamp.now(),
    "userId": userUID,
    }).then((value) => Navigator.pop(context));
    ProgressDialog.hide(context);
  }

  // Method to get the download URLs of uploaded images
  Future<List<String>> getImageUrls() async {
    final storage = FirebaseStorage.instance;
    List<String> imageUrls = [];

    for (int i = 0; i < _images.length; i++) {
      String imageName = 'image_$i';
      Reference ref = storage.ref().child('images/$imageName');
      String downloadUrl = await ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }

}

