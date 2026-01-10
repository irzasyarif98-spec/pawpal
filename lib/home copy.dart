import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawpal/login.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/petsubmission.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final User? user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Pet> petsData = [];

  @override
  void initState() {
    super.initState();
    loadPets();
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    'Hello, ${widget.user?.userName ?? 'User'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Image.network(
                    '${MyConfig.baseUrl}/pawpal/api/${widget.user?.profileImagePath ?? 'uploads/users/default.webp'}',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.white,
                        child: Icon(Icons.person, color: Colors.grey[600]),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Submit a Pet'),
              onTap: () {
                submitPet();
              },
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
      body: Center(
  child: petsData.isEmpty
      ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No pets to display.', style: TextStyle(fontSize: 18)),
          ],
        )
      : Column(
          children: [
            Expanded(                              
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: petsData.length,
                itemBuilder: (context, index) {
                  final pet = petsData[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              '${MyConfig.baseUrl}/pawpal/api/${pet.imagePaths?[0] ?? 'uploads/pets/placeholder.png'}',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.white,
                                  child: Icon(Icons.pets, color: Colors.grey[600]),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${pet.petName}, ${pet.petType}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  pet.category ?? 'No category',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  pet.description ?? 'No description available',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Center(child: Text(pet.petName ?? 'No Name')),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.network(
                                            '${MyConfig.baseUrl}/pawpal/api/${pet.imagePaths?[0] ?? 'uploads/pets/placeholder.png'}',
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 200,
                                                height: 200,
                                                color: Colors.grey[300],
                                                child: Icon(Icons.pets, size: 80, color: Colors.grey[600]),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          Text(pet.description ?? 'N/A'),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.arrow_forward_ios, size: 20),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void loadPets() {
    String userId = widget.user!.userId!;
    petsData.clear();
    try {
      http.get(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/get_my_pets.php?user_id=$userId')
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

  Future<void> submitPet() async {
    if (!mounted) return;
    await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => PetSubmissionForm(user: widget.user))
    );
    if (!mounted) return;
    loadPets();
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