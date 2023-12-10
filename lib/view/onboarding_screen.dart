import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
// import 'package:life_balancing/constants.dart';
import 'package:life_balancing/view/login.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numPages = 4;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
//IbrahimRahme@circlopedia.com
  //12345678
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _currentPage == 0
                  ? AssetImage("assets/images/Group 23.png")
                  : _currentPage == 1
                      ? AssetImage("assets/images/Mask Group 24.png")
                      : _currentPage == 2
                          ? AssetImage("assets/images/Mask Group 26.png")
                          : AssetImage("assets/images/Mask Group 27.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: 0.82.sh,
                  width: 0.90.sw,
                  child: PageView(
                    physics: PageScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(25.0.w),
                        child: Container(
                          decoration: new BoxDecoration(
                              border: new Border.all(width: 20.w, color: Colors.transparent),
                              //color is transparent so that it does not blend with the actual color specified
                              borderRadius: BorderRadius.all(Radius.circular(25.0.r)),
                              color: new Color.fromRGBO(
                                  252, 224, 213, 0.5) // Specifies the background color and the opacity
                              ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Image(
                                  image: AssetImage(
                                    CashHelper.getData(key: ChangeTheme)
                                        ? 'assets/images/logolight.png'
                                        : 'assets/images/logodark.png',
                                  ),
                                  height: 127.0.h,
                                  width: 214.0.w,
                                ),
                              ),
                              // SizedBox(height: 10.0),
                              /*Text(
                                'Circlopedia',
                                style: TextStyle(
                                  color: AppColor.mainBtn,
                                  fontFamily: "Subjective",
                                  fontSize: 18.0.sp,
                                  height: 1.5.h,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),*/
                              SizedBox(height: 20.0.h),
                              Center(
                                child: Text(
                                  'This App will take you into a journey of discovering yourself. Knowing yourself and helps you in balancing your life'
                                      .tr()
                                      .tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15.0.sp,
                                    fontFamily: "Subjective",
                                    height: 1.2.h,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0.h),
                              Center(
                                child: Container(
                                  decoration: new BoxDecoration(
                                      border: new Border.all(width: 20.w, color: Colors.transparent),
                                      //color is transparent so that it does not blend with the actual color specified
                                      borderRadius: BorderRadius.all(Radius.circular(25.0.r)),
                                      color: new Color.fromRGBO(
                                          255, 205, 187, 1.0) // Specifies the background color and the opacity
                                      ),
                                  child: Text(
                                    "The great things always happen outside of your comfort zone".tr(),
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14.0.sp,
                                      fontFamily: "Subjective",
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(height: 40.0.h),
                              Center(
                                child: InkWell(
                                    onTap: () {
                                      if (_currentPage != _numPages - 1) {
                                        _pageController.nextPage(
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      } else {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                      }
                                    },
                                    child: Container(
                                      width: 0.5.sw,
                                      padding: EdgeInsets.symmetric(vertical: 15.h),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(25.r)),
                                        color: CashHelper.getData(key: ChangeTheme)
                                            ? AppColor.mainBtnLightMode
                                            : AppColor.mainBtn,
                                      ),
                                      child: Text(
                                        'Continue'.tr(),
                                        style: TextStyle(
                                            fontSize: 17.sp,
                                            fontFamily: "Subjective",
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? Colors.black
                                                : AppColor.kTextColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(25.0.w),
                        child: Container(
                          decoration: new BoxDecoration(
                              border: new Border.all(width: 20.w, color: Colors.transparent),
                              //color is transparent so that it does not blend with the actual color specified
                              borderRadius: BorderRadius.all(Radius.circular(25.0.r)),
                              color: new Color.fromRGBO(
                                  255, 179, 71, 0.5) // Specifies the background color and the opacity
                              ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  'This is your Life:'.tr(),
                                  style: TextStyle(
                                    color: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.mainBtnLightMode
                                        : AppColor.mainBtn,
                                    fontFamily: "Subjective",
                                    fontSize: 20.0.sp,
                                    height: 1.5.h,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0.h),
                              Center(
                                child: Image(
                                  image: AssetImage(
                                    'assets/images/temp@2x.png',
                                  ),
                                  height: 120.0.h,
                                  width: 120.0.w,
                                ),
                              ),
                              SizedBox(height: 15.0.h),
                              Center(
                                child: Text(
                                  'And It represents You!!! Everything you do on the app will Contribute to the Progress of this circle This circle is what you need to focus on While using CircuLife'
                                      .tr()
                                      .tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.black87,
                                    fontSize: 15.0.sp,
                                    fontFamily: "Subjective",
                                    height: 1.2.h,
                                  ),
                                ),
                              ),
                              SizedBox(height: 15.0.h),
                              Center(
                                child: Container(
                                  decoration: new BoxDecoration(
                                      border: new Border.all(width: 20.w, color: Colors.transparent),
                                      //color is transparent so that it does not blend with the actual color specified
                                      borderRadius: BorderRadius.all(Radius.circular(25.0.r)),
                                      color: new Color.fromRGBO(
                                          255, 205, 187, 1.0) // Specifies the background color and the opacity
                                      ),
                                  child: Text(
                                    "The great things always happen outside of your comfort zone".tr(),
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14.0.sp,
                                      fontFamily: "Subjective",
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(height: 40.0.h),
                              Center(
                                child: InkWell(
                                    onTap: () {
                                      if (_currentPage != _numPages - 1) {
                                        _pageController.nextPage(
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      } else {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                      }
                                    },
                                    child: Container(
                                      width: 0.5.sw,
                                      padding: EdgeInsets.symmetric(vertical: 15.h),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(25.r)),
                                        color: CashHelper.getData(key: ChangeTheme)
                                            ? AppColor.mainBtnLightMode
                                            : AppColor.mainBtn,
                                      ),
                                      child: Text(
                                        'Continue'.tr(),
                                        style: TextStyle(
                                            fontSize: 17.sp,
                                            fontFamily: "Subjective",
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? Colors.black
                                                : AppColor.kTextColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(25.0.w),
                        child: Container(
                          decoration: new BoxDecoration(
                              border: new Border.all(width: 20.w, color: Colors.transparent),
                              //color is transparent so that it does not blend with the actual color specified
                              borderRadius: BorderRadius.all(Radius.circular(25.0.r)),
                              color: new Color.fromRGBO(
                                  187, 242, 235, 0.6) // Specifies the background color and the opacity
                              ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  'Track Everything!!'.tr(),
                                  style: TextStyle(
                                    color: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.mainBtnLightMode
                                        : AppColor.mainBtn,
                                    fontFamily: "Subjective",
                                    fontSize: 20.0.sp,
                                    height: 1.5.h,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0.h),
                              Center(
                                child: Image(
                                  image: AssetImage(
                                    'assets/images/Group 1851@2x.png',
                                  ),
                                  height: 160.0.h,
                                  width: 187.0.w,
                                ),
                              ),
                              SizedBox(height: 8.0.h),
                              Center(
                                child: Text(
                                  'You can track your Daily Routine,Habits Goals, Moods, write your Journal and Balance your life using your CircuLife'
                                      .tr()
                                      .tr()
                                      .tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15.0.sp,
                                    fontFamily: "Subjective",
                                    height: 1.2.h,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0.h),
                              Center(
                                child: Container(
                                  decoration: new BoxDecoration(
                                      border: new Border.all(width: 20.w, color: Colors.transparent),
                                      //color is transparent so that it does not blend with the actual color specified
                                      borderRadius: BorderRadius.all(Radius.circular(25.0.r)),
                                      color: new Color.fromRGBO(
                                          187, 242, 235, 0.7) // Specifies the background color and the opacity
                                      ),
                                  child: Text("The great things always happen outside of your comfort zone".tr(),
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14.0.sp,
                                        fontFamily: "Subjective",
                                      ),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              SizedBox(height: 20.0.h),
                              Center(
                                child: InkWell(
                                    onTap: () {
                                      if (_currentPage != _numPages - 1) {
                                        _pageController.nextPage(
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      } else {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                      }
                                    },
                                    child: Container(
                                      width: 0.5.sw,
                                      padding: EdgeInsets.symmetric(vertical: 10.h),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(25.r)),
                                        color: CashHelper.getData(key: ChangeTheme)
                                            ? AppColor.mainBtnLightMode
                                            : AppColor.mainBtn,
                                      ),
                                      child: Text(
                                        'Continue'.tr(),
                                        style: TextStyle(
                                            fontSize: 17.sp,
                                            fontFamily: "Subjective",
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? Colors.black
                                                : AppColor.kTextColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(25.0.w),
                        child: Container(
                          decoration: new BoxDecoration(
                              border: new Border.all(width: 20.w, color: Colors.transparent),
                              //color is transparent so that it does not blend with the actual color specified
                              borderRadius: BorderRadius.all(Radius.circular(25.0.r)),
                              color: new Color.fromRGBO(
                                  253, 225, 232, 0.5) // Specifies the background color and the opacity
                              ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  'Your Own Stats!'.tr(),
                                  style: TextStyle(
                                    color: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.mainBtnLightMode
                                        : AppColor.mainBtn,
                                    fontFamily: "Subjective",
                                    fontSize: 20.0.sp,
                                    height: 1.5.h,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0.h),
                              Center(
                                child: Image(
                                  image: AssetImage(
                                    'assets/images/Group 1794@2x.png',
                                  ),
                                  height: 171.0.h,
                                  width: 251.0.w,
                                ),
                              ),
                              SizedBox(height: 8.0.h),
                              Center(
                                child: Text(
                                  "Collect Points and Spend them Wisely, And don't forget to Enjoy Very Detailed reports about your life"
                                      .tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: CashHelper.getData(key: ChangeTheme) ? Colors.white : Colors.black87,
                                    fontSize: 15.0.sp,
                                    fontFamily: "Subjective",
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              SizedBox(height: 15.0.h),
                              Center(
                                child: Container(
                                  decoration: new BoxDecoration(
                                      border: new Border.all(width: 20.w, color: Colors.transparent),
                                      //color is transparent so that it does not blend with the actual color specified
                                      borderRadius: BorderRadius.all(Radius.circular(25.0.r)),
                                      color: new Color.fromRGBO(
                                          253, 225, 232, 1.0) // Specifies the background color and the opacity
                                      ),
                                  child: Text('"The great things always happen outside of your comfort zone"'.tr(),
                                      style: TextStyle(
                                        color: CashHelper.getData(key: ChangeTheme) ? Colors.white : Colors.black87,
                                        fontSize: 14.0.sp,
                                        fontFamily: "Subjective",
                                      ),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              SizedBox(height: 40.0.h),
                              Center(
                                child: InkWell(
                                    onTap: () {
                                      if (_currentPage != _numPages - 1) {
                                        _pageController.nextPage(
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      } else {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                      }
                                    },
                                    child: Container(
                                      width: 0.5.sw,
                                      padding: EdgeInsets.symmetric(vertical: 15.h),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(25.r)),
                                        color: CashHelper.getData(key: ChangeTheme)
                                            ? AppColor.mainBtnLightMode
                                            : AppColor.mainBtn,
                                      ),
                                      child: Text(
                                        'Continue'.tr(),
                                        style: TextStyle(
                                            fontSize: 17.sp,
                                            fontFamily: "Subjective",
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? Colors.black
                                                : AppColor.kTextColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: _buildPageIndicator(),
                // ),
                // _currentPage != _numPages - 1
                //     ? Expanded(
                //   child: Align(
                //     alignment: FractionalOffset.bottomRight,
                //     child: FlatButton(
                //       onPressed: () {
                //         _pageController.nextPage(
                //           duration: Duration(milliseconds: 500),
                //           curve: Curves.ease,
                //         );
                //       },
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Text(
                //             'Next',
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 22.0,
                //             ),
                //           ),
                //           SizedBox(width: 10.0),
                //           Icon(
                //             Icons.arrow_forward,
                //             color: Colors.white,
                //             size: 30.0,
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // )
                //     : Text(''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
