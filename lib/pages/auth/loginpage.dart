import 'package:chup/helper/helper_function.dart';
import 'package:chup/pages/auth/registerpage.dart';
import 'package:chup/pages/homepage.dart';
import 'package:chup/service/authService.dart';
import 'package:chup/service/databaseService.dart';
import 'package:chup/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color.fromRGBO(239, 181, 82, 1)))
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                  key: formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Chup!",
                            style: GoogleFonts.sacramento(
                                textStyle: const TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 10,
                                    color: Color.fromRGBO(125, 168, 206, 1)))),
                        const SizedBox(height: 10),
                        Text("Login to see what the talking",
                            style: GoogleFonts.caveat(
                                textStyle: const TextStyle(
                                    fontSize: 20,
                                    color: Color.fromRGBO(241, 123, 147, 1)))),
                        Image.asset("assets/login_page.png",
                            width: 400, height: 300),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: "Email",
                              prefixIcon: const Icon(
                                Icons.alternate_email,
                                color: Color.fromRGBO(239, 181, 82, 1),
                              )),
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          },
                          validator: (value) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value!)
                                ? null
                                : "Enter Valid Email!";
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          obscureText: true,
                          decoration: textInputDecoration.copyWith(
                              labelText: "Password",
                              prefixIcon: Icon(
                                Icons.key,
                                color: Color.fromRGBO(239, 181, 82, 1),
                              )),
                          validator: (val) {
                            if (val!.length < 6) {
                              return "Password must be at least 6 characters!";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          width: 70,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Color.fromRGBO(239, 181, 82, 1),
                                // elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40))),
                            child: const Icon(
                              Icons.login,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              login();
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text.rich(TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 14),
                            children: <TextSpan>[
                              TextSpan(
                                text: "Register Here",
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, const RegisterPage());
                                  },
                                style: const TextStyle(
                                  color: Colors.black87,
                                ),
                              )
                            ]))
                      ]),
                ),
              ),
            ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginWithUserNameAndPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .gettingUserData(email);
          // saving the values to our shared preferences
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(snapshot.docs[0]['fullName']);
          nextScreenReplacement(context, const HomePage());
        } else {
          ShowSnackbar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
