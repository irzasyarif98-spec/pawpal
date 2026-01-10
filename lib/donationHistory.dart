import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pawpal/home.dart';
import 'package:pawpal/login.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/petsubmission.dart';
import 'package:pawpal/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DonationHistory extends StatefulWidget {
  final User? user;
  final User? userProfile;
  const DonationHistory({super.key, required this.user, this.userProfile});

  @override
  State<DonationHistory> createState() => _DonationHistoryState();
}

class _DonationHistoryState extends State<DonationHistory> {
  List<Pet> petsData = [];
  String selectedCategory = 'All';
  List<Map<String, dynamic>> sentDonations = [];
  List<Map<String, dynamic>> receivedDonations = [];
  bool isLoading = true;
  String? error;
  bool sentVisible = true;

  @override
  void initState() {
    super.initState();
    loadDonationHistory();
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
                viewRequests();
              }
            ),
            ListTile(
              title: Text('Donation History'),
              onTap: () {
                Navigator.pop(context);
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
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      sentVisible = true;
                    });
                  },
                  child: const Text('Sent'),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      sentVisible = false;
                    });
                  },
                  child: const Text('Received'),
                ),
              ),
            ],
          ),
          // Sent Donations List
          Visibility(
            visible: sentVisible,
            child: Expanded(
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (error != null) {
                    return Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
                  }
                  if (sentDonations.isEmpty) {
                    return const Center(child: Text('No sent donations found.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: sentDonations.length,
                    itemBuilder: (context, index) {
                      final item = sentDonations[index];
                      final id = item['id'];
                      final donationId = item['donation_id'];
                      final amount = item['amount'];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text('Donation #$id'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Donation ID: $donationId'),
                              Text('Amount: ${amount == null || amount.toString().isEmpty ? 'Non-money' : 'RM$amount'}'),
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
          // Received Donations List
          Visibility(
            visible: !sentVisible,
            child: Expanded(
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (error != null) {
                    return Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
                  }
                  if (receivedDonations.isEmpty) {
                    return const Center(child: Text('No received donations found.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: receivedDonations.length,
                    itemBuilder: (context, index) {
                      final item = receivedDonations[index];
                      final id = item['id'];
                      final donationId = item['donation_id'];
                      final amount = item['amount'];
                      final userId = item['user_id'];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text('Donation #$id'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Donation ID: $donationId'),
                              Text('Amount: ${amount == null || amount.toString().isEmpty ? 'Non-money' : 'RM$amount'}'),
                              Text('From User: $userId'),
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
      )
    );
  }

  Future<void> loadDonationHistory() async {
    setState(() {
      isLoading = true;
      error = null;
      sentDonations.clear();
      receivedDonations.clear();
    });
    try {
      final uid = widget.user?.userId;
      if (uid == null || uid.isEmpty) {
        setState(() {
          isLoading = false;
          error = 'Missing user id';
        });
        return;
      }
      // Fetch sent donations (where user_id matches)
      final sentResponse = await http.get(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/get_donations.php?user_id=$uid'),
      );
      if (sentResponse.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(sentResponse.body);
          if (jsonResponse['status'] == 'success') {
            final data = jsonResponse['data'] as List<dynamic>;
            setState(() {
              sentDonations = List<Map<String, dynamic>>.from(data);
            });
          } else {
            setState(() {
              error = jsonResponse['message'] ?? 'Failed to load sent donations';
              isLoading = false;
            });
          }
        } on FormatException {
          setState(() {
            error = 'Invalid response format for sent donations.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Failed to load sent donations (status: ${sentResponse.statusCode})';
          isLoading = false;
        });
      }
      // Fetch received donations (where donations are for user's pets)
      // Backend should join donation_history.donation_id = donations.id
      // and filter donations.user_id == widget.user.userId (owner).
      final receivedResponse = await http.get(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/get_received_donations.php?owner_user_id=$uid'),
      );
      if (receivedResponse.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(receivedResponse.body);
          if (jsonResponse['status'] == 'success') {
            final raw = jsonResponse['data'] as List<dynamic>;
            // Ensure client-side filtering aligns with: widget.user.userId == donation.user_id
            // using donation_history.donation_id == donation.id semantics.
            // If API already filtered, this will be a no-op; otherwise it guards correctness.
            final filtered = raw.where((e) {
              final item = Map<String, dynamic>.from(e as Map);
              final ownerUserId = item['donation_owner_user_id'] ?? item['owner_user_id'] ?? item['donation_user_id'];
              if (ownerUserId != null) {
                return ownerUserId.toString() == uid.toString();
              }
              return true;
            }).toList();
            setState(() {
              receivedDonations = List<Map<String, dynamic>>.from(filtered.map((e) => Map<String, dynamic>.from(e as Map)));
              isLoading = false;
            });
          } else {
            setState(() {
              error = jsonResponse['message'] ?? 'Failed to load received donations';
              isLoading = false;
            });
          }
        } on FormatException {
          setState(() {
            error = 'Invalid response format for received donations.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error: $e';
        isLoading = false;
      });
    }
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
      MaterialPageRoute(builder: (context) => HomePage(user: widget.user))
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