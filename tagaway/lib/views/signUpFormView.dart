import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/loginView.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpFormView extends StatefulWidget {
  static const String id = 'sign_up_form_view';

  const SignUpFormView({Key? key}) : super(key: key);

  @override
  State<SignUpFormView> createState() => _SignUpFormViewState();
}

class _SignUpFormViewState extends State<SignUpFormView> {
  final PageController pageController = PageController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController repeatUserNameController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController repeatEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatpasswordController =
      TextEditingController();
  final RegExp emailValidation = RegExp(
      r"^(?=[A-Z0-9][A-Z0-9@._%+-]{5,253}$)[A-Z0-9._%+-]{1,64}@(?:(?=[A-Z0-9-]{1,63}\.)[A-Z0-9]+(?:-[A-Z0-9]+)*\.){1,8}[A-Z]{2,63}$",
      caseSensitive: false);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  launchAltocodeHome() async {
    if (!await launchUrl(Uri.parse(kAltoURL),
        mode: LaunchMode.externalApplication)) {
      throw "cannot launch url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 200,
          iconTheme: const IconThemeData(color: kAltoBlue, size: 30),
          backgroundColor: Colors.grey[50],
          elevation: 0,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'images/tag blue with white - 400x400.png',
                  scale: 4,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Create your account',
                  style: kBigTitle,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0, right: 20.0, top: 5),
                    child: Column(
                      children: [
                        const Text(
                          'Step 1 of 3',
                          style: kWhiteButtonText,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 20),
                          child: TextField(
                            controller: userNameController,
                            keyboardType: TextInputType.text,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            enableSuggestions: false,
                            decoration: const InputDecoration(
                              hintText: 'Choose your username',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: repeatUserNameController,
                          keyboardType: TextInputType.text,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                            hintText: 'Repeat your username',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: RoundedButton(
                              title: 'Next',
                              colour: kGreyDarker,
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (userNameController.text.isEmpty ||
                                    repeatUserNameController.text.isEmpty) {
                                  SnackBarGlobal.buildSnackBar(context,
                                      'Please fill both fields', 'red');
                                } else if (userNameController.text !=
                                    repeatUserNameController.text) {
                                  SnackBarGlobal.buildSnackBar(context,
                                      'Your usernames do not match', 'red');
                                } else if (userNameController.text
                                        .contains('@') ||
                                    userNameController.text.contains(':')) {
                                  SnackBarGlobal.buildSnackBar(
                                      context,
                                      'Your username cannot contain @ or :',
                                      'red');
                                } else if (userNameController.text.length < 3) {
                                  SnackBarGlobal.buildSnackBar(
                                      context,
                                      'Your username should have at least 3 characters',
                                      'red');
                                  //  HOW DO WE RESOLVE THE SPACES IN THE WEB APP SIGN UP?
                                } else if (userNameController.text ==
                                    repeatUserNameController.text) {
                                  pageController.animateToPage(
                                    1,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              }),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0, right: 20.0, top: 5),
                    child: Column(
                      children: [
                        const Text(
                          'Step 2 of 3',
                          style: kWhiteButtonText,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 20),
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            enableSuggestions: false,
                            decoration: const InputDecoration(
                              hintText: 'Your email address',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: repeatEmailController,
                          keyboardType: TextInputType.emailAddress,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                            hintText: 'Repeat your email address',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 3.0),
                          child:
                              Text('You\'ll have to validate your email later.',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: kGreyDarker,
                                  )),
                        ),
                        RoundedButton(
                            title: 'Next',
                            colour: kGreyDarker,
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (emailController.text.isEmpty ||
                                  repeatEmailController.text.isEmpty) {
                                SnackBarGlobal.buildSnackBar(
                                    context, 'Please fill both fields', 'red');
                              } else if (emailController.text !=
                                  repeatEmailController.text) {
                                SnackBarGlobal.buildSnackBar(
                                    context, 'Your emails do not match', 'red');
                              } else if (emailValidation
                                      .hasMatch(emailController.text) ==
                                  false) {
                                SnackBarGlobal.buildSnackBar(
                                    context,
                                    'Please enter a valid email address',
                                    'red');
                              } else if (emailValidation
                                      .hasMatch(emailController.text) &&
                                  emailController.text ==
                                      repeatEmailController.text) {
                                pageController.animateToPage(
                                  2,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              }
                            })
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0, right: 20.0, top: 5),
                    child: Column(
                      children: [
                        const Text(
                          'Step 3 of 3',
                          style: kWhiteButtonText,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 20),
                          child: TextField(
                            controller: passwordController,
                            keyboardType: TextInputType.text,
                            autofocus: true,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            enableSuggestions: false,
                            decoration: const InputDecoration(
                              hintText: 'Your password',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: repeatpasswordController,
                          keyboardType: TextInputType.text,
                          autofocus: true,
                          obscureText: true,
                          textAlign: TextAlign.center,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                            hintText: 'Repeat your password',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: RoundedButton(
                              title: 'Create account',
                              colour: kAltoBlue,
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (passwordController.text.isEmpty ||
                                    repeatpasswordController.text.isEmpty) {
                                  SnackBarGlobal.buildSnackBar(context,
                                      'Please fill both fields', 'red');
                                } else if (passwordController.text !=
                                    repeatpasswordController.text) {
                                  SnackBarGlobal.buildSnackBar(context,
                                      'Your passwords do not match', 'red');
                                } else if (passwordController.text.length < 6) {
                                  SnackBarGlobal.buildSnackBar(
                                      context,
                                      'Your password should have at least 6 characters',
                                      'red');
                                }
                                //  HOW DO WE RESOLVE THE SPACES IN THE WEB APP SIGN UP?
                                else if (passwordController.text ==
                                    repeatpasswordController.text) {
                                  // HERE THE ACCOUNT MUST BE CREATED
                                  AuthService.instance
                                      .signup(
                                          userNameController.text,
                                          passwordController.text,
                                          emailController.text)
                                      .then((value) {
                                    if (value == 200) {
                                      Navigator.pushReplacementNamed(
                                          context, 'login',
                                          arguments: ShowVerifyBanner(
                                              'showVerifyBanner'));
                                      userNameController.clear();
                                      repeatUserNameController.clear();
                                      emailController.clear();
                                      repeatEmailController.clear();
                                      passwordController.clear();
                                      repeatpasswordController.clear();
                                    } else if (value == 403) {
                                      //HERE WE HAVE TO MANAGE {error: 'email'}, {error: 'username'} and any other error based on 403.
                                      // SignUp Service currently does not return 'body
                                      SnackBarGlobal.buildSnackBar(context,
                                          'There has been an error', 'red');
                                    } else if (value > 500) {
                                      //CAN THIS HAPPEN?
                                      SnackBarGlobal.buildSnackBar(context,
                                          'There has been an error', 'red');
                                    }
                                    //  WHAT CODE CAN WE PUT IF THE DEVICE IS OFFLINE, SO WE NEED TO SEND USER TO OFFLINEVIEW?
                                  });
                                }
                              }),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () {
                    launchAltocodeHome();
                  },
                  child: const Text(
                    'altocode',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: kAltoBlue,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
