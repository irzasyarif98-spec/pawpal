import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pawpal/donationHistory.dart';
import 'package:pawpal/editProfile.dart';
import 'package:pawpal/login.dart';
import 'package:pawpal/models/donation.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/petsubmission.dart';
import 'package:pawpal/requests.dart';
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
  String selectedCategory = 'All';
  Donation donation = Donation();

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
              title: Text('Requests'),
              onTap: () {
                viewRequests();
              }
            ),
            ListTile(
              title: Text('Donation History'),
              onTap: () {
                viewDonationHistory();
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Edit Profile'),
              onTap: () {
                editProfile();
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.6,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search pets...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.35 ,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: <String>['All', 'Dog', 'Cat', 'Rabbit', 'Others']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue ?? 'All';
                        });
                        searchPets("", selectedCategory);
                      },
                    ),
                  )
                ],
              )
            ),
            const Text('No pets to display.', style: TextStyle(fontSize: 18)),
          ],
        )
      : Column(
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.6,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search pets...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: IconButton(onPressed: () => searchPets(searchController.text, selectedCategory), icon: Icon(Icons.search)),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.35 ,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: <String>['All', 'Dog', 'Cat', 'Rabbit', 'Others']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue ?? 'All';
                        });
                        searchPets("", selectedCategory);
                      },
                    ),
                  )
                ],
              )
            ),
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
                                            Text(pet.description ?? 'N/A'),
                                            if (pet.category == 'Donation Request') ...[
                                              FutureBuilder<Donation>(
                                                future: getDonationRequest(pet.petId!).then((data) => Donation.fromJson(data)),
                                                builder: (context, snapshot) {
                                                  donation = snapshot.data ?? Donation();
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return const CircularProgressIndicator();
                                                  } else if (snapshot.hasData) {
                                                    return Text('Donation requested: ${snapshot.data?.amount != null ? 'RM${snapshot.data!.amount!.toStringAsFixed(2)}' : snapshot.data?.description ?? 'N/A'}');
                                                  }
                                                  return const SizedBox.shrink();
                                                },
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      if (pet.category == 'Donation Request')
                                        SizedBox(
                                          width: 200,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              makeDonation(donation);
                                            },
                                            child: Text('Donate', style: TextStyle(color: Colors.white),)
                                          ),
                                        ),
                                      if (pet.category == 'Adoption')
                                        SizedBox(
                                          width: 200,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              requestAdoption(pet);
                                            },
                                            child: Text('Request to Adopt', style: TextStyle(color: Colors.white),)
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
              ),
            ),
          ],
        ),
      ),
    );
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

  void makeDonation(Donation donation) async {
    TextEditingController amountController = TextEditingController();
    Pet pet = await getPet(donation.petId!);
    double amount = 0.0;
    if (pet.userId == int.parse(widget.user!.userId ?? '0')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('You cannot donate to your own pet\'s request.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(context: context, builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Make Donation'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Donation Type: ${donation.type}'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              if (donation.type == 'Money')
                Row(
                  children: [
                    const Text('Amount: '),
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: 'Enter amount',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Text('Donation for: ${donation.description ?? 'N/A'}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () {Navigator.pop(context);}, child: Text('Cancel')),
          TextButton(
            onPressed: () {
              if (donation.type == 'Money') {
                if (amountController.text.isNotEmpty) {
                  amount = double.parse(amountController.text.trim());
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Please enter a valid donation amount.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  try {
                    http.post(
                      Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_donation.php'),
                      body: {
                        'donation_id': donation.id.toString(),
                        'amount': amount.toString(),
                        'user_id': widget.user?.userId,
                      },
                    ).then((response) {
                      if (response.statusCode == 200) {
                        var jsonResponse = jsonDecode(response.body);
                        if (jsonResponse['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('Donation successful! Thank you for your support.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(jsonResponse['message'] ?? 'Donation failed. Please try again.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Donation failed. Please try again later.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Error making donation: ${e.toString()}'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Please enter a donation amount.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                } 
                
              }
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      );
    });
  }


  Future<Map<String, dynamic>> getDonationRequest(int petId) async {
    try {
      final response = await http.get(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/get_donation_request.php?pet_id=$petId')
      );
      print(response.body);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success' && jsonResponse['data'].isNotEmpty) {
          return jsonResponse['data'][0];
        }
      }
    } catch (e) {
      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error getting donation request: ${e.toString()}.'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return {};
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

  void viewDonationHistory() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DonationHistory(user: widget.user))
    );
  }

  Future<void> editProfile() async {
    Navigator.pop(context);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage(user: widget.user)),
    );
    if (!mounted) return;
    if (result is User) {
      setState(() {
        widget.user?.userName = result.userName;
        widget.user?.userEmail = result.userEmail;
        widget.user?.userPhone = result.userPhone;
        widget.user?.profileImagePath = result.profileImagePath;
      });
    }
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