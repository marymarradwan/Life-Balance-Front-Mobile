import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/ScreenHelper.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool isLoading = false, error = false, reset = false;
  TextEditingController CodeTextEditingController = new TextEditingController();
  TextEditingController newPasswordTextEditingController = new TextEditingController();
  TextEditingController Re_newpasswordTextEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return Scaffold(
      body: LoadingOverlay(
        isLoading: isLoading,
        progressIndicator: CircularProgressIndicator(
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
        ),
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
                      height: 30.h,
                    ),
                    Text(
                      "Reset Password".tr(),
                      style: TextStyle(
                          color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                          fontSize: 20.sp,
                          fontFamily: "Subjective",
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 0.3.sh,
                    ),
                    !reset
                        ? Column(
                            children: [
                              Text(
                                "Code Sent".tr(),
                                style: TextStyle(
                                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                    fontSize: 18.sp,
                                    fontFamily: "Subjective",
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "A code has been set to your email which contains 7-digits, please enter these digits to verify Your Email"
                                    .tr(),
                                style: TextStyle(
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                  fontSize: 10.sp,
                                  fontFamily: "Subjective",
                                ),
                              ),
                              _entryField("Enter Code".tr(), CodeTextEditingController),
                              _submitButton("Enter", () {
                                setState(() {
                                  reset = true;
                                });
                              }),
                            ],
                          )
                        : Column(
                            children: [
                              _entryField("Enter New Password".tr(), newPasswordTextEditingController),
                              _entryField("RE-Enter New Password".tr(), Re_newpasswordTextEditingController),
                              _submitButton("Reset Password".tr(), () {
                                setState(() {
                                  reset = false;
                                });
                              }),
                            ],
                          )
                  ],
                ),
              ),
            ),
          ),
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
              errorText: textEditingController.text.isEmpty && error ? 'Value Can\'t Be Empty' : null,
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

  Widget _submitButton(String name, VoidCallback function) {
    return InkWell(
        onTap: function,
        child: Container(
          width: 316.w,
          height: 50.h,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(100.r)),
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
          child: Text(
            name,
            style: TextStyle(
                fontSize: 18.sp, color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
          ),
        ));
  }
}
