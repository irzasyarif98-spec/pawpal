import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawpal/login.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/petsubmission.dart';
import 'package:pawpal/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final User? user;
  final User? userProfile;
  const ProfilePage({super.key, required this.user, this.userProfile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Pet> petsData = [];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    loadPets();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    TextEditingController searchController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromARGB(255, 97, 57, 43),
        title: const Text('PawPal', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Color.fromARGB(255, 255, 235, 227),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 97, 57, 43),
              ),
              child: Row(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 1),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        '${MyConfig.baseUrl}/pawpal/api/${widget.user?.profileImagePath ?? 'uploads/users/default.webp'}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 64,
                            height: 64,
                            color: Colors.white,
                            child: Icon(Icons.person, color: Colors.grey[600]),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hello, ${widget.user?.userName ?? 'User'}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                viewHome();
              },
            ),
            ListTile(
              title: Text('Submit a Pet'),
              onTap: () {
                submitPet();
              },
            ),
            ListTile(
              title: Text('Requests'),
              onTap: () {
                viewRequests();
              }
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () {
                signOut();
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(onPressed: () {
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back)),
          SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                Container(
                  width: width * 0.35,
                  height: width * 0.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 1),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      '${MyConfig.baseUrl}/pawpal/api/${widget.userProfile?.profileImagePath ?? 'uploads/users/default.webp'}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 64,
                          height: 64,
                          color: Colors.white,
                          child: Icon(Icons.person, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(widget.userProfile?.userName ?? 'User',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Email:',
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                child: Text(
                  widget.userProfile?.userEmail ?? 'N/A',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phone Number:',
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                child: Text(
                  widget.userProfile?.userPhone ?? 'N/A',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date Registered:',
                style: TextStyle(fontSize: 16),
              ),
              Expanded(
                child: Text(
                  widget.userProfile?.userRegDate ?? 'N/A',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          )
        ],
      )
    );
  }

  void requestAdoption(Pet pet) async {
    var petId = pet.petId;
    var userId = widget.user?.userId;
    var ownerId = pet.userId;

    try {
      final response = await http.get(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/get_adoptions.php?pet_id=$petId&user_id=$userId')
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success' && jsonResponse['data'].isNotEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('You have already requested to adopt this pet.'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Network Error. Please check your connection.'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    if (pet.userId.toString() == widget.user?.userId) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('You cannot adopt your own pet.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

  
    TextEditingController messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Request to Adopt'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Send a message to the pet owner'),
                const SizedBox(height: 10),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                String message = messageController.text.trim();
                if (message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Please enter a message'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                try {
                  final response = await http.post(
                    Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_adoption.php'),
                    body: {
                      'pet_id': petId.toString(),
                      'user_id': userId.toString(),
                      'owner_user_id': ownerId.toString(),
                      'message': message,
                    },
                  );

                  if (!mounted) return;
                  print(response.body);

                  if (response.statusCode == 200) {
                    try {
                      var jsonResponse = jsonDecode(response.body);
                      Navigator.of(context).pop();
                      if (jsonResponse['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Adoption request sent!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(jsonResponse['message'] ?? 'Failed to send request'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Server Error: Invalid response.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Error sending request. Please try again later.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Network Error. Please check your connection.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Send Request', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void searchPets(String query, String petType) {
    if (query.isEmpty && petType == 'All') {
      loadPets();
      return;
    }
    
    petsData.clear();
    try {
      http.get(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/get_my_pets.php?petname=$query&pettype=$petType')
      ).then((response) {
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status'] == 'success') {
            for (var pet in jsonResponse['data']) {
              petsData.add(Pet.fromJson(pet));
            }
          }
          setState(() {});
        } else {
          print('Failed to load pets. Status code: ${response.statusCode}');
        }
      });
    } catch (e) {
      print('Error loading pets: $e');
    }
  }

  void loadPets() {
    petsData.clear();
    try {
      http.get(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/get_my_pets.php')
      ).then((response) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status'] == 'success') {
            for (var pet in jsonResponse['data']) {
              petsData.add(Pet.fromJson(pet));
            }
          }
          setState(() {});
        } else {
          print('Failed to load pets. Status code: ${response.statusCode}');
        }
      });
    } catch (e) {
      print('Error loading pets: $e');
    }
  }

  void viewHome() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user))
    );
  }

  Future<void> submitPet() async {
    if (!mounted) return;
    await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => PetSubmissionForm(user: widget.user))
    );
    if (!mounted) return;
    loadPets();
  }

  void viewRequests() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RequestsPage(user: widget.user))
    );
  }

  void signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage())
    );
  }
}