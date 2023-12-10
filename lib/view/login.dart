import 'dart:convert';

import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/model/UserData.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/view/SingUpPage.dart';
import 'package:life_balancing/view/main_screen.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'ResetPassword.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool error = false;
  bool loggedIn = false;
  bool _isLoading = false;

  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    print(CashHelper.getData(key: ChangeTheme));
    if (CashHelper.getData(key: ChangeTheme) == null) {
      CashHelper.saveData(key: ChangeTheme, value: false);
      print(CashHelper.saveData(key: ChangeTheme, value: false));
    }
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back'.tr(), style: TextStyle(fontSize: 12, fontFamily: "Subjective", fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, TextEditingController textEditingController, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Subjective",
                fontSize: 18.sp,
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
          ),
          SizedBox(
            height: 10.h,
          ),
          TextField(
            controller: textEditingController,
            onChanged: (text) {
              if (textEditingController.text.isNotEmpty) {
                setState(() {
                  error = false;
                });
              }
            },
            autofocus: false,
            style: TextStyle(fontSize: 15.sp, fontFamily: "Subjective", color: Color(0xFFbdc6cf)),
            obscureText: isPassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
              errorText: textEditingController.text.isEmpty && error ? 'Value Can\'t Be Empty' : null,
              contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeWhite : AppColor.darkModeSeco),
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
        onTap: () async {
          if (emailTextEditingController.text.isNotEmpty && passwordTextEditingController.text.isNotEmpty) {
            if (emailTextEditingController.text.indexOf(".") == -1 ||
                emailTextEditingController.text.indexOf("@") == -1) {
              Toast.show(
                'Please enter valid email'.tr(),
                context,
                backgroundColor: Colors.red,
                gravity: Toast.TOP,
                duration: Toast.LENGTH_LONG,
              );
            } else {
              setState(() {
                _isLoading = true;
                error = false;
              });
              var res = await login("api/login", emailTextEditingController.text, passwordTextEditingController.text);
              // print('//////////////${res.body}');
              if (res.statusCode == 200) {
                String token = json.decode(res.body)['data']['token'];

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('token', token);

                var configRes = await config("api/configs", token);

                if (configRes != null && configRes.statusCode == 200) {
                  String name = json.decode(configRes.body)['data']['user']['name'];
                  String image = json.decode(configRes.body)['data']['user']['image'];
                  String email = json.decode(configRes.body)['data']['user']['email'];
                  bool is_active = json.decode(configRes.body)['data']['user']['is_active'];
                  await prefs.setString('name', name);
                  await prefs.setString('image', image);
                  await prefs.setString('email', email);
                  await prefs.setBool("is_active", is_active);
                  print("is_Active$is_active");
                  setState(() {
                    _isLoading = false;
                  });
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainScreen(
                                TabId: 2,
                              )),
                      (route) => false);
                } else {
                  setState(() {
                    _isLoading = false;
                  });
                  Toast.show(
                    'Network Error'.tr(),
                    context,
                    backgroundColor: Colors.red,
                    gravity: Toast.BOTTOM,
                    duration: Toast.LENGTH_LONG,
                  );
                }

                setState(() {
                  _isLoading = false;
                });
              } else if (res.statusCode == 403) {
                setState(() {
                  _isLoading = false;
                });
                Toast.show(
                  json.decode(res.body)['message'],
                  context,
                  backgroundColor: Colors.red,
                  gravity: Toast.TOP,
                  duration: Toast.LENGTH_LONG,
                );
              }
            }
          } else {
            setState(() {
              error = true;
            });
          }
        },
        child: Container(
          width: 316.w,
          height: 50.h,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              // boxShadow: <BoxShadow>[
              //   BoxShadow(
              //       color: Colors.grey.shade200,
              //       offset: Offset(2, 4),
              //       blurRadius: 5,
              //       spreadRadius: 2)
              // ],
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
          child: Text(
            'Login'.tr(),
            style: TextStyle(
                fontSize: 18.sp,
                fontFamily: "Subjective",
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
          ),
        ));
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width / 18,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 2,
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeWhite : AppColor.darkModeSeco,
              ),
            ),
          ),
          Text('or'.tr(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width / 25,
                  fontFamily: "Subjective",
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).padding.horizontal + 10),
              child: Divider(
                thickness: 2,
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeWhite : AppColor.darkModeSeco,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 18,
          ),
        ],
      ),
    );
  }

  Widget _facebookButton() {
    return InkWell(
      onTap: () async {
        final result = await FacebookAuth.i.login(permissions: ["public_profile", "email"]);
        if (result.status == LoginStatus.success) {
          final requestData = await FacebookAuth.i.getUserData();
          // var prefs = await SharedPreferences.getInstance();
          var userData = UserData.fromJson(requestData);
          print(userData.toString());
        }
      },
      child: Container(
        height: 50.h,
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF3949AA),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100), topLeft: Radius.circular(100)),
                ),
                alignment: Alignment.center,
                child: Image(
                  image: AssetImage("assets/images/facebook.png"),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF3949AA),
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(100), topRight: Radius.circular(100)),
                ),
                alignment: Alignment.center,
                child: Text('Log in with Facebook'.tr(),
                    style: TextStyle(
                        color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                        fontSize: 15.sp,
                        fontFamily: "Subjective",
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SingUpPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Don\'t have an account ?'.tr(),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 25,
                    fontFamily: "Subjective",
                    fontWeight: FontWeight.w600,
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Register'.tr(),
                  style: TextStyle(
                      color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                      fontSize: MediaQuery.of(context).size.width / 25,
                      fontFamily: "Subjective",
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPassword()));
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.centerLeft,
                child: Text('Forgot Password ?'.tr(),
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 25,
                        fontFamily: "Subjective",
                        fontWeight: FontWeight.w500,
                        color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Image.asset(
      'assets/images/logo1.png',
      height: 150.h,
    );
  }

//'assets/images/logo1.png',
  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Emile".tr(), emailTextEditingController),
        _entryField("Password".tr(), passwordTextEditingController, isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
        body: LoadingOverlay(
          child: Padding(
            padding: EdgeInsets.only(
              right: 10.w,
              left: 10.w,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Stack(
                  children: <Widget>[
                    // Positioned(
                    //     top: -height * .15,
                    //     right: -MediaQuery.of(context).size.width * .4,
                    //     child: BezierContainer()),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 10.h),
                            _title(),
                            // SizedBox(height: 50),
                            _emailPasswordWidget(),
                            SizedBox(height: 10.h),
                            _submitButton(),
                            SizedBox(height: 10.h),
                            _divider(),
                            _facebookButton(),
                            // SizedBox(height: height * .055),
                            _createAccountLabel(),
                          ],
                        ),
                      ),
                    ),
                    // Positioned(top: 40, left: 0, child: _backButton()),
                  ],
                ),
              ),
            ),
          ),
          isLoading: _isLoading,
          // additional parameters
          opacity: 0.5,
          color: Colors.grey,
          progressIndicator: CircularProgressIndicator(),
        ));
  }
}
