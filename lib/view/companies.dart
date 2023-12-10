import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/shared/empty_error_Image.dart';
import 'package:life_balancing/shared/floating_action_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:table_calendar/table_calendar.dart';

import '../Util/ScreenHelper.dart';
import '../model/Events.dart';
import 'login.dart';

class CompaniesPage extends StatefulWidget {
  @override
  _CompaniesPage createState() => _CompaniesPage();
}

class _CompaniesPage extends State<CompaniesPage> {
  static List<SingleEvent> Event = [];
  var isPortrait;
  bool expand_Calender = true;
  CalendarFormat _calendarFormat_month = CalendarFormat.month;
  CalendarFormat _calendarFormat_week = CalendarFormat.week;
  DateTime _focusedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _selectedDay;
  DateTime kToday = DateTime.now();
  DateTime kFirstDay;
  DateTime kLastDay;

  String dateSelected;
  bool _isLoadingUpdate = false, _isInit = false;

  //validation mood
  // bool _button_validation = false, _notes_validation = false;
  bool isValid = false;
  bool isError = false;

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool is_Win_Badge = false;
  bool is_Win_Reward = false;

  Future _getSelectedDateJournal() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingUpdate = true;
        isError = false;
      });
      try {
        var res = await getData("api/admin/companies", token);
        print(json.decode(res.body)['data']);
        if (res.statusCode == 401) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
        } else if (res.statusCode == 200) {
           print(json.decode(res.body));
          List<dynamic> data = json.decode(res.body)['data'];
          List<SingleEvent> newEvent = [];

          for (var i = 0; i < data.length; i++) {
            SingleEvent event = new SingleEvent(
              data[i]['id'],
              data[i]['social_media'],
              data[i]['active'].toString(),
              data[i]['address'],
              data[i]['email'],
              data[i]['name'],
              data[i]['description'],
              data[i]['phone_number'],
              DateTime.parse(data[i]['created_at']),
            );
            newEvent.add(event);
            print(event.toString());
          }
          setState(() {
            Event = newEvent;
            _isLoadingUpdate = false;
            isError = false;
          });
        } else {
          setState(() {
            _isLoadingUpdate = false;
            isError = true;
            _refreshController.refreshFailed();
          });
        }
      } on SocketException catch (_) {
        setState(() {
          _isLoadingUpdate = false;
          isError = true;
          _refreshController.refreshFailed();
        });
      }
    });
  }

  @override
  void initState() {
    if (!_isInit) {
      _getSelectedDateJournal();
    }
    _isInit = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return Scaffold(
      floatingActionButton: FloatingActionButtons(),
      backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
      body: SmartRefresher(
        header:
            WaterDropHeader(waterDropColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtn : AppColor.mainBtn),
        //physics: BouncingScrollPhysics(),
        enablePullDown: true,
        //enableTwoLevel: true,

        onRefresh: () {
          if (mounted)
            setState(() async {
              await _getSelectedDateJournal();
              _refreshController.refreshCompleted();
            });
        },

        controller: _refreshController,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              right: ScreenHelper.fromWidth(4.0),
              left: ScreenHelper.fromWidth(4.0),
            ),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  mainAxisAlignment: !isError ? MainAxisAlignment.end : MainAxisAlignment.center,
                  children: [
                    build_journal_title(),
                    !isError ? build_Calinder_Format_Icon() : Container(),
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                !isError
                    ? Builder(builder: (BuildContext context) {
                        return Container(
                          child: Expanded(child: SingleChildScrollView(child: build_event_for_day())),
                        );
                      })
                    : ErrorEmptyItem(
                        ImagePath: "assets/images/error2x.png",
                        Title: "An Error Occured".tr(),
                        SupTitle:
                            "this time it's our Mistake, sorry for inconvenience and we will fix this issue Asap!!!"
                                .tr(),
                        TitleColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget build_Calinder_Format_Icon() {
    return Padding(
      padding: EdgeInsets.only(left: 0.2.sw),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
        ),
        child: IconButton(
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
          highlightColor: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
          // splashRadius: 40,
          onPressed: () {
            setState(() {

            });
          },
          icon: Icon(Iconsax.money),
        ),
      ),
    );
  }

  Widget build_journal_title() {
    return Text(
      'Companies'.tr(),
      style: TextStyle(
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
        fontFamily: "Subjective",
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget build_event_for_day() {
    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var _samemontheventsFilter = Event;

    return _isLoadingUpdate
        ? SingleChildScrollView(
            child: (SkeletonLoader(
              builder: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                child: Row(
                  children: <Widget>[
                    // CircleAvatar(
                    //   backgroundColor: Colors.white,
                    //   radius: 30,
                    // ),
                    // SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                              border:
                                  Border.all(color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            width: 1.sw,
                            height: 77.h,
                            // color: AppColor.darkModePrim,
                          ),
                          SizedBox(height: 10.h),
                          // Container(
                          //   decoration: BoxDecoration(
                          //     color: AppColor.darkModePrim,
                          //     border: Border.all(color: Colors.black),
                          //   ),
                          //   width: double.infinity,
                          //   height: 124,
                          //   // color: AppColor.darkModePrim,
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              items: 6,
              baseColor: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
              period: Duration(seconds: 1),
              highlightColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
              direction: SkeletonDirection.ltr,
            )),
          )
        : (_samemontheventsFilter.length == 0)
            ? Center(
                child: Image(
                image: AssetImage("assets/images/journalempty.png"),
                height: 0.5.sh,
                width: 0.9.sw,
              ))
            : ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                children: _samemontheventsFilter
                    .map(
                      (event) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Container(
                                  height: 15.h,
                                  child: VerticalDivider(
                                    color: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.LightModeSecTextField
                                        : AppColor.darkModeSeco,
                                    thickness: 3,
                                  )),
                              Container(
                                width: 60.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.r),
                                  color: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.LightModeSecTextField
                                      : AppColor.darkModeSeco,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 18.r,
                                      backgroundColor: Colors.transparent,
                                      child: Icon(Iconsax.money),
                                    ),
                                    /*SizedBox(
                                  height:5.h,
                                ),*/
                                    Text(
                                      event.nameType,
                                      style: TextStyle(
                                          color:
                                              CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                          fontFamily: "Subjective",
                                          fontSize: 10.sp),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                  height: 15.h,
                                  child: VerticalDivider(
                                    color: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.LightModeSecTextField
                                        : AppColor.darkModeSeco,
                                    thickness: 3,
                                  )),
                            ],
                          ),
                          Container(
                            width: 252.w,
                            //  height: 77.h,
                            decoration: BoxDecoration(
                              //border: Border.all(width: 0.8),
                              borderRadius: BorderRadius.circular(12.0.r),
                              color: CashHelper.getData(key: ChangeTheme)
                                  ? AppColor.LightModeSecTextField
                                  : AppColor.darkModeSeco,
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 4.0.h),
                            child: ListTile(
                              onTap: () async {
                                print(event.iconType);
                                  await launch(event.iconType);
                              },
                              contentPadding: EdgeInsets.all(10.w),
                              //  minVerticalPadding: 0,
                              isThreeLine: false,
                              minLeadingWidth: 0,
                              leading: event.Image != ""
                                  ? CachedNetworkImage(
                                      imageUrl: event.Image,
                                      height: 45.w,
                                      width: 45.w,
                                      fit: BoxFit.contain,
                                      errorWidget: (context, url, error) {
                                        return SizedBox(
                                          width: 0.01,
                                          height: 0.01,
                                        );
                                      },
                                    )
                                  : SizedBox(
                                      height: 0.01,
                                      width: 0.01,
                                    ),
                              title: Text(
                                event.Item_Title,
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontFamily: "Subjective",
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),

                              trailing: event.MoodImage != ""
                                  ? CachedNetworkImage(
                                      imageUrl: event.MoodImage,
                                      height: 40.w,
                                      width: 40.w,
                                      fit: BoxFit.contain,
                                      errorWidget: (context, url, error) {
                                        return SizedBox(
                                          width: 0.01,
                                          height: 0.01,
                                        );
                                      },
                                    )
                                  : SizedBox(
                                      height: 0.01,
                                      width: 0.01,
                                    ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  event.Item_Sup_Tilte != ""
                                      ? Text(
                                          event.Item_Sup_Tilte,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? AppColor.mainBtnLightMode
                                                : AppColor.mainBtn,
                                            fontFamily: "Subjective",
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0.01,
                                        ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  event.Description != ""
                                      ? Text(
                                          event.Description,
                                          style: TextStyle(
                                            fontSize: 9.sp,
                                            fontFamily: "Subjective",
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? Colors.black
                                                : AppColor.kTextColor,
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0.01,
                                        )
                                ],
                              ),

                              // subtitle: ,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList());
  }
}
