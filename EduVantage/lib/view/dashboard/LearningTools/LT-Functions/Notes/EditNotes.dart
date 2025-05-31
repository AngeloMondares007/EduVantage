import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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


class EditNotesScreen extends StatefulWidget {
  final QueryDocumentSnapshot noteDocument; // Add this field to store the note data

  EditNotesScreen({required this.noteDocument}); // Constructor to pass the note data

  @override
  _EditNotesScreenState createState() => _EditNotesScreenState();
}

class _EditNotesScreenState extends State<EditNotesScreen> {
  final CollectionReference classCollection = FirebaseFirestore.instance.collection('Notes');
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

  // Define the _extractLinkText function inside the _EditNotesScreenState class
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
    fetchImageUrls();

    // Initialize title, note, and selectedColor with existing data
    final data = widget.noteDocument.data()! as Map<String, dynamic>;
    title = data['title'] as String? ?? '';
    note = data['note'] as String? ?? '';
    selectedColor = Color(int.parse(data['backgroundColor'] as String? ?? '0xFF000000', radix: 16));

    // Initialize existingImageUrls with existing image URLs
    if (data.containsKey('imageUrls')) {
      existingImageUrls = List<String>.from(data['imageUrls']);
    }

    // Declare and initialize notificationDateTime to null
    DateTime? notificationDateTime;

    // Check if the 'notificationDateTime' field exists before accessing it
    final bool containsNotificationDateTime = data.containsKey('notificationDateTime');
    if (containsNotificationDateTime) {
      final notificationTimestamp = data['notificationDateTime'];
      if (notificationTimestamp != null) {
        notificationDateTime = (notificationTimestamp as Timestamp).toDate();
      }
    }
  }


  Future<void> fetchImageUrls() async {
    final data = widget.noteDocument.data()! as Map<String, dynamic>;
    if (data.containsKey('imageUrls')) {
      setState(() {
        imageUrls = List<String>.from(data['imageUrls']);
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

  void _showFullImage(String imageUrl) {
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
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Center(child: Icon(Icons.error, color: Colors.red)),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
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

  void deleteImage(int index) async {
    try {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            title: Text('Confirm Deletion', style:
            TextStyle(fontFamily: AppFonts.alatsiRegular,
                fontSize: 24, fontWeight: FontWeight.bold),),
            content: Text('Are you sure you want to delete this image?', style:
            TextStyle(fontFamily: AppFonts.alatsiRegular, fontSize: 14, fontWeight: FontWeight.normal)),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel', style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular, fontSize: 14),),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular, fontSize: 14),),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        // Proceed with image deletion
        setState(() {
          imageUrls.removeAt(index);
          existingImageUrls.removeAt(index);
        });

        // // Delete the image from Firebase Storage
        // final storage = FirebaseStorage.instance;
        // String imageName = 'image_$index';
        // Reference ref = storage.ref().child('images/$imageName');
        // await ref.delete();
        //
        // print('Image deleted from Firebase Storage');
        //
        // // Update the 'imageUrls' array in Firestore
        // await FirebaseFirestore.instance.collection('Notes')
        //     .doc(widget.noteDocument.id).update({'imageUrls': imageUrls});
        //
        // print('Image URL deleted from Firestore');

        // Show a toast message or handle success notification
        // Utils.toastMessage('Image deleted successfully');
      }
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        print('Error deleting image: Object not found');
        // Show a message or log indicating that the object was not found
      } else {
        print('Error deleting image: $e');
        // Show a generic error message or handle other Firebase errors
      }
    } catch (e) {
      print('Error deleting image: $e');
      // Show an error message or handle other non-Firebase-related errors
      // Utils.toastMessage('Error deleting image');
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
                              child: Text('OK', style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular),),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Overwrite', style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular),),
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
                              child: Text('OK', style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular),),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Save Both', style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular),),
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
                  child: Text('OK', style: TextStyle(color: Colors.black, fontFamily: AppFonts.alatsiRegular),),
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

  Future<void> checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        await Permission.manageExternalStorage.request();
      }
    }
    // Add handling for iOS permissions if needed
  }


  Future<void> fetchUserUID() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      setState(() {
        userUID = currentUser.uid;
      });
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

  Color getDateTimeColor(Color backgroundColor) {
    // Calculate the luminance of the background color
    double luminance = backgroundColor.computeLuminance();
    // Set hint text color based on luminance
    return luminance > 0.5 ? Colors.black26 : Colors.white38;
  }

  Color getLinkContainer(Color backgroundColor) {
    // Calculate the luminance of the background color
    double luminance = backgroundColor.computeLuminance();
    // Set hint text color based on luminance
    return luminance > 0.5 ? Colors.white : Colors.black;
  }




  @override
  Widget build(BuildContext context) {

    Color textColor = getTextColor(selectedColor);
    Color hintTextColor = getHintTextColor(selectedColor);
    Color dateTimeColor = getDateTimeColor(selectedColor);
    Color linkColor = getLinkContainer(selectedColor);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Edit Note", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
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
            child:IconButton(
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
                Icons.color_lens,
                color: Colors.teal,
                size: 20,
              ),
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
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  updateNoteData(); // Update note data instead of saving new data
                }
              },
              icon: Icon(
                Icons.save_as_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 15)
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
                // Add the notificationDateTime widget below the TextFormField widgets
                if (widget.noteDocument.data() is Map<String, dynamic> && (widget.noteDocument.data() as Map<String, dynamic>).containsKey('notificationDateTime'))
                  Padding(
                    padding: const EdgeInsets.only(left: 200),
                    child: Text(
                      DateFormat('MMM dd, yyyy h:mm a').format((widget.noteDocument['notificationDateTime'] as Timestamp).toDate()),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: dateTimeColor,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    cursorColor: textColor,
                    initialValue: title, // Set the initial value
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(fontSize: 24, color: hintTextColor),
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
                    initialValue: note, // Set the initial value
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Note',
                      hintStyle: TextStyle(fontSize: 18, color: hintTextColor, fontWeight: FontWeight.normal),
                      border: InputBorder.none,
                      errorStyle: TextStyle(
                        color: textColor, // Set the color for validation error text
                      ),
                    ),
                    style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.normal),
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
                // Display images using CachedNetworkImage
                if (imageUrls.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Container(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => _showFullImage(imageUrls[index]),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrls[index],
                                      placeholder: (context, url) => CircularProgressIndicator(), // Placeholder widget while loading
                                      errorWidget: (context, url, error) => Icon(Icons.error), // Error widget if image fails to load
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
                                      deleteImage(index);
                                    },
                                    child: Icon(Icons.close, color: Colors.red, size: 20),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                // Display images
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

  void updateNoteData() async {

    ProgressDialog.show(context, message: 'Saving...', icon: Icons.save_as_rounded);

    // Upload new images to Firebase Storage
    await uploadImagesToStorage();

    // Concatenate new image URLs with existing ones
    List<String> updatedImageUrls = await getImageUrls();
    updatedImageUrls.addAll(existingImageUrls); // Assuming existingImageUrls is a list of URLs for old images

    // Use the document reference from the noteDocument to update the existing note
    widget.noteDocument.reference.update({
      'title': title,
      'note': note,
      'backgroundColor': selectedColor.value.toRadixString(16),
      'imageUrls': updatedImageUrls,
    }).then((_) {
      print('Note updated in Firestore');
      // Navigate back after updating note
      Navigator.pop(context);
    }).catchError((error) {
      print('Error updating note in Firestore: $error');
    });

    // Log the activity and display a toast message
    FirebaseFirestore.instance.collection('ActivityLogs').add({
      "title": "Note Updated",
      "activity": '${await getUserName(userUID)} edited a note "${title}"',
      "timestamp": Timestamp.now(),
      "userId": userUID,
    });

    ProgressDialog.hide(context);
    Utils.toastMessage('Note ${title} updated successfully');
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
