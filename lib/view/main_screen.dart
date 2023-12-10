import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/view/HomePage.dart';
import 'package:life_balancing/view/dashboard.dart';
import 'package:life_balancing/view/goals.dart';
import 'package:life_balancing/view/habits.dart';
import 'package:life_balancing/view/journal.dart';

class MainScreen extends StatefulWidget {
  final int TabId;

  const MainScreen({Key key, this.TabId}) : super(key: key);

  @override
  _MainScreen createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  int _selectedIndex;
  List<Widget> screen = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _selectedIndex = widget.TabId ?? 2;
    screen = [DashboardPage(), HabitsPage(), HomePage(), GoalsPage(), JournalPage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topRight: Radius.circular(25), topLeft: Radius.circular(25)),
          /* boxShadow: [
            BoxShadow(
                color: Colors.black12,
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(5, -1)),
          ],*/
        ),
        child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
            child: BottomNavigationBar(
              // height: 65,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  // backgroundColor: AppColor.darkModeSeco,
                  // backgroundColor: AppColor.darkModePrim,
                  icon:
                  Container(
                    // padding: EdgeInsets.all(2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Iconsax.status_up5,
                          size: 36.r,
                          // color: AppColor.kTextColor,
                        ),
                         Text(
                          "Dashboard".tr(),
                          style: TextStyle(
                              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                              fontSize: 10.sp,
                              fontFamily: "Subjective",
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  // Icon(
                  //   Iconsax.status_up5,
                  //   size: 36.r,
                  //   // color: AppColor.kTextColor,
                  // ),
                  // title: Text(
                  //   "Dashboard".tr(),
                  //   style: TextStyle(
                  //       color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  //       fontSize: 10.sp,
                  //       fontFamily: "Subjective",
                  //       fontWeight: FontWeight.normal),
                  // ),

                  activeIcon: Icon(
                    Iconsax.status_up5,
                    size: 36.r,
                    // color: AppColor.mainBtn,
                  ),
                ),
                /*Container(
            // padding: EdgeInsets.all(2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Iconsax.status_up5,
                  size: 36.r,
                  color: AppColor.kTextColor,
                ),
                Text(
                  "Dashboard",
                  style: TextStyle(
                      color: AppColor.kTextColor,
                      fontSize: 10.sp,
                      fontFamily: "Subjective",
                      fontWeight: FontWeight.normal),
                )
              ],
            ),
          ),*/
                BottomNavigationBarItem(
                  // backgroundColor: AppColor.darkModePrim,
                  icon:
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Iconsax.clipboard_text5,
                          size: 36.r,
                          //  color: AppColor.kTextColor,
                        ),
                         Text(
                          "Habits".tr(),
                          style: TextStyle(
                              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                              fontSize: 10.sp,
                              fontFamily: "Subjective",
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  // Icon(
                  //   Iconsax.clipboard_text5,
                  //   size: 36.r,
                  //   //  color: AppColor.kTextColor,
                  // ),
                  // title: Text(
                  //   "Habits".tr(),
                  //   style: TextStyle(
                  //       color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  //       fontSize: 10.sp,
                  //       fontFamily: "Subjective",
                  //       fontWeight: FontWeight.normal),
                  // ),
                  activeIcon: Icon(
                    Iconsax.clipboard_text5,
                    size: 36.r,
                    //  color: AppColor.mainBtn,
                  ),
                ),
                /*
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Iconsax.clipboard_text5,
                  size: 36.r,
                  color: AppColor.kTextColor,
                ),
                Text(
                  "Habits",
                  style: TextStyle(
                      color: AppColor.kTextColor,
                      fontSize: 10.sp,
                      fontFamily: "Subjective",
                      fontWeight: FontWeight.normal),
                )
              ],
            ),
          ),*/
                BottomNavigationBarItem(
                    //  backgroundColor: AppColor.darkModePrim,
                    icon:
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Iconsax.home5,
                            size: 36.r,
                           // color: AppColor.kTextColor,
                          ),
                          Text(
                            "Home".tr(),
                            style: TextStyle(
                                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                fontSize: 10.sp,
                                fontFamily: "Subjective",
                                fontWeight: FontWeight.normal),
                          )
                        ],
                      ),
                    ),
                    // Icon(
                    //   Iconsax.home5,
                    //   size: 36.r,
                    //   // color: AppColor.kTextColor,
                    // ),
                    // title: Text(
                    //   "Home".tr(),
                    //   style: TextStyle(
                    //       color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    //       fontSize: 10.sp,
                    //       fontFamily: "Subjective",
                    //       fontWeight: FontWeight.normal),
                    // ),
                    activeIcon: Icon(
                      Iconsax.home5,
                      size: 36.r,
                      // color: AppColor.mainBtn,
                    )),
                /*Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Iconsax.home5,
                  size: 36.r,
                  color: AppColor.kTextColor,
                ),
                Text(
                  "Home",
                  style: TextStyle(
                      color: AppColor.kTextColor,
                      fontSize: 10.sp,
                      fontFamily: "Subjective",
                      fontWeight: FontWeight.normal),
                )
              ],
            ),
          ),*/
                BottomNavigationBarItem(
                  //  backgroundColor: AppColor.darkModePrim,
                  icon:
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Iconsax.clipboard_tick5,
                          size: 36.r,
                         // color: AppColor.kTextColor,
                        ),
                        Text(
                          "Goals",
                          style: TextStyle(
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                  fontSize: 10.sp,
                                  fontFamily: "Subjective",
                                  fontWeight: FontWeight.normal),
                        )
                      ],
                    ),
                  ),
                  // Icon(
                  //   Iconsax.clipboard_tick5,
                  //   size: 36.r,
                  //   //color: AppColor.kTextColor,
                  // ),
                  // title: Text(
                  //   "Goals".tr(),
                  //   style: TextStyle(
                  //       color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  //       fontSize: 10.sp,
                  //       fontFamily: "Subjective",
                  //       fontWeight: FontWeight.normal),
                  // ),
                  activeIcon: Icon(
                    Iconsax.clipboard_tick5,
                    size: 36.r,
                    //  color: AppColor.mainBtn,
                  ),
                ),
                /* Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Iconsax.clipboard_tick5,
                  size: 36.r,
                  color: AppColor.kTextColor,
                ),
                Text(
                  "Goals",
                  style: TextStyle(
                      color: AppColor.kTextColor,
                      fontSize: 10.sp,
                      fontFamily: "Subjective",
                      fontWeight: FontWeight.normal),
                )
              ],
            ),
          ),*/
                BottomNavigationBarItem(
                    //    backgroundColor: AppColor.darkModePrim,
                    icon:
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image(
                            image: AssetImage("assets/images/journal icon.png"),
                            width: 37.w,
                            height: 37.w,
                            fit: BoxFit.contain,
                          ),
                        Text(
                          "Journal".tr(),
                          style: TextStyle(
                              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                              fontSize: 10.sp,
                              fontFamily: "Subjective",
                              fontWeight: FontWeight.normal),
                        ),
                        ],
                      ),
                    ),
                    // Image(
                    //   image: AssetImage("assets/images/journal icon.png"),
                    //   width: 37.w,
                    //   height: 37.w,
                    //   fit: BoxFit.contain,
                    // ),
                    // title: Text(
                    //   "Journal".tr(),
                    //   style: TextStyle(
                    //       color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    //       fontSize: 10.sp,
                    //       fontFamily: "Subjective",
                    //       fontWeight: FontWeight.normal),
                    // ),
                    activeIcon: Image(
                      image: AssetImage("assets/images/journal icon.png"),
                      color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                      colorBlendMode: BlendMode.modulate,
                      width: 37.w,
                      height: 37.w,
                      fit: BoxFit.contain,
                    )),
                /*Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.my_library_books,
                  size: 36.r,
                  color: AppColor.kTextColor,
                  semanticLabel: "journal",
                ),
                Text(
                  "Journal",
                  style: TextStyle(
                      color: AppColor.kTextColor,
                      fontSize: 10.sp,
                      fontFamily: "Subjective",
                      fontWeight: FontWeight.normal),
                )
              ],
            ),
          ),*/
              ],
              // color: AppColor.darkModeSeco,
              //  buttonBackgroundColor: AppColor.mainBtn,
              elevation: 2,
              backgroundColor:
                  CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
              selectedItemColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
              unselectedItemColor: AppColor.kTextColor,
              landscapeLayout: BottomNavigationBarLandscapeLayout.centered,

              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              // animationCurve: Curves.easeInOut,
              // animationDuration: Duration(milliseconds: 300),
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              //letIndexChange: (index) => true,
              currentIndex: _selectedIndex,
            )),
      ),
      body: screen[_selectedIndex],
    );
  }
}
