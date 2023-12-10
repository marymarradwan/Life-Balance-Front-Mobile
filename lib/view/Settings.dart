import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/ScreenHelper.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/custome_sheet.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/view/Ads.dart';
import 'package:life_balancing/view/companies.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_sheet.dart';
import 'login.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModePrim,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              right: ScreenHelper.fromWidth(4.0),
              left: ScreenHelper.fromWidth(4.0),
            ),
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Settings".tr(),
                    style: TextStyle(
                        fontSize: 20.sp,
                        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSeco : AppColor.mainBtn,
                        fontFamily: "Subjective",
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  buttonStyle("Premium".tr(), () {
                    print("Premium");
                  }, Iconsax.star1,
                      CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
                  SizedBox(
                    height: 5.h,
                  ),
                  buttonStyle("Companies".tr(), () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => CompaniesPage()));
                  }, Iconsax.star1,
                      CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
                  SizedBox(
                    height: 5.h,
                  ),
                  buttonStyle("Ads".tr(), () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdsPage()));
                  }, Iconsax.star1,
                      CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
                  SizedBox(
                    height: 5.h,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /* buttonStyle(
                          "Theme", () {print("Theme");}, Iconsax.brush_2, Colors.red),*/
                      buttonStyle("About As".tr(), () {
                        print('About As');
                      }, Iconsax.profile_2user5, Colors.blue),
                      SizedBox(
                        height: 5.h,
                      ),
                      buttonStyle("Help".tr(), () {
                        print("Help");
                      }, Iconsax.info_circle5, Colors.amber),
                      SizedBox(
                        height: 5.h,
                      ),
                      buttonStyle("Notifications".tr(), () {
                        print("Notifications");
                      }, Iconsax.notification5, Colors.orange),
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buttonStyle("Rate Us".tr(), () {
                        print("Rate us");
                      }, Iconsax.like_15, Colors.blue),
                      SizedBox(
                        height: 5.h,
                      ),
                      buttonStyle("Share The App".tr(), () {
                        print("Share The App");
                      }, Iconsax.share5, Colors.green),
                      SizedBox(
                        height: 5.h,
                      ),
                      buttonStyle("Send Your Feedback".tr(), () {
                        print("Send Your Feedback");
                      }, Iconsax.emoji_happy5, Colors.amber),
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buttonStyle("Like Us On Facebook".tr(), () {
                        print("Like Us On Facebook ");
                      }, Icons.facebook, Color(0xFF6562FC)),
                      SizedBox(
                        height: 5.h,
                      ),
                      buttonStyle("Follow Us On Instagram".tr(), () {
                        print("Follow Us On Instagram");
                      }, Iconsax.instagram, Colors.red),
                      SizedBox(
                        height: 5.h,
                      ),
                      buttonStyle("Visit Our Website".tr(), () {
                        print("Visit Our Website");
                      }, Iconsax.global5, Colors.blue),
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  buttonStyle("LogOut".tr(), () async {
                    showDialog(
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: CashHelper.getData(key: ChangeTheme)
                                ? AppColor.mainBtnLightMode
                                : AppColor.darkModePrim,
                            scrollable: true,
                            title: Text('Log Out '.tr()),
                            titleTextStyle: TextStyle(
                              color: AppColor.kTextColor,
                              fontFamily: "Subjective",
                            ),
                            content: Text(
                              "Are You sure want to Log Out!!".tr(),
                              style: TextStyle(
                                color: AppColor.kTextColor,
                                fontSize: 15.sp,
                                fontFamily: "Subjective",
                              ),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  setState(() async {
                                    //add task id and goal id

                                    SharedPreferences preferences = await SharedPreferences.getInstance();
                                    await preferences.clear();
                                    await CashHelper.sharedPreferences.remove(ChangeTheme);
                                    Navigator.pushAndRemoveUntil(context,
                                        MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);

                                    //task_name_Controler.text = "";
                                  });
                                },
                                //textColor: Theme.of(context).primaryColor,
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                    color: AppColor.kTextColor,
                                    fontFamily: "Subjective",
                                  ),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  //add task id and goal id
                                  // DeletedTask = false;
                                  Navigator.of(context).pop();
                                  //task_name_Controler.text = "";
                                },
                                //textColor: Theme.of(context).primaryColor,
                                child: Text(
                                  'back'.tr(),
                                  style: TextStyle(
                                    color: AppColor.kTextColor,
                                    fontFamily: "Subjective",
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        context: context);
                  }, Iconsax.logout5, AppColor.mainBtn),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return scaffold;
  }

  Widget buttonStyle(String name, VoidCallback function, IconData icon, Color color) {
    return ButtonTheme(
      child: ElevatedButton(
        onPressed: function,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 10.w,
            ),
            Container(
              width: 34.w,
              height: 34.h,
              child: Padding(
                padding: EdgeInsets.only(bottom: 2.h, right: 20.w),
                child: Icon(
                  icon,
                  color: color,
                  size: 24.r,
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r), /*color: AppColor.darkModePrim*/
              ),
            ),
            SizedBox(
              width: 20.w,
            ),
            Text(
              name,
              style: TextStyle(
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  fontFamily: "Subjective",
                  fontSize: 16.sp),
            )
          ],
        ),
        style: ButtonStyle(
          backgroundColor: CashHelper.getData(key: ChangeTheme)
              ? MaterialStateProperty.all<Color>(AppColor.LightModeWhite)
              : MaterialStateProperty.all<Color>(AppColor.darkModeSeco),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0.r),
              side: BorderSide(
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeWhite : AppColor.darkModeSeco),
            ),
          ),
          minimumSize: MaterialStateProperty.all<Size>(Size(348.w, 47.h)),
        ),
      ),
    );
  }
}
