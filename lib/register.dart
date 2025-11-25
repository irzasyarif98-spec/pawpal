import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pawpal/login.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/myconfig.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  late double height, width;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    print(width);
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
                      Center(
                        child: Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Email Address'),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Color.fromARGB(255, 255, 248, 245),
                          prefixIconColor: Color.fromARGB(255, 97, 57, 43),
                          prefixIcon: Icon(Icons.email)
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('Name'),
                      TextField(
                        controller: nameController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Color.fromARGB(255, 255, 248, 245),
                          prefixIconColor: Color.fromARGB(255, 97, 57, 43),
                          prefixIcon: Icon(Icons.person)
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('Phone Number'),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter your phone number',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Color.fromARGB(255, 255, 248, 245),
                          prefixIconColor: Color.fromARGB(255, 97, 57, 43),
                          prefixIcon: Icon(Icons.phone_iphone)
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      Text('Password'),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Color.fromARGB(255, 255, 248, 245),
                          prefixIconColor: Color.fromARGB(255, 97, 57, 43),
                          prefixIcon: Icon(Icons.lock)
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      Text('Confirm Password'),
                      TextField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          hintText: 'Re-enter your password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Color.fromARGB(255, 255, 248, 245),
                          prefixIconColor: Color.fromARGB(255, 97, 57, 43),
                          prefixIcon: Icon(Icons.lock)
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 40),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 35,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 97, 57, 43),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              registerDialog();
                            },
                            child: Text('Register', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text('Already have an account?'),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                              setState(() {});
                            },
                            child: Text(' Sign in', style: TextStyle(color: Colors.blue))
                          ),
                        ],
                      )
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

  void registerDialog() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || name.isEmpty || phone.isEmpty) {
      SnackBar snackBar = const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Please fill in all details.'),
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      SnackBar snackBar = const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Enter a valid email address'),
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (password.length < 6) {
      SnackBar snackBar = const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Password must at least contain 6 characters.'),
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (password != confirmPassword) {
      SnackBar snackBar = const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Passwords do not match.'),
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    registerUser(email, password, name, phone);
  }

  void registerUser(String email, String password, String name, String phone) async {
    setState(() {
      isLoading = true;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Registering...'),
            ],
          ),
        );
      },
      barrierDismissible: false,
    );

    await http.post(
      Uri.parse("${MyConfig.baseUrl}/pawpal/api/register_user.php"),
      body: {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      },
    ).then((response) {
      var jsonResponse = response.body;
      var responseArr = jsonDecode(jsonResponse);
      if (response.statusCode == 200) {
        if (responseArr['status'] == 'success') {
          emailController.clear();
          nameController.clear();
          phoneController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          
          if (!mounted) return;
          if (isLoading) {
            Navigator.pop(context);
            setState(() {
              isLoading = false;
            });
          }

          showDialog(
            context: context, 
            builder: (context) => AlertDialog(
              title: Text('Registration Successful'),
              content: Text('You have registered successfully. Please sign in to continue.'),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const LoginPage())
                    );
                  }, 
                  child: Text('Continue')
                )
              ],
            )
          );
        } else {
          SnackBar snackBar = SnackBar(
            backgroundColor: Colors.red,
            content: Text(responseArr['message']),
            duration: Duration(seconds: 3),
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return;
        }
      } else {
        SnackBar snackBar = const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error registering user. Please try again later.'),
          duration: Duration(seconds: 3),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
        }
      }).timeout(
        Duration(seconds: 10),  
        onTimeout: () {
          SnackBar snackBar = const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Request timed out. Please try again.'),
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      );

    if (isLoading) {
      if (!mounted) return;
      Navigator.pop(context); // Close the loading dialog
      setState(() {
        isLoading = false;
      });
    }
  }
}