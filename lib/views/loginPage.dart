import 'package:flutter/material.dart';
import 'package:proyek2/controllers/loginController.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = ''; // Error message variable

  final LoginController _loginController = LoginController();

  @override
  Widget build(BuildContext context) {
    // Logo Section
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 60.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    // Username Field
    final usernameField = TextFormField(
      controller: _usernameController,
      keyboardType: TextInputType.text,
      autofocus: false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Enter Username',
        hintStyle: TextStyle(color: Colors.white),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );

    // Password Field
    final passwordField = TextFormField(
      controller: _passwordController,
      autofocus: false,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Enter Password',
        hintStyle: TextStyle(color: Colors.white),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );

    // Login Button
    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        color: Colors.blueAccent,
        child: MaterialButton(
          minWidth: 200.0,
          height: 50.0,
          onPressed: () {
            setState(() {
              _errorMessage = ''; // Reset error message
            });

            _loginController.login(
              username: _usernameController.text,
              password: _passwordController.text,
              context: context,
              setLoading: (bool loading) {
                setState(() {
                  _isLoading = loading;
                });
              },
              showErrorDialog: (message) {
                setState(() {
                  _errorMessage = message;
                });
              },
            );
          },
          child: _isLoading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(
                  'Log In',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
        ),
      ),
    );

    // Body Design
    return Scaffold(
      backgroundColor: Colors.purple[900], // Default background color
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                logo, // Logo at the top
                SizedBox(height: 20.0),
                // Teks "Silakan masukkan username dan password"
                Text(
                  'Silakan masukkan username dan password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 30.0), // Jarak antara teks dan form
                // Message if error occurs
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 253, 127, 118),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                // Username Field
                usernameField,
                SizedBox(height: 20.0),
                // Password Field
                passwordField,
                loginButton, // Login Button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
