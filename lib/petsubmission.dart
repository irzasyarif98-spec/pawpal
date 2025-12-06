import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class PetSubmissionForm extends StatefulWidget {
  final User? user;
  const PetSubmissionForm({super.key, required this.user});

  @override
  State<PetSubmissionForm> createState() => _PetSubmissionFormState();
}

class _PetSubmissionFormState extends State<PetSubmissionForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<String> petCategories = ['Cat', 'Dog', 'Rabbit', 'Others'];
  List<String> submissionCategories = ['Adoption', 'Donation Request', 'Help/Rescue'];
  String? selectedPetType;
  String? selectedCategory;
  late double height, width;
  List<File> imageFiles = [];
  List<Uint8List> webImageFiles = [];
  List<String> base64Images = [];  // Store base64 strings immediately
  String? lat, long;
  bool hasPic1 = false;
  bool hasPic2 = false;
  bool hasPic3 = false;

  @override
  void initState() {
    super.initState();
    //imageFiles = [];
    //webImageFiles = [];

  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    if (width > 400) {
      width = 400;
    } else {
      width = width;
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 97, 57, 43),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: width,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 235, 227),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                         icon: Icon(Icons.arrow_back)),
                      Center(
                        child: Text(
                          'Pet Submission Form',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 97, 57, 43),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(5),
                            image: (imageFiles.isEmpty && webImageFiles.isEmpty)
                                ? null
                                : DecorationImage(
                                    image: kIsWeb
                                        ? MemoryImage(webImageFiles[0])
                                        : FileImage(imageFiles[0]),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: Visibility(
                              visible: !hasPic1,
                              child: IconButton(
                                onPressed: () {
                                  if (kIsWeb) {
                                    openGallery();
                                  } else {
                                    pickImageDialog();
                                  }
                                }, 
                                icon: Icon(Icons.camera_alt_outlined, size: 50)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Visibility(
                        visible: hasPic1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(5),
                                image: (!hasPic2)
                                    ? null
                                    : DecorationImage(
                                        image: kIsWeb
                                            ? MemoryImage(webImageFiles[1])
                                            : FileImage(imageFiles[1]),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              child: SizedBox(
                                width: 75,
                                height: 75,
                                child: Visibility(
                                  visible: !hasPic2,
                                  child: IconButton(
                                    onPressed: () {
                                      if (kIsWeb) {
                                        openGallery();
                                      } else {
                                        pickImageDialog();
                                      }
                                    }, 
                                    icon: Icon(Icons.camera_alt_outlined, size: 30)),
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(5),
                                image: (!hasPic3)
                                    ? null
                                    : DecorationImage(
                                        image: kIsWeb
                                            ? MemoryImage(webImageFiles[2])
                                            : FileImage(imageFiles[2]),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              child: SizedBox(
                                width: 75,
                                height: 75,
                                child: Visibility(
                                  visible: (hasPic2 && !hasPic3),
                                  child: IconButton(
                                    onPressed: () {
                                      if (kIsWeb) {
                                        openGallery();
                                      } else {
                                        pickImageDialog();
                                      }
                                    }, 
                                    icon: Icon(Icons.camera_alt_outlined, size: 30)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text("Category")
                          ),
                          DropdownButton(
                            value: selectedCategory,
                            hint: Text('Select a category'),
                            items: submissionCategories.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(), 
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategory = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 15), 
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text("Pet Type")
                          ),
                          DropdownButton(
                            value: selectedPetType,
                            hint: Text('Select your pet type'),
                            items: petCategories.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(), 
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedPetType = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text("Pet Name")
                          ),
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter pet name',
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text("Description")
                          ),
                          Expanded(
                            child: TextField(
                              controller: descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter pet description',
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 10),
                      
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            submitDialog();
                          }, 
                          child: Text('Submit')
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }

  void submitDialog() {
    if (nameController.text.trim().isEmpty || selectedPetType == null || selectedCategory == null || descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please fill in all details.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    if (descriptionController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Description must be at least 10 characters long.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    if (!hasPic1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Upload at least one image of the pet.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    submitPet();
  }

  void submitPet() async {

    if (!kIsWeb) {
      await _determinePosition().then((position) {
        setState(() {
          lat = position.latitude.toString();
          long = position.longitude.toString();
        });
        print('Location obtained - Lat: $lat, Long: $long');
      }).catchError((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error getting location.'),
          duration: Duration(seconds: 3),
        ),
      );
      print('Location error: $e');
      });
    }

    // Use pre-encoded base64 images instead of encoding now
    String petName = nameController.text.trim();
    String petType = selectedPetType!;
    String submissionCategory = selectedCategory!;
    String petDescription = descriptionController.text.trim();

    http.post(
      Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_pet.php'),
      body: {
        'userid': widget.user!.userId,
        'petname': petName,
        'pettype': petType,
        'category': submissionCategory,
        'description': petDescription,
        'image1': base64Images.length > 0 ? base64Images[0] : '',
        'image2': base64Images.length > 1 ? base64Images[1] : '',
        'image3': base64Images.length > 2 ? base64Images[2] : '',
        'lat': lat ?? '',
        'long': long ?? '',
      },
    ).then((response) {
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        print(response.body);
        var jsonResponse = response.body;
        var responseArr = jsonDecode(jsonResponse);
        if (responseArr['status'] == 'success') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Pet submission successful!'),
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Pet submission failed. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Server error. Please try again later.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void refreshImageView() {
    if (imageFiles.isEmpty && webImageFiles.isEmpty) {
      return;
    }
    if (kIsWeb) {
      if (webImageFiles.isNotEmpty) hasPic1 = true;
      if (webImageFiles.length >= 2) hasPic2 = true;
      if (webImageFiles.length >= 3) hasPic3 = true;
      setState(() {});
    } else {
      if (imageFiles.isNotEmpty) hasPic1 = true;
      if (imageFiles.length >= 2) hasPic2 = true;
      if (imageFiles.length >= 3) hasPic3 = true;
      setState(() {});
    }
  }

  Future<void> openGallery() async {
    if (imageFiles.length >= 3 || webImageFiles.length >= 3) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('You can only upload up to 3 images.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

    final picker = ImagePicker();
    final pickedImages = await picker.pickImage(
      imageQuality: 90,
      source: ImageSource.gallery,
    );
    //List<File>? imageFiles = [];

    if (pickedImages != null) {
      if (kIsWeb) {
        //webImage = await pickedFile.readAsBytes();
        //for (final xfile in pickedImages) {
        final bytes = await pickedImages.readAsBytes();
        webImageFiles.add(bytes);
        base64Images.add(base64Encode(bytes));
        //}
        setState(() {});
      } else {
        //image = File(pickedFile.path);
        //imageFiles.addAll(pickedImages.map((file) => File(file.path)).toList());
        imageFiles.add(File(pickedImages.path));
        base64Images.add(base64Encode(await File(pickedImages.path).readAsBytes()));
      }
    }
    refreshImageView();
    print(imageFiles.length);
    print(webImageFiles.length);
  }
  
  Future<void> openCamera() async {
    if (imageFiles.length >= 3 || webImageFiles.length >= 3) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('You can only upload up to 3 images.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        webImageFiles.add(bytes);
        base64Images.add(base64Encode(bytes));
        setState(() {});
      } else {
        imageFiles.add(File(pickedFile.path));
        // Convert to base64 immediately after taking photo
        final bytes = await File(pickedFile.path).readAsBytes();
        base64Images.add(base64Encode(bytes));
      }
    }
    refreshImageView();
  }

  void pickImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  openCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  openGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    if (!mounted) return Future.error('Location services are disabled.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text('Location services are disabled. Please enable the services.'),
        duration: Duration(seconds: 3),
      ),
    );
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      if (!mounted) return Future.error('Location permissions are denied');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text('Location permissions are denied.'),
        duration: Duration(seconds: 3),
      ),
    );
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    if (!mounted) return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text('Location permissions are permanently denied.'),
        duration: Duration(seconds: 3),
      ),
    );
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
}