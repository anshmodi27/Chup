import 'package:chup/helper/helper_function.dart';
import 'package:chup/pages/auth/loginpage.dart';
import 'package:chup/pages/homepage.dart';
import 'package:chup/service/authService.dart';
import 'package:chup/widgets/widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String fullName = "";
  String email = "";
  String password = "";
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color.fromRGBO(239, 181, 82, 1)),
            )
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
                        Text("Create Your account to chat & explore",
                            style: GoogleFonts.caveat(
                                textStyle: const TextStyle(
                                    fontSize: 20,
                                    color: Color.fromRGBO(241, 123, 147, 1)))),
                        Image.asset("assets/register_page.png",
                            width: 400, height: 300),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: "Name",
                              prefixIcon: Icon(
                                Icons.face,
                                color: Color.fromRGBO(239, 181, 82, 1),
                              )),
                          onChanged: (value) {
                            setState(() {
                              fullName = value;
                            });
                          },
                          validator: (value) {
                            if (value!.isNotEmpty) {
                              return null;
                            } else {
                              return "Please Enter a Name";
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: "Email",
                              prefixIcon: Icon(
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
                              Icons.how_to_reg,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              register();
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text.rich(TextSpan(
                            text: "Already have an account? ",
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 14),
                            children: <TextSpan>[
                              TextSpan(
                                text: "Login Here",
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, const LogInPage());
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

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .registerUserWithEmailPassword(fullName, email, password)
          .then((value) async {
        if (value == true) {
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(fullName);
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
