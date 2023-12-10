import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/ScreenHelper.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'main_screen.dart';

class SingUpPage extends StatefulWidget {
  @override
  _SingUpPageState createState() => _SingUpPageState();
}

class _SingUpPageState extends State<SingUpPage> {
  var imageSelected;
  File imagefile;
  String image;
  String image_Name = "assets/images/temp@2x.png";

  bool error = false, _isLoading = false;

  String errorEmile;
  String errorUserName;

  TextEditingController passwordTextEditingController = new TextEditingController();
  TextEditingController con_passwordTextEditingController = new TextEditingController();
  TextEditingController NameTextEditingController = new TextEditingController();
  TextEditingController UserNameTextEditingController = new TextEditingController();
  TextEditingController emailTextEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return Scaffold(
      body: LoadingOverlay(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                right: ScreenHelper.fromWidth(4.0),
                left: ScreenHelper.fromWidth(4.0),
              ),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20.h,
                    ),
                    build_Profile_Image(),
                    SizedBox(
                      height: 10.h,
                    ),
                    build_SingUp_Info(),
                    SizedBox(
                      height: 20.h,
                    ),
                    _submitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
        isLoading: _isLoading,
        // additional parameters
        opacity: 0.5,
        color: Colors.grey,
        progressIndicator: CircularProgressIndicator(),
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
        onTap: () async {
          setState(() {
            _isLoading = true;
            error = false;
          });
          print("pressed");
          var filename;

          if (!(["", null, false, 0].contains(imageSelected))) {
            filename = await SaveFile("api/save-file", imageSelected);
          }

          print(filename);
          // print(res.body);
          print(imageSelected);
          if (/*UserNameTextEditingController.text.isNotEmpty &&*/
              passwordTextEditingController.text.isNotEmpty &&
                  con_passwordTextEditingController.text.isNotEmpty &&
                  NameTextEditingController.text.isNotEmpty &&
                  emailTextEditingController.text.isNotEmpty) {
            print("in");
            if (passwordTextEditingController.text != con_passwordTextEditingController.text) {
              print("Does not matched");
              Toast.show(
                'Password Does Not Match'.tr(),
                context,
                backgroundColor: Colors.red,
                gravity: Toast.BOTTOM,
                duration: Toast.LENGTH_LONG,
              );
              setState(() {
                _isLoading = false;
                error = true;
              });
            } else if (emailTextEditingController.text.indexOf(".") == -1 ||
                emailTextEditingController.text.indexOf("@") == -1) {
              Toast.show(
                'Please enter valid email'.tr(),
                context,
                backgroundColor: Colors.red,
                gravity: Toast.TOP,
                duration: Toast.LENGTH_LONG,
              );
              setState(() {
                _isLoading = false;
                error = true;
              });
            } else {
              var resSing = await SingUp(
                  "api/register",
                  NameTextEditingController.text,
                  NameTextEditingController.text,
                  filename,
                  emailTextEditingController.text,
                  passwordTextEditingController.text,
                  con_passwordTextEditingController.text);
              print(resSing);
              print(resSing.statusCode);
              if (resSing != null && resSing.statusCode == 200) {
                var res = await login("api/login", emailTextEditingController.text, passwordTextEditingController.text);
                print(res);
                String token = json.decode(res.body)['data']['token'];

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('token', token);

                var configRes = await config("api/configs", token);

                if (configRes.statusCode == 200) {
                  String name = json.decode(configRes.body)['data']['user']['name'];
                  String image = json.decode(configRes.body)['data']['user']['image'];
                  String email = json.decode(configRes.body)['data']['user']['email'];
                  bool is_active = json.decode(configRes.body)['data']['user']['is_active'];
                  await prefs.setString('name', name);
                  await prefs.setString('image', image);
                  await prefs.setString('email', email);
                  await prefs.setString('token', token);
                  await prefs.setBool("is_active", is_active);

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
              } else if (resSing.statusCode == 403) {
                setState(() {
                  _isLoading = false;
                });
                Toast.show(
                  json.decode(resSing.body)['message'],
                  context,
                  backgroundColor: Colors.red,
                  gravity: Toast.TOP,
                  duration: Toast.LENGTH_LONG,
                );
              } else if (resSing.statusCode == 400) {
                setState(() {
                  _isLoading = false;
                });
                Toast.show(
                  "The email has already exist".tr(),
                  context,
                  backgroundColor: Colors.red,
                  gravity: Toast.TOP,
                  duration: Toast.LENGTH_LONG,
                );
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
            }
          } else {
            setState(() {
              error = true;
              _isLoading = false;
            });
          }
        },
        child: Container(
          width: 316.w,
          height: 50.h,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(100.r)),
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
          child: Text(
            'Sign Up'.tr(),
            style: TextStyle(
                fontSize: 18.sp, color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
          ),
        ));
  }

  Widget build_SingUp_Info() {
    return Column(
      children: <Widget>[
        // _entryField("User Name", UserNameTextEditingController),
        _entryField("email".tr(), emailTextEditingController),
        _entryField("Password".tr(), passwordTextEditingController, isPassword: true),
        _entryField("Re-Enter Your Password".tr(), con_passwordTextEditingController, isPassword: true),
        _entryField("What Should we call you?".tr(), NameTextEditingController),
      ],
    );
  }

  Widget build_Profile_Image() {
    return CircleAvatar(
      backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
      radius: 75.r,
      backgroundImage: imagefile == null
          ? AssetImage(image_Name)
          : FileImage(
              imagefile,
              //fit: BoxFit.cover,
            ),
      child: Padding(
        padding: EdgeInsets.only(left: 90.w, top: 90.w),
        child: Container(
          width: 46.r,
          height: 46.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.0.r),
            color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
          ),
          child: GestureDetector(
            onTap: () => pickImage(),
            child: Icon(
              Icons.edit,
              size: 34.r,
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
            ),
          ),
        ),
      ),
    );
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 50, maxHeight: 500.h, maxWidth: 500.w);
      if (image == null) return;
      //imageSelected=image.name;
      setState(() {
        imagefile = File(image.path);
        imageSelected = image.path;
      });
    } on PlatformException catch (e) {
      print("Failed to pick image : $e");
    }
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
                fontSize: 14.sp,
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
            style: TextStyle(fontSize: 22.0.sp, color: Color(0xFFbdc6cf)),
            obscureText: isPassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
              errorText: textEditingController.text.isEmpty && error ? 'Value Can\'t Be Empty'.tr() : null,
              contentPadding: EdgeInsets.only(left: 14.0.w, bottom: 8.0.h, top: 8.0.h),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
/*AlertDialog buildImageDialog(){
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15),
      contentPadding: EdgeInsets.all(15),
      //clipBehavior: Clip.antiAliasWithSaveLayer,

      backgroundColor: AppColor.darkModePrim,
      scrollable: true,
      // title: Center(child: const Text('Select Image')),
      titleTextStyle: TextStyle(color: AppColor.kTextColor),

      content:StatefulBuilder(
        builder:(context , setState)=> Container(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 5,
                childAspectRatio: 0.8),
            itemBuilder: (context, index) {
              //print(Categry_name);
              return ButtonTheme(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      //selected=true;
                      image = results[index];
                      //select.forEach((element) {element=false;});
                      for(int i=0;i<select.length;i++)
                      {
                        select[i]=false;
                      }
                      select[index]=!select[index];
                      print(results[index]);

                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        AppColor.darkModeSeco),
                    shape:
                    MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: AppColor.darkModePrim),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(150.0, 150.0)),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
                  ),
                  child: Container(
                    //padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    //width: 160.0,
                    //height: 160.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: select[index] ? AppColor.mainBtn :  AppColor
                            .darkModeSeco),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image(
                        image: NetworkImage(results[index]),
                        // height:90,
                        //width: 90,
                      ),
                    ),
                  ),
                ),
              );
            },
            // itemCount: Single_Section_activite[Section_index].activities.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: _Images.length,
          ),
          width: MediaQuery.of(context).size.width,
          height: 400,
        ),
      ),
      actions: <Widget>[
        Center(
            child: ButtonTheme(
                minWidth: 200.0,
                height: 100.0,
                child: ElevatedButton(
                  child: Text(
                    'Continue',
                    style: TextStyle(
                        color: AppColor.darkModePrim,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed:
                      () {
                    setState(() {
                      imageSelected=image;
                      Navigator.of(context).pop();
                    }
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        AppColor.mainBtn),
                    shape:
                    MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: AppColor.darkModePrim),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(150.0, 50.0)),
                  ),
                )
            )
        )
      ],


    );
  }*/
/*File _storedImage;
  Future<void> _takePicture() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.camera,
      maxWidth: 600,
    );
    if (imageFile == null) {
      return;
    }
    setState(() {
      _storedImage = imageFile;
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();    final fileName = path.basename(imageFile.path);
    final savedImage = await imageFile.copy('${appDir.path}/$fileName');    }*/
}
