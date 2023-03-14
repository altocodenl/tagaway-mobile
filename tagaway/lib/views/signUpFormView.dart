import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final PageController _pageController = PageController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _repeatUserNameController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _repeatEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatpasswordController =
      TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
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
                controller: _pageController,
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
                            controller: _userNameController,
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
                          controller: _repeatUserNameController,
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
                                _pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                                FocusManager.instance.primaryFocus?.unfocus();
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
                            controller: _emailController,
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
                          controller: _repeatEmailController,
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
                              //VALIDATE EMAIL. WE CAN USE WHAT WE HAVE IN CupertinoInvite() IN AC;PIC UPLOADER
                              _pageController.animateToPage(
                                2,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                              FocusManager.instance.primaryFocus?.unfocus();
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
                            controller: _passwordController,
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
                          controller: _repeatpasswordController,
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
                                // HERE THE ACCOUNT MUST BE CREATED
                                FocusManager.instance.primaryFocus?.unfocus();
                                Navigator.pushReplacementNamed(
                                    context, LoginView.id);
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
