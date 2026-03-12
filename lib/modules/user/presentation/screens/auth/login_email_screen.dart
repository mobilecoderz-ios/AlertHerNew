import 'package:alert_her/core/comman_widgets/normal_text_field.dart';
import 'package:alert_her/core/comman_widgets/primary_button.dart';
import 'package:alert_her/core/comman_widgets/text_heading.dart';
import 'package:alert_her/core/comman_widgets/text_sub_heading.dart';
import 'package:alert_her/core/constants/my_colors.dart';
import 'package:alert_her/core/routes/routes.dart';
import 'package:alert_her/core/utils/sb.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isValidEmailAndPassword = false;
  bool checkedValue = false;
  bool isObscureText = true;
  Color fillColorEmail = Colors.white; // Default fill color
  Color fillColor = Colors.white; // Default fill color

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() {
      setState(() {
        fillColor = passwordController.text.isNotEmpty
            ? MyColors.primaryLight
            : MyColors.white;

        if (emailController.text.isNotEmpty &&
            passwordController.text.isNotEmpty) {
          isValidEmailAndPassword = true;
        } else {
          isValidEmailAndPassword = false;
        }
      });
    });

    emailController.addListener(() {
      setState(() {
        fillColorEmail = emailController.text.isNotEmpty
            ? MyColors.primaryLight
            : MyColors.white;
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Text.rich(
            TextSpan(
              text: 'By proceeding, you agree to AlertHer app ',
              style: TextStyle(fontSize: 14),
              children: [
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(color: MyColors.primary),
                ),
                TextSpan(text: ','),
                WidgetSpan(
                  child: SizedBox(height: 20),
                ),
                TextSpan(
                  text: 'User Agreement',
                  style: TextStyle(color: MyColors.primary),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'T&Cs.',
                  style: TextStyle(color: MyColors.primary),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 300,
                  color: MyColors.primaryLight,
                  padding: const EdgeInsets.only(top: 25, left: 25, right: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '👋 Hello!',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const TextHeading(
                            text: 'Welcome Back to ',
                            fontSize: 22,
                          ),
                          SizedBox(
                            height: 29,
                            width: 127,
                            child: Image.asset('assets/images/logo.png'),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        "Let's Login with your Email .",
                        style:
                            TextStyle(fontSize: 14, color: MyColors.blackLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 230, // Position it slightly over the header
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Align(
                          alignment: Alignment.topLeft, child: Text('Email')),
                      SB.h(10),
                      SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: NormalTextField(
                            controller: emailController,
                            hintText: 'Enter Registered Email',
                            inputType: TextInputType.emailAddress,
                            isEnabled: true,
                            fillColor: fillColorEmail,
                          )),
                      SB.h(20),
                      const Align(
                          alignment: Alignment.topLeft,
                          child: Text('Password')),
                      SB.h(10),
                      SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: NormalTextField(
                              obscureText: isObscureText,
                              controller: passwordController,
                              hintText: 'Enter Password',
                              inputType: TextInputType.text,
                              isEnabled: true,
                              onSuffixIconTap: () {
                                setState(() {
                                  isObscureText = !isObscureText;
                                });
                              },
                              iconPath: isObscureText
                                  ? 'assets/icons/password_hide.svg'
                                  : 'assets/icons/password_show.svg',
                              fillColor: fillColor)),
                      SB.h(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                checkedValue = !checkedValue;
                              });
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: checkedValue
                                      ? Image(
                                          image: AssetImage(
                                              'assets/images/check_box_on.png'))
                                      : Image.asset(
                                          'assets/images/check_box_off.png'),
                                ),
                                SB.w(10),
                                Text('Remember me')
                              ],
                            ),
                          ),
                          TextSubHeading(
                            text: 'Forget Password?',
                            color: MyColors.orange,
                          ),
                        ],
                      ),
                      SB.h(50),
                      SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            buttonText: 'Login',
                            onPressed: () {},
                            isDisabled: !isValidEmailAndPassword,
                          )),
                      SB.h(36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Login with Phone no GFJ."),
                          TextButton(
                            onPressed: () {
                              //context.go(Routes.loginMobile);
                              context.go(Routes.loginEmail);
                            },
                            child: const Text("Click Here"),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Not a user? "),
                          TextButton(
                            onPressed: () {},
                            child: const Text("Register Now"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
