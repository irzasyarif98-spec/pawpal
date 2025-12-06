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
              child: Text(
                'Hello, ${widget.user?.userName ?? 'User'}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loadPets,
              child: const Text('Load My Pets'),
            ),
          ],
        )
      : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: loadPets,
                child: const Text('Refresh'),
              ),
            ),
            Expanded(                              
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: petsData.length,
                itemBuilder: (context, index) {
                  final pet = petsData[index];
                  return Card(
                    child: ListTile(
                      leading: Image.network(
                        '${MyConfig.baseUrl}/pawpal/api/uploads/pets/pet_${pet.petId}_1.png'
                      ),
                      title: Text('${pet.petName}, ${pet.petType}' ?? 'No name'),
                    
                      subtitle: Text(pet.category ?? ''),
                      trailing: IconButton(onPressed: () {
                        showDialog(context: context, builder: (context) {
                          return AlertDialog(
                            title: Center(child: Text(pet.petName ?? 'No Name')),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    '${MyConfig.baseUrl}/pawpal/api/uploads/pets/pet_${pet.petId}_1.png'
                                  ),
                                  SizedBox(height: 10),
                                  Text(pet.description ?? 'N/A'),
                                  
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close'),
                              ),
                            ],
                          );
                        });
                      }, icon: Icon(Icons.arrow_right)),

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

  void submitPet() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => PetSubmissionForm(user: widget.user))
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