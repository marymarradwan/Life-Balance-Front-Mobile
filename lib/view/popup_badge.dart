import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/appqoutes.dart';
import 'package:life_balancing/model/activite_Item.dart';
import 'package:life_balancing/model/entity_mood.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/view/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PopUpBadge extends StatefulWidget {
  final int badgeId;
  final List<Emoje> emoje;
  final int entity_id;
  final int entity_type;

  const PopUpBadge(
    BuildContext context, {
    Key key,
    this.badgeId,
    this.emoje,
    this.entity_id,
    this.entity_type,
  }) : super(key: key);

  @override
  _PopUpBadgeState createState() => _PopUpBadgeState();
}

class _PopUpBadgeState extends State<PopUpBadge> {
  bool isInit = true;
  bool loading = true;
  String badge_name;
  String badge_Url;
  String description_badge;
  int points;
  String Section_name;

  @override
  void initState() {
    if (isInit) {
      _simulatedLoad();
    }
    isInit = false;
    super.initState();
  }

  Future _simulatedLoad() async {
    qouts = AppQoutes.qoutesList[AppQoutes.random.nextInt(204)];
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      /*   setState(() {
        loading = true;
      });*/
      try {
        var res = await getBadgeInfo("api/badge", widget.badgeId, token);
        if (res.statusCode == 200) {
          setState(() {
            loading = false;
          });
          print("done");
          badge_name = json.decode(res.body)["data"]["name"];
          badge_Url = json.decode(res.body)["data"]["image"];
          points = json.decode(res.body)["data"]["points"];
          Section_name = json.decode(res.body)["data"]["section_name"];
        } else if (res.statusCode == 401) {
          setState(() {
            loading = false;
          });
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
        } else
          setState(() {
            loading = false;
          });
      } on SocketException catch (_) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  final String advice = "The great things always happen outside of your comfort zone";
  bool press_X = true;
  int mood_Id;
  bool _isLoadingImages = false;
  bool isAddMood = false;
  bool isAddMoodError = false;
  String qouts;

  Future _updategoal(EntityMood item) async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingImages = true;
      });
      print(item);
      var res = await addEntityMood("api/moods/entity-mood", item, token);
      // print(json.decode(res.body)['data']);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        dynamic data = json.decode(res.body)['data'];
        print(data);
        print("done of endpoint");
        if (mounted)
          setState(() {
            _isLoadingImages = false;
          });
      } else {
        // Toast.show(
        //   'Network Error',
        //   context,
        //   backgroundColor: Colors.red,
        //   gravity: Toast.BOTTOM,
        //   duration: Toast.LENGTH_LONG,
        // );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 10,
      insetPadding: EdgeInsets.all(20.w),
      actionsAlignment: MainAxisAlignment.center,
      contentPadding: EdgeInsets.all(5.w),
      content: Container(
        padding: EdgeInsets.all(10.w),
        //width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r), color: AppColor.darkModePrim),
        height: 0.74.sh,
        child: Stack(children: [
          Image(
            image: AssetImage("assets/images/Popupimage.png"),
            width: 307.w,
            height: 260.h,
          ),
          loading
              ? CircularProgressIndicator(
                  color: AppColor.mainBtn,
                  strokeWidth: 2,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /* Icon(
                Iconsax.tick_circle,
                size: 64.r,
                color: AppColor.mainBtn,
              ),*/
                    /* SizedBox(
              height: 10.h,
            ),*/

                    Text(
                      "Congratulations!!!".tr(),
                      style: TextStyle(
                          fontSize: 27.sp,
                          fontFamily: "Subjective",
                          fontWeight: FontWeight.bold,
                          color: AppColor.kTextColor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      "You Earned a New Badge".tr(),
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: "Subjective",
                          fontWeight: FontWeight.w800,
                          color: AppColor.kTextColor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    /*  SizedBox(
              height: 10.h,
            ),*/
                    SizedBox(
                        height: 133.h,
                        width: 133.w,
                        child: Image(
                          image: NetworkImage(badge_Url),
                          fit: BoxFit.contain,
                        )),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      badge_name,
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: "Subjective",
                          fontWeight: FontWeight.w500,
                          color: AppColor.mainBtn),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      "Get".tr() +
                          "$points" +
                          " points in the".tr() +
                          " $Section_name" +
                          " Section to \nearn the".tr() +
                          " $badge_name" +
                          " Badge".tr(),
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: "Subjective",
                          fontWeight: FontWeight.w500,
                          color: AppColor.kTextColor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    press_X
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0.r),
                              color: AppColor.darkModeSeco,
                            ),
                            padding: EdgeInsets.all(10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Iconsax.quote_down5,
                                  color: AppColor.kTextColor,
                                  size: 30.r,
                                ),
                                SizedBox(
                                  width: 230.0,
                                  child: DefaultTextStyle(
                                    style: TextStyle(
                                        color: AppColor.kTextColor,
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
                                GestureDetector(
                                  child: Icon(
                                    Icons.highlight_off,
                                    color: AppColor.kTextColor,
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
                        : const SizedBox(height: 0.01),
                    SizedBox(
                      height: 10.h,
                    ),
                    /* SizedBox(
              height: 10.h,
            ),*/
                    Text(
                      "What is your feelings about this Badge".tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                          fontFamily: "Subjective",
                          color: AppColor.kTextColor),
                    ),
                    /* SizedBox(
              height: 10,
            ),*/
                    SizedBox(
                      height: 10.h,
                    ),
                    /*Text(
                      isAddMoodError ? "Please Selected Mood" : "",
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 11.sp,
                          fontFamily: "Subjective",
                          color: Colors.red),
                    ),*/
                    Container(
                      width: 1.sw,
                      height: 100.h,
                      child: GridView.builder(
                        //  physics:  NeverScrollableScrollPhysics(),
                        itemCount: widget.emoje.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.5,
                        ),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return build_Single_Emoje(widget.emoje[index], () {
                            setState(() {
                              widget.emoje.forEach((element) {
                                element.isClicked = false;
                              });
                              widget.emoje[index].isClicked = true;
                            });
                            /* image_mood_path = _emoje[index].emoje_path;
                                        image_mood_name = _emoje[index].emoje_name;
                                        image_mood_Clicked =
                                            _emoje[index].isClicked;*/
                            mood_Id = widget.emoje[index].id;
                            isAddMood = true;
                            //Mood Id
                            print(mood_Id);
                          });
                        },
                      ),
                    ),
                    // SizedBox(height: 10.h,),
                    ButtonTheme(
                      minWidth: 200.0,
                      //      height: 100.0,
                      child: ElevatedButton(
                        child: Text(
                          "done".tr(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.sp,
                              fontFamily: "Subjective",
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          _updategoal(new EntityMood(mood_Id, widget.entity_id, widget.entity_type));
                          Navigator.of(context).pop();
                          /* if (isAddMood) {

                            Navigator.of(context).pop();
                          } else {
                            setState(() {
                              isAddMood = false;
                              isAddMoodError = true;
                            });*/
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainBtn),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0.r),
                              side: BorderSide(color: AppColor.darkModePrim),
                            ),
                          ),
                          minimumSize: MaterialStateProperty.all<Size>(Size(150.w, 50.h)),
                        ),
                      ),
                    ),
                  ],
                ),
        ]),
      ),
    );
  }

  Widget build_Single_Emoje(Emoje emoje, VoidCallback function) {
    return Material(
      color: emoje.isClicked ? AppColor.mainBtn : Colors.transparent,
      borderRadius: BorderRadius.circular(5.r),
      child: InkWell(
        onTap: function,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 25.r,
              backgroundColor: Colors.transparent,
              child: CachedNetworkImage(
                  imageUrl: emoje.emoje_path, errorWidget: (context, string, _) => Icon(Icons.error)),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              emoje.emoje_name,
              style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 10.sp),
            )
          ],
        ),
      ),
    );
  }
}
