import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/appqoutes.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/model/activite_Item.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/shared/empty_error_Image.dart';
import 'package:life_balancing/shared/floating_action_button.dart';
import 'package:life_balancing/shared/header.dart';
import 'package:life_balancing/view/Popup_item.dart';
import 'package:life_balancing/view/login.dart';
import 'package:life_balancing/view/popup_badge.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';
import 'package:toast/toast.dart';

import '../Util/ScreenHelper.dart';
import '../model/habits_item.dart';
import 'CreateHabits.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({Key key}) : super(key: key);
  @override
  _HabitsPage createState() => _HabitsPage();
}

class _HabitsPage extends State<HabitsPage> with AutomaticKeepAliveClientMixin {
  final String advice = "The great things always happen outside of your comfort zone";
  final String image_Name = "assets/images/temp@2x.png";
  String qouts;

  String _image = "";
  String _name = "";

  //HabitItem.fromJson(json)
  bool press_X = true;

  List<HabitItem> _habits = [];

  var _isLoading = true, _isInit = false;
  var _isLoadingUpdate = false;
  bool is_Win_Badge = false;
  bool is_clicked_done_popUp = false;
  bool is_Win_Reward = false;

  TextEditingController text = new TextEditingController();
  String Note;
  int mood_Id;
  List<Emoje> _emoje = [];
  var _isLoadingMood = true;

  bool _button_validation = false, _notes_validation = false;

  bool isValid = false;
  SlidableController slidableController;
  Color _fabColor = AppColor.mainBtn;
  Animation<double> _rotationAnimation;
  bool isError = false;
  int badge_id;
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  // var _isLoading = true, _isInit = false;
  Future _fetchMood() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingMood = true;
      });
      var res = await getData("api/mood", token);
      // print(json.decode(res.body)['data'][0]["id"]);

      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        //     print("\ndone\n\n");//print(res.body.toString());
        List<dynamic> emoje = json.decode(res.body)['data'];
        List<Emoje> newEmoje = [];
        for (var i = 0; i < emoje.length; i++) {
          Emoje item = new Emoje(
            emoje[i]['id'],
            emoje[i]['image'],
            emoje[i]['name'],
            false,
          );
          newEmoje.add(item);
        }
        if (mounted)
          setState(() {
            _emoje = newEmoje;
            _isLoadingMood = false;
          });
      } else {
        Toast.show(
          'Network Error'.tr(),
          context,
          backgroundColor: Colors.red,
          gravity: Toast.BOTTOM,
          duration: Toast.LENGTH_LONG,
        );
      }
    });
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {
      _rotationAnimation = slideAnimation;
    });
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {
      _fabColor = isOpen ? Colors.green : Colors.blue;
    });
  }

  @override
  void initState() {
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    if (!_isInit) {
      _simulateLoad();
      _fetchMood();
    }

    qouts = AppQoutes.qoutesList[AppQoutes.random.nextInt(204)];
    _isInit = true;
    super.initState();
  }

  int getPointsWin(int points, int timeRimining) {
    return points ~/ timeRimining;
  }

  Future<void> _simulateLoad() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      String image = prefs.getString('image');
      String name = prefs.getString('name');
      setState(() {
        _name = name;
        _image = image;
        isError = false;
        _isLoading = true;
        //  _refreshController.isRefresh;
      });
      try {
        var res = await getData("api/habit", token);
        if (res.statusCode == 401) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
        } else if (res.statusCode == 200) {
          List<dynamic> habits = json.decode(res.body)['data'];
          print("Habits\n $habits");
          List<HabitItem> newHabits = [];
          for (var i = 0; i < habits.length; i++) {
            HabitItem habitItem = new HabitItem(
              habits[i]['id'],
              habits[i]['image'],
              habits[i]['image_name'],
              habits[i]['repetition_number'],
              habits[i]['points'],
              habits[i]['name'],
              TimeOfDay.now(),
              DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
              "AnyTime",
              new PerformHabits("Daily", ["San", "Mon", "Fri"]),
              habits[i]['active_date'],
              habits[i]['section_id'],
              habits[i]['date_type'],
              //chang in api
              habits[i]['repetition_type'],
            );
            newHabits.add(habitItem);
          }
          newHabits.sort((a, b) => a.activeDate.compareTo(b.activeDate));
          if (mounted)
            setState(() {
              _habits = newHabits;
              _isLoading = false;
              isError = false;
            });
        } else {
          setState(() {
            _isLoading = false;
            isError = true;
            _refreshController.refreshFailed();
          });
        }
      } on SocketException catch (_) {
        setState(() {
          _isLoading = false;
          isError = true;
          _refreshController.refreshFailed();
        });
      }
    });
  }

  Future _updateHabit(moveType, id, item) async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingUpdate = true;
      });
      var res = await updateHabit("api/habit", moveType, id, token);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        List<dynamic> habits = json.decode(res.body)['data'];
        is_Win_Badge = json.decode(res.body)["badge"]["isOpenNewBadge"];
        is_Win_Reward = json.decode(res.body)["reword"]["isOpenNewReword"];
        if (is_Win_Badge) {
          badge_id = json.decode(res.body)["badge"]["badgeId"];
          showDialog(
              useSafeArea: true,
              context: context,
              builder: (BuildContext context) => PopUpBadge(
                    context,
                    badgeId: badge_id,
                    emoje: _emoje.map((item) => new Emoje.clone(item)).toList(),
                    entity_id: item.id,
                    entity_type: 3,
                  ));
        }
        List<HabitItem> newHabits = [];
        for (var i = 0; i < habits.length; i++) {
          HabitItem habitItem = new HabitItem(
              habits[i]['id'],
              habits[i]['image'],
              habits[i]['name'],
              habits[i]['repetition_number'],
              habits[i]['points'],
              habits[i]['name'],
              TimeOfDay.now(),
              DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
              "AnyTime",
              new PerformHabits("Daily", ["San", "Mon", "Fri"]),
              habits[i]['active_date'],
              habits[i]['section_id'],
              habits[i]['date_type'],
              habits[i]['repetition_type']);
          newHabits.add(habitItem);
        }
        newHabits.sort((a, b) => a.activeDate.compareTo(b.activeDate));
        setState(() {
          _habits = newHabits;
          _isLoadingUpdate = false;

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              moveType == 1 ? "Done".tr() : "Skip".tr(),
              style: TextStyle(
                color: AppColor.kTextColor,
                fontFamily: "Subjective",
              ),
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 1),
            backgroundColor: AppColor.mainBtn,
          ));
        });
      } else {
        setState(() {
          _isLoadingUpdate = false;
        });
        Toast.show(
          'Network Error'.tr(),
          context,
          backgroundColor: Colors.red,
          gravity: Toast.BOTTOM,
          duration: Toast.LENGTH_LONG,
        );
      }
    });
  }

  Future _deleteHabit(id, HabitItem habits) async {
    Navigator.of(context).pop();
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingUpdate = true;
      });
      var res = await deleteHabit("api/habit", id, token);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        setState(() {
          _habits.remove(habits);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Deleted ".tr(),
              style: TextStyle(
                color: AppColor.kTextColor,
                fontFamily: "Subjective",
              ),
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 1),
            backgroundColor: AppColor.mainBtn,
          ));
          _isLoadingUpdate = false;
        });
      } else {
        setState(() {
          _isLoadingUpdate = false;
        });
        Toast.show(
          'Network Error'.tr(),
          context,
          backgroundColor: Colors.red,
          gravity: Toast.BOTTOM,
          duration: Toast.LENGTH_LONG,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return Scaffold(
        floatingActionButton: FloatingActionButtons(),
        backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
        body: LoadingOverlay(
          child: SmartRefresher(
            header: WaterDropHeader(
                waterDropColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
            //physics: BouncingScrollPhysics(),
            enablePullDown: true,
            enableTwoLevel: true,

            onRefresh: () {
              if (mounted)
                setState(() async {
                  await _simulateLoad();
                  _refreshController.refreshCompleted();
                });
            },

            controller: _refreshController,
            child: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: ScreenHelper.fromWidth(4.0),
                    left: ScreenHelper.fromWidth(4.0),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      HeaderCard(
                        name: _name,
                        image: _image,
                        refrechPage: (val) {
                          if (val) {
                            setState(() {});
                          }
                        },
                      ),
                      SizedBox(height: 10.h),
                      press_X
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0.r),
                                color: CashHelper.getData(key: ChangeTheme)
                                    ? AppColor.LightModeSecTextField
                                    : AppColor.darkModeSeco,
                              ),
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Iconsax.quote_down5,
                                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                    size: 30.r,
                                  ),
                                  SizedBox(
                                    width: 230.0,
                                    child: DefaultTextStyle(
                                      style: TextStyle(
                                          color:
                                              CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                          fontSize: 12.sp,
                                          fontFamily: "Subjective",
                                          fontWeight: FontWeight.normal),
                                      child: AnimatedTextKit(
                                        repeatForever: false,
                                        totalRepeatCount: 1,
                                        animatedTexts: [
                                          TyperAnimatedText(qouts),
                                        ],
                                        onTap: () {
                                          print("Tap Event");
                                        },
                                      ),
                                    ),
                                  ),
                                  /*Expanded(
                                        child: Text(
                                          qouts,
                                          style: TextStyle(
                                              color: AppColor.kTextColor,
                                              fontSize: 12.sp,
                                              fontFamily: "Subjective",
                                              fontWeight: FontWeight.normal),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),*/
                                  GestureDetector(
                                    child: Icon(
                                      Iconsax.close_circle5,
                                      color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                      size: 20.r,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        press_X = !press_X;
                                      });
                                    },
                                  ),
                                  //_buildExpandedText(advice),
                                ],
                              ),
                            )
                          : const SizedBox(
                              height: 0.01,
                            ),
                      SizedBox(
                        height: 10.h,
                      ),
                      !isError
                          ? _isLoading
                              ? (SkeletonLoader(
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
                                                  color: CashHelper.getData(key: ChangeTheme)
                                                      ? AppColor.lightModePrim
                                                      : AppColor.darkModePrim,
                                                  border: Border.all(color: Colors.black),
                                                  borderRadius: BorderRadius.circular(10.r),
                                                ),

                                                width: 348.w,
                                                height: 63.h,
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
                                  baseColor: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.LightModeSecTextField
                                      : AppColor.darkModeSeco,
                                  period: Duration(seconds: 1),
                                  highlightColor: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.mainBtnLightMode
                                      : AppColor.mainBtn,
                                  direction: SkeletonDirection.ltr,
                                ))
                              : _habits.length > 0
                                  ? ListView.builder(
                                      itemCount: _habits.length,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                int point =
                                                    getPointsWin(_habits[index].points, _habits[index].times_Remaining);
                                                final List<Emoje> mode_Active1 = List.generate(
                                                    6,
                                                    (index) => new Emoje(
                                                        index, "https://ai-gym.club/uploads/angel.gif", "Mood", false));
                                                checkDate(DateTime.now(), DateTime.parse(_habits[index].activeDate))
                                                    ? Navigator.of(context).push(MaterialPageRoute(
                                                        builder: (_) => CreateHabitsPage(
                                                              HeaderName: "Edit Habit",
                                                              ButtonNamr: "Update Habit",
                                                              item: _habits[index],
                                                            )))
                                                    : null;
                                              },
                                              child: Slidable(
                                                actionPane: SlidableBehindActionPane(),
                                                actionExtentRatio: 0.25,
                                                controller: slidableController,
                                                closeOnScroll: true,
                                                movementDuration: Duration(microseconds: 500),
                                                //fastThreshold: 2,

                                                actions: <Widget>[
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        width: 75.w,
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(15.0.r),
                                                          color: checkDate(DateTime.now(),
                                                                  DateTime.parse(_habits[index].activeDate))
                                                              ? CashHelper.getData(key: ChangeTheme)
                                                                  ? AppColor.mainBtnLightMode.withOpacity(0.2)
                                                                  : AppColor.mainBtn.withOpacity(0.2)
                                                              : CashHelper.getData(key: ChangeTheme)
                                                                  ? AppColor.LightModeSecTextField.withOpacity(1)
                                                                  : AppColor.darkModeSeco.withOpacity(1),
                                                        ),
                                                        child: IconSlideAction(
                                                          caption: "Done".tr(),
                                                          closeOnTap: true,
                                                          color: Colors.transparent,
                                                          /*icon: Icons
                                                          .done_outline_outlined,*/
                                                          iconWidget: Icon(
                                                            Icons.check_circle,
                                                            color: CashHelper.getData(key: ChangeTheme)
                                                                ? AppColor.mainBtnLightMode
                                                                : AppColor.mainBtn,
                                                            size: 30.r,
                                                          ),
                                                          onTap: () {
                                                            if (_habits[index].times_Remaining <= 1 &&
                                                                checkDate(DateTime.now(),
                                                                    DateTime.parse(_habits[index].activeDate))) {
                                                              final List<Emoje> mode_Active1 = List.generate(
                                                                  6,
                                                                  (index) => new Emoje(
                                                                      index,
                                                                      "https://ai-gym.club/uploads/angel.gif",
                                                                      "Mood",
                                                                      false));

                                                              showDialog(
                                                                useSafeArea: true,
                                                                context: context,
                                                                builder: (BuildContext context) => PopUpItem(
                                                                  context,
                                                                  PopupName: "Habits",
                                                                  emoje: _emoje
                                                                      .map((item) => new Emoje.clone(item))
                                                                      .toList(),
                                                                  points: _habits[index].points,
                                                                  entity_id: _habits[index].id,
                                                                  entity_type: 2,
                                                                  /*is_Win_badge:
                                                                      is_Win_Badge,*/
                                                                ),
                                                              ); /*.then((_) =>
                                                                  is_Win_Badge
                                                                      ? showDialog(
                                                                          useSafeArea:
                                                                              true,
                                                                          context:
                                                                              context,
                                                                          builder: (BuildContext context) =>
                                                                              PopUpBadge(
                                                                                context,
                                                                                badgeId: badge_id,
                                                                                emoje: _emoje.map((item) => new Emoje.clone(item)).toList(),
                                                                                entity_id: _habits[index].id,
                                                                                entity_type: 3,
                                                                              ))
                                                                      : null);*/
                                                              /* if (is_Win_Badge &&
                                                                  is_clicked_done_popUp) {

                                                              }*/
                                                            }
                                                            var parsedDate = DateTime.parse(_habits[index].activeDate);
                                                            var now = DateTime.now();
                                                            if (now.isAfter(parsedDate)) {
                                                              _updateHabit(1, _habits[index].id, _habits[index]);
                                                            } else {
                                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                content: Text(
                                                                  "Waiting to : ".tr() +
                                                                      _habits[index].activeDate.toString() +
                                                                      " to Activated".tr(),
                                                                  style: TextStyle(
                                                                    color: CashHelper.getData(key: ChangeTheme)
                                                                        ? Colors.black
                                                                        : AppColor.kTextColor,
                                                                    fontFamily: "Subjective",
                                                                  ),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                duration: Duration(seconds: 1),
                                                                backgroundColor: AppColor.emotionsSections,
                                                              ));
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                secondaryActions: <Widget>[
                                                  //skip slidable
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        width: 75.w,
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(15.0.r),
                                                          color: checkDate(DateTime.now(),
                                                                  DateTime.parse(_habits[index].activeDate))
                                                              ? CashHelper.getData(key: ChangeTheme)
                                                                  ? AppColor.mainBtnLightMode.withOpacity(0.2)
                                                                  : AppColor.mainBtn.withOpacity(0.2)
                                                              : CashHelper.getData(key: ChangeTheme)
                                                                  ? AppColor.LightModeSecTextField.withOpacity(2)
                                                                  : AppColor.darkModeSeco.withOpacity(1),
                                                        ),
                                                        child: IconSlideAction(
                                                          caption: "Skip".tr(),
                                                          closeOnTap: true,
                                                          color: Colors.transparent,
                                                          /*icon: Icons
                                                          .done_outline_outlined,*/
                                                          iconWidget: Icon(
                                                            Icons.cancel,
                                                            color: AppColor.emotionsSections,
                                                            size: 30.r,
                                                          ),
                                                          onTap: () {
                                                            if (_habits[index].times_Remaining <= 1 &&
                                                                checkDate(DateTime.now(),
                                                                    DateTime.parse(_habits[index].activeDate))) {
                                                              final List<Emoje> mode_Active1 = List.generate(
                                                                  6,
                                                                  (index) => new Emoje(
                                                                      index,
                                                                      "https://ai-gym.club/uploads/angel.gif",
                                                                      "Mood",
                                                                      false));

                                                              showDialog(
                                                                useSafeArea: true,
                                                                context: context,
                                                                builder: (BuildContext context) => PopUpItem(
                                                                  context,
                                                                  PopupName: "Habits",
                                                                  emoje: _emoje
                                                                      .map((item) => new Emoje.clone(item))
                                                                      .toList(),
                                                                  points: _habits[index].points,
                                                                  entity_id: _habits[index].id,
                                                                  entity_type: 2,
                                                                  /*  is_Win_badge:
                                                                      is_Win_Badge,*/
                                                                ),
                                                              ) /*.then((_) =>
                                                                  is_Win_Badge
                                                                      ? showDialog(
                                                                          useSafeArea:
                                                                              true,
                                                                          context:
                                                                              context,
                                                                          builder: (BuildContext context) =>
                                                                              PopUpBadge(
                                                                                context,
                                                                                badgeId: badge_id,
                                                                                emoje: _emoje.map((item) => new Emoje.clone(item)).toList(),
                                                                                entity_id: _habits[index].id,
                                                                                entity_type: 3,
                                                                                // points: 10000,
                                                                              ))
                                                                      : null)*/
                                                                  ;
                                                            }
                                                            var parsedDate = DateTime.parse(_habits[index].activeDate);
                                                            var now = DateTime.now();
                                                            if (now.isAfter(parsedDate)) {
                                                              _updateHabit(2, _habits[index].id, _habits[index]);
/*
                                                              if (is_Win_Badge) {
                                                                showDialog(
                                                                    useSafeArea:
                                                                        true,
                                                                    context:
                                                                        context,
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        PopUpBadge(
                                                                          context,
                                                                          badge_Url:
                                                                              "assets/images/temp@2x.png",
                                                                          badge_Name:
                                                                              "test",
                                                                          emoje:
                                                                              _emoje,
                                                                          entity_id:
                                                                              _habits[index].id,
                                                                          entity_type:
                                                                              2,
                                                                          points:
                                                                              _habits[index].points,
                                                                        ));
                                                              }
*/
                                                              /*ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                        content: Text(
                                                          "Skip ",
                                                          style: TextStyle(
                                                            color: AppColor
                                                                .kTextColor,
                                                            fontFamily:
                                                                "Subjective",
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        duration:
                                                            Duration(seconds: 1),
                                                        backgroundColor:
                                                            AppColor.mainBtn,
                                                      ));*/
                                                            } else {
                                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                content: Text(
                                                                  "Waiting to : ".tr() +
                                                                      _habits[index].activeDate.toString() +
                                                                      " to Activated",
                                                                  style: TextStyle(
                                                                    color: CashHelper.getData(key: ChangeTheme)
                                                                        ? Colors.black
                                                                        : AppColor.kTextColor,
                                                                    fontFamily: "Subjective",
                                                                  ),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                duration: Duration(seconds: 1),
                                                                backgroundColor: AppColor.emotionsSections,
                                                              ));
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      /////////////////////////////////////////////////////
                                                    ],
                                                  ),

                                                  //delete
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        width: 75.w,
                                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(15.0.r),
                                                          color: checkDate(DateTime.now(),
                                                                  DateTime.parse(_habits[index].activeDate))
                                                              ? CashHelper.getData(key: ChangeTheme)
                                                                  ? AppColor.mainBtnLightMode.withOpacity(0.1)
                                                                  : AppColor.mainBtn.withOpacity(0.2)
                                                              : CashHelper.getData(key: ChangeTheme)
                                                                  ? AppColor.LightModeSecTextField.withOpacity(1)
                                                                  : AppColor.darkModeSeco.withOpacity(1),
                                                        ),
                                                        child: IconSlideAction(
                                                          caption: "Delete",
                                                          closeOnTap: true,
                                                          color: Colors.transparent,
                                                          /*icon: Icons
                                                          .done_outline_outlined,*/
                                                          iconWidget: Icon(
                                                            Icons.delete,
                                                            size: 30.r,
                                                            color: /*checkDate(
                                                                    DateTime
                                                                        .now(),
                                                                    DateTime.parse(
                                                                        _habits[index]
                                                                            .activeDate))
                                                                ? AppColor
                                                                    .emotionsSections
                                                                :*/
                                                                AppColor.emotionsSections,
                                                          ),
                                                          onTap: () {
                                                            showDialog(
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    backgroundColor:
                                                                        CashHelper.getData(key: ChangeTheme)
                                                                            ? AppColor.lightModePrim
                                                                            : AppColor.darkModePrim,
                                                                    scrollable: true,
                                                                    title: const Text('Delete Goal'),
                                                                    titleTextStyle: TextStyle(
                                                                      color: CashHelper.getData(key: ChangeTheme)
                                                                          ? Colors.black
                                                                          : AppColor.kTextColor,
                                                                      fontFamily: "Subjective",
                                                                    ),
                                                                    content: Text(
                                                                      "Do You Want To Delete This Habits !!",
                                                                      style: TextStyle(
                                                                        color: CashHelper.getData(key: ChangeTheme)
                                                                            ? Colors.black
                                                                            : AppColor.kTextColor,
                                                                        fontSize: 15.sp,
                                                                        fontFamily: "Subjective",
                                                                      ),
                                                                    ),
                                                                    actions: <Widget>[
                                                                      new TextButton(
                                                                        onPressed: () {
                                                                          setState(() {
                                                                            //add task id and goal id

                                                                            _deleteHabit(
                                                                                _habits[index].id, _habits[index]);

                                                                            //task_name_Controler.text = "";
                                                                          });
                                                                        },
                                                                        //textColor: Theme.of(context).primaryColor,
                                                                        child: Text(
                                                                          'OK',
                                                                          style: TextStyle(
                                                                            color: CashHelper.getData(key: ChangeTheme)
                                                                                ? Colors.black
                                                                                : AppColor.kTextColor,
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
                                                                          'back',
                                                                          style: TextStyle(
                                                                            color: CashHelper.getData(key: ChangeTheme)
                                                                                ? Colors.black
                                                                                : AppColor.kTextColor,
                                                                            fontFamily: "Subjective",
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                                context: context);
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],

                                                //enabled:true,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15.0.r),
                                                    //change the item color
                                                    color: checkDate(
                                                            DateTime.now(), DateTime.parse(_habits[index].activeDate))
                                                        ? CashHelper.getData(key: ChangeTheme)
                                                            ? AppColor.mainBtnLightMode.withOpacity(0.2)
                                                            : AppColor.mainBtn.withOpacity(0.2)
                                                        : CashHelper.getData(key: ChangeTheme)
                                                            ? AppColor.LightModeSecTextField.withOpacity(1)
                                                            : AppColor.darkModeSeco.withOpacity(1),
                                                  ),
                                                  padding: EdgeInsets.all(5.w),
                                                  child: Container(
                                                    /*height: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                5,*/
                                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                    child: ListTile(
                                                      leading: CircleAvatar(
                                                        radius: 25.r,
                                                        // backgroundImage: NetworkImage(image),
                                                        backgroundColor: Colors.transparent,
                                                        child: CachedNetworkImage(
                                                          imageUrl: _habits[index].image,
                                                          errorWidget: (context, url, error) => Icon(
                                                            Icons.error,
                                                            color: CashHelper.getData(key: ChangeTheme)
                                                                ? AppColor.mainBtnLightMode
                                                                : AppColor.mainBtn,
                                                          ),
                                                        ),
                                                      ),
                                                      title: Text(
                                                        _habits[index].habits_name,
                                                        style: TextStyle(
                                                            color: CashHelper.getData(key: ChangeTheme)
                                                                ? Colors.black
                                                                : AppColor.kTextColor,
                                                            fontSize: 15.sp,
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily: "Subjective",
                                                            decoration: checkDate(DateTime.now(),
                                                                    DateTime.parse(_habits[index].activeDate))
                                                                ? TextDecoration.none
                                                                : TextDecoration.lineThrough),
                                                      ),
                                                      subtitle: Text(
                                                        _habits[index].times_Remaining.toString() + " Times Remaining",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.normal,
                                                            fontSize: 10.sp,
                                                            fontFamily: "Subjective",
                                                            color: CashHelper.getData(key: ChangeTheme)
                                                                ? AppColor.mainBtnLightMode
                                                                : AppColor.mainBtn),
                                                      ),
                                                      trailing: Column(
                                                        children: [
                                                          Text(
                                                            "+" + _habits[index].points.toString() + " pts",
                                                            style: TextStyle(
                                                                color: CashHelper.getData(key: ChangeTheme)
                                                                    ? AppColor.mainBtnLightMode
                                                                    : AppColor.mainBtn,
                                                                fontFamily: "Subjective",
                                                                fontSize: 16.sp),
                                                          ),
                                                          SizedBox(
                                                            height: 10.h,
                                                          ),
                                                          checkDate(DateTime.now(),
                                                                  DateTime.parse(_habits[index].activeDate))
                                                              ? SizedBox(
                                                                  width: 0.01.w,
                                                                  height: 0.01.h,
                                                                )
                                                              : Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Text(
                                                                      "Time Until Next Habit:",
                                                                      style: TextStyle(
                                                                        fontSize: 10.sp,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: CashHelper.getData(key: ChangeTheme)
                                                                            ? AppColor.mainBtnLightMode
                                                                            : AppColor.mainBtn,
                                                                        fontFamily: "Subjective",
                                                                      ),
                                                                    ),
                                                                    SlideCountdownClock(
                                                                      shouldShowDays: true,
                                                                      // padding: EdgeInsets.all(2),
                                                                      /* decoration:
                                                        BoxDecoration(color: Colors.grey.withOpacity(0.2), shape: BoxShape.rectangle),*/
                                                                      duration: Duration(
                                                                        days:
                                                                            ((DateTime.parse(_habits[index].activeDate)
                                                                                    .day) -
                                                                                DateTime.now().day),
                                                                        hours:
                                                                            ((DateTime.parse(_habits[index].activeDate)
                                                                                    .hour) -
                                                                                DateTime.now().hour),
                                                                        seconds:
                                                                            ((DateTime.parse(_habits[index].activeDate)
                                                                                    .second) -
                                                                                DateTime.now().second),
                                                                      ),
                                                                      slideDirection: SlideDirection.Up,
                                                                      separator: ":",
                                                                      textStyle: TextStyle(
                                                                        fontSize: 10.sp,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: CashHelper.getData(key: ChangeTheme)
                                                                            ? AppColor.mainBtnLightMode
                                                                            : AppColor.mainBtn,
                                                                        fontFamily: "Subjective",
                                                                      ),

                                                                      onDone: () {
                                                                        print("Habits Active");
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                        ],
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        mainAxisAlignment: checkDate(DateTime.now(),
                                                                DateTime.parse(_habits[index].activeDate))
                                                            ? MainAxisAlignment.center
                                                            : MainAxisAlignment.spaceEvenly,
                                                      ),
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 1.w),
                                                      // contentPadding: EdgeInsets.all(MediaQuery.of(context).size.width/37.5),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Divider(),
                                          ],
                                        );
                                      },
                                    )
                                  : ErrorEmptyItem(
                                      ImagePath: "assets/images/Habits2x.png",
                                      Title: "No Habits Yet!!!",
                                      SupTitle: "Set your first Habit by pressing the button and selecting new Habits.",
                                      TitleColor: CashHelper.getData(key: ChangeTheme)
                                          ? AppColor.mainBtnLightMode
                                          : AppColor.mainBtn,
                                    )
                          : ErrorEmptyItem(
                              ImagePath: "assets/images/error2x.png",
                              Title: "An Error Occured",
                              SupTitle:
                                  "this time it's our Mistake, sorry for inconvenience and we will fix this issue Asap!!!",
                              TitleColor:
                                  CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
                    ],
                  ),
                ),
              ),
            ),
          ),
          isLoading: _isLoadingUpdate,
          // additional parameters
          opacity: 0.5,
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
          progressIndicator: CircularProgressIndicator(
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
        ));
  }

  bool checkDate(DateTime dt1, DateTime dt2) {
    bool res = dt1.isAfter(dt2);
    return res;
  }

  @override
  bool get wantKeepAlive => true;
}

//List<HabitItem> content = Habits.new_Habits;
/*HabitItem(
    "assets/images/onboarding2.png",
    "Visiting My Famile",
    3,
    50,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  ),
  HabitItem(
    "assets/images/onboarding1.png",
    "Eating Healthy",
    4,
    75,
  )*/
