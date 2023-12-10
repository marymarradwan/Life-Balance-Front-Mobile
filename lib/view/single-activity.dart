import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/view/popup_badge.dart';
import 'package:life_balancing/view/result_single_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:toast/toast.dart';

import '../Util/ScreenHelper.dart';
import '../model/activite_Item.dart';
import '../services/auth.dart';
import 'MoreActivite.dart';
import 'login.dart';

class SingleActivityPage extends StatefulWidget {
  @override
  _SingleActivityPage createState() => _SingleActivityPage();
}

class _SingleActivityPage extends State<SingleActivityPage> {
  singleActivity single_Activite;
  String image_Name = "assets/images/temp@2x.png";
  String image_mood_path;
  String image_mood_name;
  bool image_mood_Clicked;
  int Emoje_index;
  int Activity_id;
  String Activity_image;
  singleActivity activite;
  Emoje mood;
  DateTime from_time;
  DateTime to_Time;
  String notes;
  bool is_Clicked_Category = false;
  List<bool> Categry = [false, false, false, false, false, false];
  List<Emoje> mode_Active =
      List.generate(18, (index) => new Emoje(index, "https://ai-gym.club/uploads/angel.gif", "Mood", false));
  String Categry_name;
  int Section_index;
  String name;
  TextEditingController time_from = new TextEditingController();
  TextEditingController tlme_to = new TextEditingController();
  Map<int, SectionActivities> Single_Section_activite = {};
  List<Emoje> _emoje = [];

  /*TimeOfDay FromDate;
  TimeOfDay TODate;*/
  //String Notes_or_Comments;
  final List<bool> emoje_Clicked = [];
  bool init = true;

  var _isLoading = true, _isInit = false;
  var _isLoadingMood = true;
  bool is_valid = false;

  //validation single activity
  bool _button_validation = false, _fromTime_validation = false, _toTimevalidation = false, _notes_validation = false;

  bool is_Win_Badge = false;
  bool is_Win_Reward = false;
  int badge_id;
  @override
  void initState() {
    if (!_isInit) {
      _LoadSectionActivity();
      _fetchMood();
    }
    _isInit = true;
    super.initState();
  }

  Future _LoadSectionActivity() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);

      var res = await getData("api/section", token);
      print(res.statusCode);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        var Section = json.decode(res.body)['data'] as List<dynamic>;
        print(Section);
        // Map<int, Activite> _newactivities = {};
        Map<int, SectionActivities> _newactivities = {};

        Section.forEach((element) {
          _newactivities.putIfAbsent(
              element["id"],
              () => SectionActivities(
                    element["id"],
                    element["name"],
                    (element['activities'] as List<dynamic>)
                        .map((item) => singleActivity(
                              item["id"],
                              item["section_id"],
                              item["name"],
                              item["image"],
                              item["points"],
                              false,
                              false,
                              false,
                              _emoje,
                              null,
                              DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                              DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 8),
                              null,
                            ))
                        .toList(),
                  ));
        });

        print(_newactivities);
        setState(() {
          //  _habits = newHabits;
          Single_Section_activite = _newactivities;
          _isLoading = false;
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

  Future _fetchMood() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);

      var res = await getData("api/mood", token);
      // print(json.decode(res.body)['data'][0]["id"]);
      //  print(res.statusCode);
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

  Future _Do_Activity() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);

      var res = await createSingleActivite(
          "api/activities/do-activity", Activity_id, Emoje_index, notes, time_from.text, tlme_to.text, null, token);
      // print(json.decode(res.body)['data'][0]["id"]);

      print(res.body.toString());
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        is_Win_Badge = json.decode(res.body)["badge"]["isOpenNewBadge"];
        is_Win_Reward = json.decode(res.body)["reword"]["isOpenNewReword"];
        if (is_Win_Badge) {
          badge_id = json.decode(res.body)["badge"]["badgeId"];
        }
        print("\ndone\n\n"); //print(res.body.toString());
        print(res.body.toString());
        single_Activite = new singleActivity(activite.id, activite.Section_id, activite.name, activite.image,
            activite.points, activite.isClicked, false);

        /* activite,
                new Emoje(image_mood_path, image_mood_name, image_mood_Clicked),
                from_time,
                to_Time,
                notes*/ /*);*/
        // print(image_mood_path);
        // print(image_mood_path);
        if (is_Win_Badge) {
          showDialog(
              useSafeArea: true,
              context: context,
              builder: (BuildContext context) => PopUpBadge(
                    context,
                    badgeId: badge_id,
                    emoje: _emoje.map((item) => new Emoje.clone(item)).toList(),
                    entity_id: activite.id,
                    entity_type: 3,
                    // points: 10000,
                  )).then((_) => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Resulte(
                    Single_activite: single_Activite,
                    Emoje_path: image_mood_path,
                  ))));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Resulte(
                    Single_activite: single_Activite,
                    Emoje_path: image_mood_path,
                  )));
        }
        /*if (!is_Win_Badge) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Resulte(
                    Single_activite: single_Activite,
                    Emoje_path: image_mood_path,
                  )));
        }*/
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

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return Scaffold(
      backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              right: ScreenHelper.fromWidth(4.0),
              left: ScreenHelper.fromWidth(4.0),
            ),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 10.0.h),
                  Text(
                    'New Action'.tr(),
                    style: TextStyle(
                      color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                      fontFamily: "Subjective",
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  build_Grid_Cateogry(),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _isLoading
                          ? Container(
                              width: 90.w,
                              child: SkeletonLoader(
                                builder: Container(
                                  height: 22.h,
                                  // width: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: CashHelper.getData(key: ChangeTheme)
                                          ? AppColor.lightModePrim
                                          : AppColor.darkModePrim,
                                      border: Border.all(color: Colors.black)),
                                ),
                                items: 1,
                                period: Duration(seconds: 1),
                                highlightColor:
                                    CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                                direction: SkeletonDirection.ltr,
                                baseColor: CashHelper.getData(key: ChangeTheme)
                                    ? AppColor.LightModeSecTextField
                                    : AppColor.darkModeSeco,
                              ),
                            )
                          : Text(
                              "Select Activite".tr(),
                              style: TextStyle(
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                  fontFamily: "Subjective",
                                  fontSize: 12.sp),
                            ),
                      SizedBox(
                        width: 80.w,
                      ),
                      _isLoading
                          ? Container(
                              width: 111.w,
                              child: SkeletonLoader(
                                builder: Container(
                                  height: 22.h,
                                  // width: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: CashHelper.getData(key: ChangeTheme)
                                          ? AppColor.lightModePrim
                                          : AppColor.darkModePrim,
                                      border: Border.all(color: Colors.black)),
                                ),
                                items: 1,
                                period: Duration(seconds: 1),
                                highlightColor:
                                    CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                                direction: SkeletonDirection.ltr,
                                baseColor: CashHelper.getData(key: ChangeTheme)
                                    ? AppColor.LightModeSecTextField
                                    : AppColor.darkModeSeco,
                              ),
                            )
                          : ButtonTheme(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                    CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.LightModeSecTextField
                                        : AppColor.darkModeSeco,
                                  ),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0.r),
                                      side: BorderSide(
                                          color: CashHelper.getData(key: ChangeTheme)
                                              ? AppColor.lightModePrim
                                              : AppColor.darkModePrim),
                                    ),
                                  ),
                                  minimumSize: MaterialStateProperty.all<Size>(Size(111.w, 32.h)),
                                ),
                                onPressed: (Section_index != 0 && Section_index != null)
                                    ? () async {
                                        var val = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => MoreActivite(
                                                      name_Activite: Categry_name,
                                                      activite: Single_Section_activite[Section_index].activities,
                                                      Section_id: Single_Section_activite[Section_index].id,
                                                      Section_image: "assets/images/temp@2x.png",
                                                      type: 1,
                                                    )));
                                        setState(() {});
                                      }
                                    : null,
                                child: Row(
                                  children: [
                                    Text(
                                      "More Activites".tr(),
                                      style: TextStyle(
                                          color:
                                              CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                          fontFamily: "Subjective",
                                          fontSize: 16.sp),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Container(
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: CashHelper.getData(key: ChangeTheme)
                                            ? AppColor.lightModePrim
                                            : AppColor.darkModePrim,
                                        size: 16.r,
                                      ),
                                      decoration: BoxDecoration(
                                          color:
                                              CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                          borderRadius: BorderRadius.circular(17.r)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(5.w),
                    width: 1.sw,
                    height: 0.5.sh,
                    /*decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent),*/ /*build_Single_Activite_Card()*/
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Categry_name != null
                          ? build_Activite_Section(Single_Section_activite, Categry_name)
                          : _isLoading
                              ? LimitedBox(
                                  maxHeight: 400.h,
                                  maxWidth: 1.sw,
                                  child: (SkeletonGridLoader(
                                    builder: Container(
                                      height: 138.w,
                                      width: 138.w,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.r),
                                          color: CashHelper.getData(key: ChangeTheme)
                                              ? AppColor.lightModePrim
                                              : AppColor.darkModePrim,
                                          border: Border.all(color: Colors.black)),
                                    ),
                                    items: 6,
                                    itemsPerRow: 3,
                                    period: Duration(seconds: 1),
                                    highlightColor: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.mainBtnLightMode
                                        : AppColor.mainBtn,
                                    direction: SkeletonDirection.ltr,
                                    childAspectRatio: 1,
                                    baseColor: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.LightModeSecTextField
                                        : AppColor.darkModeSeco,
                                  )),
                                )
                              : Container(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 0.2.sw),
                                      child: Text(
                                        "Select Category".tr(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.sp,
                                            fontFamily: "Subjective",
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? Colors.black
                                                : AppColor.kTextColor),
                                      ),
                                    ),
                                  ),
                                ),
                    ),
                  ),

                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    padding: EdgeInsets.all(15.w),
                    width: 1.sw,
                    height: 0.5.sh,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: CashHelper.getData(key: ChangeTheme)
                            ? AppColor.LightModeSecTextField
                            : AppColor.darkModeSeco),
                    child: Column(
                      children: [
                        Text(
                          "How This Activity Make You Feel ?".tr(),
                          style: TextStyle(
                              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                              fontFamily: "Subjective",
                              fontSize: 12.sp),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        _isLoadingMood
                            ? Container(
                                /* width: 1.sw,
                          height: 0.5.sh,*/
                                child: (SkeletonGridLoader(
                                    builder: Container(
                                      width: 80.w,
                                      height: 1.sw / 8,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.r),
                                          color: CashHelper.getData(key: ChangeTheme)
                                              ? AppColor.LightModeSecTextField
                                              : AppColor.darkModeSeco,
                                          border: Border.all(color: Colors.black)),
                                    ),
                                    items: 18,
                                    itemsPerRow: 6,
                                    period: Duration(seconds: 1),
                                    highlightColor: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.mainBtnLightMode
                                        : AppColor.mainBtn,
                                    direction: SkeletonDirection.ltr,
                                    childAspectRatio: 0.5,
                                    baseColor: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.lightModePrim
                                        : AppColor.darkModePrim)),
                              )
                            : Container(
                                width: 1.sw,
                                height: 320.h,
                                child: GridView.builder(
                                  //physics:  NeverScrollableScrollPhysics(),
                                  itemCount: _emoje.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.5,
                                  ),
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return build_Single_Emoje(_emoje[index], () {
                                      setState(() {
                                        FocusScope.of(context).unfocus();
                                        _emoje.forEach((element) {
                                          element.isClicked = false;
                                        });
                                        _emoje[index].isClicked = true;
                                      });
                                      image_mood_path = _emoje[index].emoje_path;
                                      image_mood_name = _emoje[index].emoje_name;
                                      image_mood_Clicked = _emoje[index].isClicked;
                                      Emoje_index = _emoje[index].id;
                                      print(Emoje_index);
                                    });
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  //
                  Container(
                    padding: EdgeInsets.all(10),
                    //width: 336.0,
                    //height: 180.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: CashHelper.getData(key: ChangeTheme)
                            ? AppColor.LightModeSecTextField
                            : AppColor.darkModeSeco),
                    child: Column(
                      children: [
                        /* Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "From Time",
                                  style: TextStyle(
                                      color: AppColor.kTextColor,
                                      fontFamily: "Subjective",
                                      fontSize: 12.sp),
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                SizedBox(
                                  child: build_Remainder(from_time, time_from),
                                  width: 0.40.sw,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "To Time",
                                  style: TextStyle(
                                      color: AppColor.kTextColor,
                                      fontFamily: "Subjective",
                                      fontSize: 12.sp),
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                SizedBox(
                                  child: build_Remainder(to_Time, tlme_to),
                                  width: 0.40.sw,
                                ),
                              ],
                            ),
                          ],
                        ),*/
                        SizedBox(
                          height: 10.h,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "Additional Notes Or Comments".tr(),
                              style: TextStyle(
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                  fontFamily: "Subjective",
                                  fontSize: 12.sp),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            SizedBox(
                              width: 0.9.sw,
                              child: build_comments_notes_Fild(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Insert_Button(),
                  SizedBox(
                    height: 20.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget build_Activite_Section(Map<int, SectionActivities> items, String name) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1),
      itemBuilder: (context, index) {
        //print(Categry_name);
        return build_Single_Activite(Single_Section_activite[Section_index].activities[index]);
      },
      itemCount: Single_Section_activite[Section_index].activities.length,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
    );
  }

  Widget build_comments_notes_Fild() {
    return TextField(
      textAlign: TextAlign.left,
      maxLines: 3,
      style: TextStyle(
          fontSize: 12.sp,
          fontFamily: "Subjective",
          color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
      showCursor: true,
      onChanged: (value) {
        notes = value;
      },
      cursorColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
      decoration: InputDecoration(
        errorText: _notes_validation ? "Place Add Notes".tr() : null,
        filled: true,
        fillColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
        contentPadding: EdgeInsets.only(left: 14.0.w, bottom: 8.0.h, top: 8.0.h),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(),
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
        ),
      ),
    );
  }

  Widget build_Grid_Cateogry() {
    return Container(
      padding: EdgeInsets.all(10),
      //width: 336.0,
      //height: 180.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco),

      child: Column(
        children: [
          Text(
            "Select Cateogry".tr(),
            style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontFamily: "Subjective",
                fontSize: 12.sp),
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Button_Category(
                  //TODO chang the image
                  "assets/images/social.png",
                  "Social".tr(),
                  AppColor.socialSection, () {
                FocusScope.of(context).unfocus();
                setState(() {
                  for (int index = 0; index < Categry.length; index++) {
                    if (index == 0) {
                      Categry[0] = true;
                    } else {
                      Categry[index] = false;
                    }
                  }
                  Categry_name = "Social";
                  Section_index = 1;
                  /*if(_Cateogry_validiate)
                                        _Cateogry_validiate=false;

                                      _Cateogry_validiate=true;*/
                });
              }, 0),
              SizedBox(
                width: 4.w,
              ),
              Button_Category(
                  //TODO chang the image
                  "assets/images/carrer.png",
                  "Carrer",
                  AppColor.careerSections, () {
                FocusScope.of(context).unfocus();
                setState(() {
                  for (int index = 0; index < Categry.length; index++) {
                    if (index == 1) {
                      Categry[1] = true;
                    } else {
                      Categry[index] = false;
                    }
                  }
                  Categry_name = "Career";
                  Section_index = 2;
                  /*if(_Cateogry_validiate)
                                        _Cateogry_validiate=false;

                                      _Cateogry_validiate=true;*/
                });
              }, 1),
              SizedBox(
                width: 4.w,
              ),
              Button_Category("assets/images/learn.png", "Learn".tr(), AppColor.learnSections, () {
                FocusScope.of(context).unfocus();
                setState(() {
                  for (int index = 0; index < Categry.length; index++) {
                    if (index == 2) {
                      Categry[2] = true;
                    } else {
                      Categry[index] = false;
                    }
                  }
                  Categry_name = "Learn";
                  Section_index = 3;
                  /*if(_Cateogry_validiate)
                                        _Cateogry_validiate=false;

                                      _Cateogry_validiate=true;*/
                });
              }, 2),
            ],
          ),
          SizedBox(
            height: 5.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Button_Category("assets/images/spirit.png", "Spirit".tr(), AppColor.spiritSections, () {
                FocusScope.of(context).unfocus();
                setState(() {
                  for (int index = 0; index < Categry.length; index++) {
                    if (index == 3) {
                      Categry[3] = true;
                    } else {
                      Categry[index] = false;
                    }
                  }
                  Categry_name = "Spirit".tr();
                  Section_index = 4;
                  /*if(_Cateogry_validiate)
                                        _Cateogry_validiate=false;

                                      _Cateogry_validiate=true;*/
                });
              }, 3),
              SizedBox(
                width: 4.h,
              ),
              Button_Category("assets/images/health.png", "Health".tr(), AppColor.healthSections, () {
                FocusScope.of(context).unfocus();
                setState(() {
                  for (int index = 0; index < Categry.length; index++) {
                    if (index == 4) {
                      Categry[4] = true;
                    } else {
                      Categry[index] = false;
                    }
                  }
                  Categry_name = "Health".tr();
                  Section_index = 5;
                  /*if(_Cateogry_validiate)
                                        _Cateogry_validiate=false;

                                      _Cateogry_validiate=true;*/
                });
              }, 4),
              SizedBox(width: 4.w),
              Button_Category("assets/images/emotion.png", "Emotions".tr(), AppColor.emotionsSections, () {
                FocusScope.of(context).unfocus();
                setState(() {
                  for (int index = 0; index < Categry.length; index++) {
                    if (index == 5) {
                      Categry[5] = true;
                    } else {
                      Categry[index] = false;
                    }
                  }
                  Categry_name = "Emotions".tr();
                  Section_index = 6;
                  /* if(_Cateogry_validiate)
                                        _Cateogry_validiate=false;

                                      _Cateogry_validiate=true;*/
                });
              }, 5),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    );
  }

  Widget build_Remainder(DateTime Date, TextEditingController timeinput) {
    return TextField(
      //scrollPadding: EdgeInsets.all(50),
      //textAlignVertical: TextAlignVertical.bottom,
      onTap: () async {
        DateTime pickedTime = await showDatePicker(
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: CashHelper.getData(key: ChangeTheme)
                      ? AppColor.LightModeSecTextField
                      : AppColor.darkModeSeco, // header background color
                  onPrimary:
                      CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor, // header text color
                  onSurface: CashHelper.getData(key: ChangeTheme)
                      ? AppColor.LightModeSecTextField
                      : AppColor.darkModeSeco, // body text color
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    primary: CashHelper.getData(key: ChangeTheme)
                        ? AppColor.LightModeSecTextField
                        : AppColor.darkModeSeco, // button text color
                  ),
                ),
              ),
              child: child,
            );
          },
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
          initialDate: DateTime.now(),
          context: context,
        );
        Date = pickedTime;
        if (pickedTime != null) {
          DateFormat formatter = DateFormat('yyyy-MM-dd');
          String formatted = formatter.format(pickedTime);
          setState(() {
            timeinput.text = formatted;
            Date = pickedTime;
            print(formatted);
          });
        }
      },

      controller: timeinput,
      readOnly: true,
      textAlign: TextAlign.left,
      //keyboardType: TextInputType.number,

      style: TextStyle(
          fontSize: 12.sp,
          fontFamily: "Subjective",
          color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
      showCursor: false,
      decoration: InputDecoration(
        filled: true,
        fillColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
        errorText: (_fromTime_validation || _toTimevalidation) ? "Place Add Time".tr() : null,
        /* errorText: textEditingController.text.isEmpty && error
            ? 'Value Can\'t Be Empty'
            : null,*/
        contentPadding: EdgeInsets.only(left: 14.0.w, bottom: 8.0.h, top: 8.0.h),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(),
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
        ),
      ),
    );
  }

  Widget build_Single_Emoje(Emoje emoje, VoidCallback function) {
    return Material(
      color: emoje.isClicked
          ? CashHelper.getData(key: ChangeTheme)
              ? AppColor.mainBtnLightMode
              : AppColor.mainBtn
          : Colors.transparent,
      borderRadius: BorderRadius.circular(5.r),
      child: InkWell(
        onTap: function,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: Colors.transparent,
              child: CachedNetworkImage(
                  imageUrl: emoje.emoje_path, errorWidget: (context, string, _) => Icon(Icons.error)),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              emoje.emoje_name,
              style: TextStyle(
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  fontFamily: "Subjective",
                  fontSize: 10.sp),
            )
          ],
        ),
      ),
    );
  }

  Widget build_Single_Activite(singleActivity item) {
    return ButtonTheme(
      child: GestureDetector(
        onTap: () {
          setState(() {
            //item.isClicked = !item.isClicked;

            for (int i = 0; i < Single_Section_activite[Section_index].activities.length; i++) {
              if (item == Single_Section_activite[Section_index].activities[i]) {
                item.isClicked = !item.isClicked;
                Activity_id = item.id;
                Activity_image = item.image;
              } else
                Single_Section_activite[Section_index].activities[i].isClicked = false;
            }
            activite = item;
          });
        },
        /*for (int i = 0; i < ActiviteList.Single_Section_activite.values.toList().length; i++) {

          });*/

        child: Container(
          padding: EdgeInsets.all(5.w),
          width: 138.r,
          height: 138.r,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: item.isClicked
                  ? CashHelper.getData(key: ChangeTheme)
                      ? AppColor.mainBtnLightMode
                      : AppColor.mainBtn
                  : CashHelper.getData(key: ChangeTheme)
                      ? AppColor.LightModeSecTextField
                      : AppColor.darkModeSeco),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /*GestureDetector(
                child: Padding(
                  padding: EdgeInsets.only(left: 90.r),
                  child: Container(
                      width: 30.h,
                      height: 30.h,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          color: AppColor.darkModePrim),
                      child: Icon(
                        Icons.favorite,
                        color: item.Fav ? AppColor.favActivity : Colors.white,
                        size: 25.r,
                      )),
                ),
                onTap: () {
                  setState(() {
                    item.Fav = !item.Fav;
                  });
                },
              ),*/
              CircleAvatar(
                radius: 40.r,
                backgroundColor: Colors.transparent,
                child: CachedNetworkImage(
                    imageUrl: item.image,
                    errorWidget: (context, string, _) => Icon(
                          Icons.error,
                          color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                        )),
              ),
              SizedBox(
                height: 5.h,
              ),
              Text(
                item.name,
                style: TextStyle(
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    fontFamily: "Subjective",
                    fontSize: 11.sp),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 5.h,
              ),
              Text(
                "+" + item.points.toString() + "pts".tr(),
                style: TextStyle(
                    color: item.isClicked
                        ? CashHelper.getData(key: ChangeTheme)
                            ? Colors.black
                            : AppColor.kTextColor
                        : CashHelper.getData(key: ChangeTheme)
                            ? AppColor.mainBtnLightMode
                            : AppColor.mainBtn,
                    fontFamily: "Subjective",
                    fontSize: 10.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // List<Widget> emoje_List = [];

  Widget Insert_Button() {
    return ButtonTheme(
      minWidth: 200.0,
      // height:MediaQuery.of(context).size.height/6.4,
      child: ElevatedButton(
        child: is_valid
            ? CircularProgressIndicator(
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim)
            : Text(
                'Insert Action'.tr(),
                style: TextStyle(
                    color: Colors.white, fontSize: 22.sp, fontFamily: "Subjective", fontWeight: FontWeight.bold),
              ),
        onPressed: () async {
          /* if (time_from.text == null ||
              time_from.text == "" ||
              time_from.text == " ") {
            print("from_time$from_time");
            setState(() {
              _fromTime_validation = true;
            });
          } else
            setState(() {
              _fromTime_validation = false;
            });
          if (tlme_to.text == null ||
              tlme_to.text == "" ||
              tlme_to.text == " ") {
            print("to_Time$to_Time");
            setState(() {
              _toTimevalidation = true;
            });
          } else
            setState(() {
              _toTimevalidation = false;
            });
          if (notes == null ||
              notes.compareTo("") == 0 ||
              notes.compareTo(" ") == 0) {
            print(" notes$notes");
            setState(() {
              _notes_validation = true;
            });
          } else
            setState(() {
              _notes_validation = false;
            });*/
          if (Section_index == 0 || Section_index == null) {
            Toast.show(
              'Place Select Category'.tr(),
              context,
              backgroundColor: Colors.red,
              gravity: Toast.BOTTOM,
              duration: Toast.LENGTH_LONG,
            );
            _button_validation = true;
          } else {
            setState(() {
              _button_validation = false;
            });
          }
          if (Activity_id == 0 || Activity_id == null) {
            for (int i = 0; i < Single_Section_activite[Section_index].activities.length; i++) {
              if (Single_Section_activite[Section_index].activities[i].isClicked == true) {
                print("innnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
                Activity_id = Single_Section_activite[Section_index].activities[i].id;
                activite = Single_Section_activite[Section_index].activities[i];
                _button_validation = false;
                break;
              }
            }
            if (Activity_id == 0 || Activity_id == null)
              Toast.show(
                'Place Select Activity'.tr(),
                context,
                backgroundColor: Colors.red,
                gravity: Toast.BOTTOM,
                duration: Toast.LENGTH_LONG,
              );
            _button_validation = true;
          } else {
            _button_validation = false;
          }
          /* if (Emoje_index == 0 || Emoje_index == null) {
            Toast.show(
              'Place Select Your Mood',
              context,
              backgroundColor: Colors.red,
              gravity: Toast.BOTTOM,
              duration: Toast.LENGTH_LONG,
            );
            _button_validation = true;
          } else {
            _button_validation = false;
          }*/
          if (/*!_toTimevalidation &&
              !_fromTime_validation &&*/
              !_button_validation /*&&
              !_notes_validation*/
              ) {
            setState(() {
              is_valid = true;
            });
            await Future.delayed(Duration(seconds: 2));
            setState(() {
              is_valid = false;
            });
            _Do_Activity();
          }
          // setState(() {
          ///post the activity to Api
          ///Create Object json and send
          // single_Activite = new singleActivity(
          //     activite.id,
          //     activite.Section_id,
          //     activite.name,
          //     activite.image,
          //     activite.points,
          //     activite.isClicked);

          /* activite,
                new Emoje(image_mood_path, image_mood_name, image_mood_Clicked),
                from_time,
                to_Time,
                notes*/ /*);*/
          // print(image_mood_path);
          // print(image_mood_path);
          // Navigator.of(context).push(MaterialPageRoute(
          //     builder: (_) => Resulte(
          //           Single_activite: single_Activite,
          //           Emoje_path: image_mood_path,
          //         )));
          /*HabitItem item=new HabitItem(image_Name, section_Title, time_Remaining, points, name_Habits, Reminder, starting_Day, time_of_The_Habits, perform_habits);
            //var res=JsonEncoder(item.toJson());
            print(item.toString());
            Habits.add_Habits(item);
            Navigator.of(context).pop();*/
          // });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.r),
              side: BorderSide(
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim),
            ),
          ),
          minimumSize: MaterialStateProperty.all<Size>(Size(276.w, 50.h)),
        ),
      ),
    );
  }

  Widget Button_Category(String imagepath, String title, Color anActiveColor, VoidCallback function, int index) {
    return GestureDetector(
      onTap: function,
      child: Container(
        //margin: EdgeInsets.all(value),
        width: 102.w,
        height: 43.h,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: (anActiveColor),
          border: Border.all(
              color: Categry[index]
                  ? CashHelper.getData(key: ChangeTheme)
                      ? AppColor.mainBtnLightMode
                      : AppColor.mainBtn
                  : anActiveColor,
              width: 3),
        ),
        //adding: EdgeInsets.all(5.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image(
              image: AssetImage(imagepath),
              width: 33.w,
              height: 33.w,
            ),
            Text(
              title,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: Categry[index]
                      ? CashHelper.getData(key: ChangeTheme)
                          ? Colors.black
                          : AppColor.kTextColor
                      : CashHelper.getData(key: ChangeTheme)
                          ? AppColor.kTextColor
                          : Colors.black,
                  fontFamily: "Subjective"),
            ),
          ],
        ),
      ),
    );
  }
}
