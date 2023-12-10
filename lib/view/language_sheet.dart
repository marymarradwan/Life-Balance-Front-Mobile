import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/Util/language_helper.dart';

class LanguageSheet extends StatefulWidget {
  final bool isSelectedLang;
  final String title;
  Function(bool) onChange;

  LanguageSheet({Key key, this.isSelectedLang, this.title, this.onChange}) : super(key: key);

  @override
  State<LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<LanguageSheet> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.title == 'English') {
          context.setLocale(LanguageHelper.kEnglishLocale);
          CashHelper.saveData(key: LanguageValue, value: 'en');
        } else {
          CashHelper.saveData(key: LanguageValue, value: 'ar');
          print(CashHelper.getData(key: LanguageValue));

          context.setLocale(LanguageHelper.kArabicLocale);
        }
        widget.onChange(!widget.isSelectedLang);
        setState(() {});
      },
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 13.67.w),
            child: Container(
              width: 23.w,
              height: 23.h,
              decoration: BoxDecoration(
                border: Border.all(
                    width: 2, color: widget.isSelectedLang ? AppColor.darkModePrim : AppColor.profileTextColors),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: widget.isSelectedLang ? AppColor.darkModePrim : Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 2.w,
          ),
          Text(
            (widget.title),
            style: TextStyle(
                color: widget.isSelectedLang ? AppColor.darkModePrim : AppColor.profileTextColors, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class LanguageWidget extends StatefulWidget {
  const LanguageWidget({Key key}) : super(key: key);

  @override
  State<LanguageWidget> createState() => _LanguageWidgetState();
}

class _LanguageWidgetState extends State<LanguageWidget> {
  List<String> lang = ['English', 'العربية'];

  // String selectedItem = 'English';
  bool isSelected = false;
  int selectedIndex = 0;

  void didChangeDependencies() {
    super.didChangeDependencies();
    // CashHelper.saveData(key: LanguageValue, value: 'en');

    String language = CashHelper.getData(key: LanguageValue);
    print(language);
    print(CashHelper.getData(key: LanguageValue));
    if (language == 'en') {
      lang[0] = 'English';
      selectedIndex = 0;
    } else if (language == 'ar') {
      lang[1] = 'العربية';
      selectedIndex = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select language".tr(),
              // style: AppTheme.headline2.copyWith(color: AppColors.kPDarkBlueColor, fontSize: 20),
            ),
            SizedBox(
              height: 42.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(height: 35.h),
                  padding: EdgeInsets.zero,
                  itemCount: lang.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return LanguageSheet(
                      onChange: (val) {
                        selectedIndex = index;
                        isSelected = val;
                        setState(() {});
                      },
                      isSelectedLang: selectedIndex == index,
                      title: lang[index],
                    );
                  }),
            ),
            SizedBox(
              height: 20.h,
            ),
            const Divider(
              thickness: 1,
              endIndent: 20,
              indent: 20,
              color: Colors.white,
            ),
            SizedBox(
              height: 38.h,
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(4)),
                          fixedSize: MaterialStateProperty.all<Size>(
                            Size(double.infinity, 50.h),
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: AppColor.darkModePrim, width: 1),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Text(
                            "continue".tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 17, color: Colors.black),
                            //style: AppTheme.button
                            //  .copyWith(color: AppColors.kPDarkBlueColor, fontSize: buttonFontSize ?? AppTheme.button.fontSize)),
                          ),
                        )
                        // Expanded(
                        //   child: Padding(
                        //     padding: EdgeInsets.symmetric(horizontal: 15.w),
                        //     child: CoustomButton(
                        //       function: () {
                        //         Navigation.pop();
                        //       },
                        //       buttonName: "OK".tr(),
                        //       backgoundColor: AppColors.kWhiteColor,
                        //       borderSideColor: AppColors.kPDarkBlueColor,
                        //       borderRadius: 10.0.r,
                        //     ),
                        //   ),
                        // ),
                        ),
                  ),
                )
              ],
            ),
          ]),
    );
  }
}
