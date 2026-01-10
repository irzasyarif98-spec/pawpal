import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawpal/donationHistory.dart';
import 'package:pawpal/home.dart';
import 'package:pawpal/login.dart';
import 'package:pawpal/models/adoption.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/petsubmission.dart';
import 'package:pawpal/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RequestsPage extends StatefulWidget {
  final User? user;
  const RequestsPage({super.key, required this.user});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  List<Pet> petsData = [];
  List<Adoption> sentRequests = [];
  List<Adoption> incomingRequests = [];
  String selectedCategory = 'All';
  bool sentVisible = true;

  @override
  void initState() {
    super.initState();
    loadAdoptions();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
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
                Navigator.pop(context);
              }
            ),
            ListTile(
              title: Text('Donation History'),
              onTap: () {
                viewDonationHistory();
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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width*0.45, 
                child: TextButton(onPressed: () {
                  setState(() {
                    sentVisible = true;
                  });
                }, child: Text('Sent'))),
              SizedBox(
                width: width*0.45, 
                child: TextButton(onPressed: () {
                  setState(() {
                    sentVisible = false;
                  });
                }, child: Text('Received'))),
              
            ],
          ),
          // Sent Requests List
          Visibility(
            visible: sentVisible,
            child: Expanded(                              
              child: sentRequests.isEmpty
                ? const Center(
                    child: Text(
                      'No pending requests',
                      ),
                  )
                : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: sentRequests.length,
                itemBuilder: (context, index) {
                  final adoption = sentRequests[index];
                  return FutureBuilder<Map<String, dynamic>>(
                    future: Future.wait([
                      getPet(adoption.petId!),
                      getUser(adoption.ownerUserId!)
                    ]).then((results) => {
                      'pet': results[0],
                      'user': results[1]
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Card(
                          child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                        );
                      }
                      final pet = snapshot.data?['pet'] ?? Pet(petName: 'Unknown', petType: 'Unknown', description: 'Unknown');
                      final user = snapshot.data?['user'] ?? User();
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
                                    backgroundColor: Colors.white,
                                    title: Center(child: Text(pet.petName ?? 'No Name')),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (pet.imagePaths != null && pet.imagePaths!.isNotEmpty)
                                              ...pet.imagePaths!.map((imagePath) => Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: Image.network(
                                                  '${MyConfig.baseUrl}/pawpal/api/$imagePath',
                                                  width: 250,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: 250,
                                                      height: 200,
                                                      color: const Color.fromARGB(255, 255, 255, 255),
                                                      child: Icon(Icons.pets, size: 80, color: Colors.grey[600]),
                                                    );
                                                  },
                                                ),
                                              )).toList()
                                            else
                                              Container(
                                                width: 250,
                                                height: 200,
                                                color: const Color.fromARGB(255, 255, 255, 255),
                                                child: Icon(Icons.pets, size: 80, color: Colors.grey[600]),
                                              ),
                                            const SizedBox(height: 10),
                                            Text('Your message: ${adoption.message ?? 'N/A'}'),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      if (adoption.status == 'pending')
                                        SizedBox(
                                          width: 200,
                                          child: Text( 
                                            'Waiting for ${user.userName} to respond...'
                                          )
                                        )
                                      else if (adoption.status == 'approved')
                                        SizedBox(
                                          width: 200,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.push(
                                                context, 
                                                MaterialPageRoute(
                                                  builder: (context) => ProfilePage(
                                                    user: widget.user,
                                                    userProfile: user,
                                                  )
                                                )
                                              );
                                            },
                                            child: Text('Contact Details', style: TextStyle(color: Colors.white),)
                                          ),
                                        )
                                      else if (adoption.status == 'rejected')
                                        SizedBox(
                                          width: 200,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Rejected', style: TextStyle(color: Colors.white),)
                                          ),
                                        ),
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
                  );
                },
              ),
            ),
          ),
          
          // Received Requests List
          Visibility(
            visible: !sentVisible,
            child: Expanded(                              
              child: incomingRequests.isEmpty
                ? const Center(
                    child: Text(
                      'No pending requests',
                      ),
                  )
                : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: incomingRequests.length,
                itemBuilder: (context, index) {
                  final adoption = incomingRequests[index];
                  return FutureBuilder<Map<String, dynamic>>(
                    future: Future.wait([
                      getPet(adoption.petId!),
                      getUser(adoption.adopterId!)
                    ]).then((results) => {
                      'pet': results[0],
                      'user': results[1]
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Card(
                          child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                        );
                      }
                      final pet = snapshot.data?['pet'] ?? Pet(petName: 'Unknown', petType: 'Unknown', description: 'Unknown');
                      final user = snapshot.data?['user'] ?? User();
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
                                    backgroundColor: Colors.white,
                                    title: Center(child: Text(pet.petName ?? 'No Name')),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (pet.imagePaths != null && pet.imagePaths!.isNotEmpty)
                                              ...pet.imagePaths!.map((imagePath) => Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: Image.network(
                                                  '${MyConfig.baseUrl}/pawpal/api/$imagePath',
                                                  width: 250,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: 250,
                                                      height: 200,
                                                      color: const Color.fromARGB(255, 255, 255, 255),
                                                      child: Icon(Icons.pets, size: 80, color: Colors.grey[600]),
                                                    );
                                                  },
                                                ),
                                              )).toList()
                                            else
                                              Container(
                                                width: 250,
                                                height: 200,
                                                color: const Color.fromARGB(255, 255, 255, 255),
                                                child: Icon(Icons.pets, size: 80, color: Colors.grey[600]),
                                              ),
                                            const SizedBox(height: 10),
                                            Text('Incoming message: ${adoption.message ?? 'N/A'}'),
                                            TextButton(onPressed: (){
                                              Navigator.of(context).pop();
                                              Navigator.push(
                                                context, 
                                                MaterialPageRoute(
                                                  builder: (context) => ProfilePage(
                                                    user: widget.user,
                                                    userProfile: user,
                                                  )
                                                )
                                              );
                                            }, child: Text('View profile.'))
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      if (adoption.status == 'pending')
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 120,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                ),
                                                onPressed: () async {
                                                  // Approve adoption
                                                  setState(() {
                                                    adoption.status = 'approved';
                                                  });
                                                  Navigator.of(context).pop();
                                                  await updateAdoptionStatus(adoption);
                                                },
                                                child: Text('Approve', style: TextStyle(color: Colors.white),)
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            SizedBox(
                                              width: 120,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                onPressed: () async {
                                                  // Reject adoption
                                                  setState(() {
                                                    adoption.status = 'rejected';
                                                  });
                                                  Navigator.of(context).pop();
                                                  await updateAdoptionStatus(adoption);
                                                },
                                                child: Text('Reject', style: TextStyle(color: Colors.white),)
                                              ),
                                            ),
                                          ],
                                        )
                                      else if (adoption.status == 'approved')
                                        SizedBox(
                                          width: 200,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.push(
                                                context, 
                                                MaterialPageRoute(
                                                  builder: (context) => ProfilePage(
                                                    user: widget.user,
                                                    userProfile: user,
                                                  )
                                                )
                                              );
                                            },
                                            child: Text('Contact Details', style: TextStyle(color: Colors.white),)
                                          ),
                                        )
                                      else if (adoption.status == 'rejected')
                                        SizedBox(
                                          width: 200,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Rejected', style: TextStyle(color: Colors.white),)
                                          ),
                                        ),
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<User> getUser(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/get_user.php?user_id=$id')
      );
      if (response.statusCode == 200) {
        print(response.body);
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success' && jsonResponse['data'].isNotEmpty) {
          return User.fromJson(jsonResponse['data'][0]);
        }
      }
    } catch (e) {
      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error loading user data: $e. Please try again later'),
        duration: Duration(seconds: 2),
      );
      if (!mounted) return User();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return User();
  }

  Future<Pet> getPet(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/get_my_pets.php?pet_id=$id')
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success' && jsonResponse['data'].isNotEmpty) {
          return Pet.fromJson(jsonResponse['data'][0]);
        }
      }
    } catch (e) {
      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error loading pet data: $e. Please try again later'),
        duration: Duration(seconds: 2),
      );
      if (!mounted) return Pet();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return Pet();
  }

  Future<void> loadAdoptions() async {
    var userId = widget.user?.userId;
    incomingRequests.clear();
    sentRequests.clear();
    try {
      final response = await http.get(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/get_adoptions.php?user_id=$userId')
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          for (var adoption in jsonResponse['data']) {
            sentRequests.add(Adoption.fromJson(adoption));
          }
        }
        setState(() {});
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

    try {
      final response = await http.get(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/get_adoptions.php?owner_user_id=$userId&approved=null')
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          for (var adoption in jsonResponse['data']) {
            incomingRequests.add(Adoption.fromJson(adoption));
          }
        }
        setState(() {});
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
  }

  Future<void> updateAdoptionStatus(Adoption adoption) async {
    if (adoption.adoptionId == null) return;

    String? approved;
    if (adoption.status == 'approved') {
      approved = '1';
    } else if (adoption.status == 'rejected') {
      approved = '0';
    } else {
      approved = 'null';
    }

    try {
      await http.post(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/update_adoption.php'),
        body: {
          'adoption_id': adoption.adoptionId.toString(),
          'approved': approved,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to update adoption: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void viewHome() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(user: widget.user))
    );
  }

  void loadPets() {
    petsData.clear();
    try {
      http.get(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/get_my_pets.php')
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
          SnackBar snackBar = const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to load pets. Please try again later.'),
            duration: Duration(seconds: 2),
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
    } catch (e) {
      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error loading pets: $e. Please try again later'),
        duration: Duration(seconds: 2),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void viewDonationHistory() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DonationHistory(user: widget.user))
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