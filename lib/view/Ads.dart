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

class AdsPage extends StatefulWidget {
  @override
  _AdsPage createState() => _AdsPage();
}

class _AdsPage extends State<AdsPage> {
  static List<dynamic> ads = [];
  var isPortrait;
  bool expand_Calender = true;
  DateTime kToday = DateTime.now();
  DateTime kFirstDay;
  DateTime kLastDay;

  String dateSelected;
  bool _isLoadingUpdate = false,
      _isInit = false;

  bool isValid = false;
  bool isError = false;

  RefreshController _refreshController = RefreshController(
      initialRefresh: false);
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
        var res = await getData("api/admin/ads", token);
        print(json.decode(res.body)['data']);
        if (res.statusCode == 401) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => LoginPage()));
        } else if (res.statusCode == 200) {
          print(json.decode(res.body));
          List<dynamic> data = json.decode(res.body)['data'];

          setState(() {
            ads = data;
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
      backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor
          .lightModePrim : AppColor.darkModePrim,
      body: SmartRefresher(
        header:
        WaterDropHeader(
            waterDropColor: CashHelper.getData(key: ChangeTheme) ? AppColor
                .mainBtn : AppColor.mainBtn),
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
                  mainAxisAlignment: !isError
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.center,
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
                    child: Expanded(child: SingleChildScrollView(
                        child: build_event_for_day())),
                  );
                })
                    : ErrorEmptyItem(
                  ImagePath: "assets/images/error2x.png",
                  Title: "An Error Occured".tr(),
                  SupTitle:
                  "this time it's our Mistake, sorry for inconvenience and we will fix this issue Asap!!!"
                      .tr(),
                  TitleColor: CashHelper.getData(key: ChangeTheme) ? AppColor
                      .mainBtnLightMode : AppColor.mainBtn,
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
          color: CashHelper.getData(key: ChangeTheme) ? AppColor
              .LightModeSecTextField : AppColor.darkModeSeco,
        ),
        child: IconButton(
          color: CashHelper.getData(key: ChangeTheme) ? AppColor
              .mainBtnLightMode : AppColor.mainBtn,
          highlightColor: CashHelper.getData(key: ChangeTheme) ? AppColor
              .LightModeSecTextField : AppColor.darkModeSeco,
          // splashRadius: 40,
          onPressed: () {
            setState(() {

            });
          },
          icon: Icon(Iconsax.bag),
        ),
      ),
    );
  }

  Widget build_journal_title() {
    return Text(
      'advertisements'.tr(),
      style: TextStyle(
        color: CashHelper.getData(key: ChangeTheme)
            ? AppColor.mainBtnLightMode
            : AppColor.mainBtn,
        fontFamily: "Subjective",
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget build_event_for_day() {
    isPortrait = MediaQuery
        .of(context)
        .orientation == Orientation.portrait;
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
                        CashHelper.getData(key: ChangeTheme) ? AppColor
                            .lightModePrim : AppColor.darkModePrim,
                        border:
                        Border.all(color: CashHelper.getData(key: ChangeTheme)
                            ? Colors.black
                            : Colors.white),
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
        baseColor: CashHelper.getData(key: ChangeTheme) ? AppColor
            .LightModeSecTextField : AppColor.darkModeSeco,
        period: Duration(seconds: 1),
        highlightColor: CashHelper.getData(key: ChangeTheme) ? AppColor
            .mainBtnLightMode : AppColor.mainBtn,
        direction: SkeletonDirection.ltr,
      )),
    )
        : (ads.length == 0)
        ? Center(
        child: Image(
          image: AssetImage("assets/images/journalempty.png"),
          height: 0.5.sh,
          width: 0.9.sw,
        ))
        : ListView.builder(
        padding: EdgeInsets.all(2.w),
        itemCount: ads.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Column(
            children: [
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(5.r),
                  height: 114.h,
                  width: 1.sw,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    // color: AppColor.darkModeSeco,
                    image: DecorationImage(
                      image: /* AssetImage(
                                                "assets/images/Group1221.png")*/
                      NetworkImage(ads[index]['image']),
                      /*onError: (exception, stackTrace) {
                                              return Icon(
                                                  Icons.hourglass_empty);
                                            },*/
                      fit: BoxFit.contain,
                    ),
                    /*border: Border.all(
                                                color: Colors.amber)*/
                  ),
                ),
                onTap: () async {
                  await launch(ads[index]['url']);
                },
              ),
              SizedBox(
                height: 10.h,
              )
            ],
          );
        });
  }
}
