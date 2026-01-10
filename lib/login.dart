import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/register.dart';
import 'package:pawpal/home.dart';
import 'package:pawpal/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late double height, width;
  bool isChecked = false;
  bool isLoading = false;

  late User user;

  @override
  void initState() {
    super.initState();
    loadPreferences();
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
                    children: [
                      Center(
                        child: Text(
                          'Sign In',
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
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          filled: true,
                          fillColor: Color.fromARGB(255, 255, 248, 245),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixIcon: Icon(Icons.email),
                          prefixIconColor: Color.fromARGB(255, 97, 57, 43)
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('Password'),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          filled: true,
                          fillColor: Color.fromARGB(255, 255, 248, 245),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixIcon: Icon(Icons.lock),
                          prefixIconColor: Color.fromARGB(255, 97, 57, 43)
                        ),
                        obscureText: true,
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            onChanged: (value) {
                              isChecked = value!;
                              setState(() {});
                              if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                                prefUpdate(isChecked);
                              }
                            },
                          ),
                          Text('Remember Me'),
                        ],
                      ),
                      SizedBox(height: 15),
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
                              loginUser();
                            },
                            child: Text('Sign In', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text('Don\'t have an account?'),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                              setState(() {});
                            },
                            child: Text(' Register', style: TextStyle(color: Colors.blue))
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

  void prefUpdate(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      prefs.setString('email', emailController.text);
      prefs.setString('password', passwordController.text);
      prefs.setBool('rememberMe', true);
    } else {
      prefs.remove('email');
      prefs.remove('password');
      prefs.remove('rememberMe');
    }
  }

  void loadPreferences() {
    SharedPreferences.getInstance().then((prefs) {
      bool? rememberMe = prefs.getBool('rememberMe');
      if (rememberMe != null && rememberMe) {
        String? email = prefs.getString('email');
        String? password = prefs.getString('password');
        emailController.text = email ?? '';
        passwordController.text = password ?? '';
        isChecked = true;
        setState(() {});
        loginUser();
      }
    });
  }

  void loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please fill in all fields.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    setState(() {
      isLoading = true;
    });

    _showLoadingDialog('Signing In...');

    try {
      final response = await http
          .post(
            Uri.parse('${MyConfig.baseUrl}/pawpal/api/login_user.php'),
            body: {
              'email': email,
              'password': password,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var jsonResponse = response.body;
        var responseArr = jsonDecode(jsonResponse);
        if (responseArr['status'] == 'success') {
          user = User.fromJson(responseArr['data'][0]);

          _closeLoadingDialog();
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(user: user)),
          );
        } else {
          _closeLoadingDialog();
          _showConnectionError(responseArr['message']);
        }
      } else {
        _closeLoadingDialog();
        _showConnectionError('Error signing in. Please try again later.');
      }
    } on TimeoutException {
      _closeLoadingDialog();
      _showConnectionError('Request timed out. Please check your connection and try again.');
    } catch (e) {
      _closeLoadingDialog();
      _showConnectionError('Unable to reach the server. Please check your connection.');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  void _closeLoadingDialog() {
    if (!mounted) return;
    if (isLoading && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    setState(() {
      isLoading = false;
    });
  }

  void _showConnectionError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}