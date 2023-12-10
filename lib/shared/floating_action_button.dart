import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:iconsax/iconsax.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/model/activite_Item.dart';
import 'package:life_balancing/model/goal_item.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/view/CreateGoal.dart';
import 'package:life_balancing/view/CreateHabits.dart';
import 'package:life_balancing/view/CreateJournal.dart';
import 'package:life_balancing/view/Premium.dart';
import 'package:life_balancing/view/login.dart';
import 'package:life_balancing/view/popup_badge.dart';
import 'package:life_balancing/view/qr_code_page.dart';
import 'package:life_balancing/view/quick-entry.dart';
import 'package:life_balancing/view/single-activity.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class FloatingActionButtons extends StatefulWidget {
  const FloatingActionButtons({Key key}) : super(key: key);

  @override
  _FloatingActionButtonsState createState() => _FloatingActionButtonsState();
}

class _FloatingActionButtonsState extends State<FloatingActionButtons> {
  var _isLoadingMood = false;
  List<Emoje> _emoje = [];
  bool is_Win_Badge = false;
  bool is_Win_Reward = false;
  bool _isInit = false;
  bool isValid = false;
  bool _button_validation = false, _notes_validation = false;
  TextEditingController text = new TextEditingController();
  String Note;
  int mood_Id;
  int badge_id;

  @override
  void initState() {
    if (!_isInit) {
      //_simulateLoad();
      _fetchMood();
    }
    _isInit = true;
    super.initState();
  }

  Future _fetchMood() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingMood = true;
      });
      var res = await getData("api/mood", token);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
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
        setState(() {
          _isLoadingMood = false;
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

  Future _Do_Mood(int mode_id, String note) async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingMood = true;
      });
      var res = await Do_mode("api/moods/do-mood", mode_id, note, "", token);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 402) {
        setState(() {
          _isLoadingMood = false;
        });
        print("in402");
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text(
        //     "Upgrade to Premium",
        //     style: TextStyle(
        //       color: AppColor.kTextColor,
        //       fontFamily: "Subjective",
        //     ),
        //     textAlign: TextAlign.center,
        //   ),
        //   duration: Duration(seconds: 2),
        //   backgroundColor: AppColor.emotionsSections,
        // ));
        // Timer(Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PremiumPage()));
        // });
      } else if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Mood Inserted".tr(),
            style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
            ),
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 1),
          backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
        ));
        print("\ndone\n\n"); //print(res.body.toString());
        print(res.body.toString());
        is_Win_Badge = json.decode(res.body)["badge"]["isOpenNewBadge"];
        is_Win_Reward = json.decode(res.body)["reword"]["isOpenNewReword"];
        setState(() {
          _isLoadingMood = false;
        });
        if (is_Win_Badge) {
          badge_id = json.decode(res.body)["badge"]["badgeId"];
          showDialog(
              useSafeArea: true,
              context: context,
              builder: (BuildContext context) => PopUpBadge(
                    context,
                    badgeId: badge_id,
                    emoje: _emoje.map((item) => new Emoje.clone(item)).toList(),
                    entity_id: mode_id,
                    entity_type: 3,
                  )).then((_) => Navigator.of(context).pop());
        } else {
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _isLoadingMood = false;
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

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add_outlined,
      buttonSize: 60,
      //  spacing: 5,
      // spaceBetweenChildren: 12,
      backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
      elevation: 0,
      //animationSpeed: 300,
      //  elevation: 3,
      //activeBackgroundColor: AppColor.loginColor,
      activeIcon: Icons.close,
      foregroundColor: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
      //childrenButtonSize: const Size(60, 60),
      //gradientBoxShape: BoxShape.circle,
      // gradient: const LinearGradient(
      //     begin: Alignment.centerLeft,
      //     end: Alignment.topRight,
      //     colors: [
      //       AppColor.pinkColor,
      //       Colors.orange,
      //     ]),
      children: [
        SpeedDialChild(
            label: "Insert Multiple Activities".tr(),
            backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
            labelBackgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
            labelStyle: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontFamily: "Subjective",
                fontSize: 14),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
              child: Icon(
                Iconsax.document_copy5,
                size: 24.r,
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => QuickEntryPage()));
            },
            labelWidget: Container(
              padding: EdgeInsets.all(15),
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
              child: Center(
                child: Text(
                  "Insert Multiple Activities".tr(),
                  style: TextStyle(
                      color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                      fontFamily: "Subjective",
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
        SpeedDialChild(
          label: "Insert Single Activity".tr(),
          backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
          labelBackgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
          labelStyle: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
              fontSize: 14),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
            child: Icon(
              Iconsax.document_text5,
              size: 24.r,
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
            ),
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SingleActivityPage()));
          },
          labelWidget: Container(
            padding: EdgeInsets.all(15),
            height: 50,
            width: 250,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
            child: Center(
              child: Text(
                "Insert Single Activity".tr(),
                style: TextStyle(
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    fontFamily: "Subjective",
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SpeedDialChild(
          label: "New Habit".tr(),
          backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
          labelBackgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
          labelStyle: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
              fontSize: 14),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
            child: Icon(
              Iconsax.clipboard_text5,
              size: 24.r,
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateHabitsPage(
                          HeaderName: "New Habit".tr(),
                          ButtonNamr: " Create Habit".tr(),
                        )));
          },
          labelWidget: Container(
            padding: EdgeInsets.all(15),
            height: 50,
            width: 250,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
            child: Center(
              child: Text(
                "New Habit".tr(),
                style: TextStyle(
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    fontFamily: "Subjective",
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SpeedDialChild(
          label: "New Mood".tr(),
          backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
          labelBackgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
          labelStyle: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
              fontSize: 14),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
            child: Icon(
              Iconsax.smileys5,
              size: 24.r,
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
            ),
          ),
          onTap: () {
            showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) {
                  return LoadingOverlay(
                    isLoading: _isLoadingMood,
                    opacity: 0.5,
                    color:
                        CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
                    progressIndicator: CircularProgressIndicator(
                      color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                    ),
                    child: StatefulBuilder(
                      builder: (BuildContext context, setState) => SafeArea(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Container(
                            //height: 500.0,
                            decoration: new BoxDecoration(
                                color: CashHelper.getData(key: ChangeTheme)
                                    ? AppColor.lightModePrim
                                    : AppColor.darkModePrim,
                                borderRadius: new BorderRadius.only(
                                    topLeft: Radius.circular(10.0.r), topRight: Radius.circular(10.0.r))),
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.top),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Tell Us About Your Mood ?".tr(),
                                    style: TextStyle(
                                        color:
                                            CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                        fontFamily: "Subjective",
                                        fontSize: 18.sp),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  Container(
                                    width: 1.sw,
                                    height: 300.h,
                                    child: GridView.builder(
                                      //  physics:  NeverScrollableScrollPhysics(),
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
                                          /* image_mood_path = _emoje[index].emoje_path;
                                        image_mood_name = _emoje[index].emoje_name;
                                        image_mood_Clicked =
                                            _emoje[index].isClicked;*/
                                          mood_Id = _emoje[index].id;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  Text(
                                    "Additional Notes Or Comments".tr(),
                                    style: TextStyle(
                                        color:
                                            CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                        fontFamily: "Subjective",
                                        fontSize: 14.sp),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  TextField(
                                    // autofocus: true,

                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: "Subjective",
                                        color:
                                            CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
                                    showCursor: true,
                                    controller: text,
                                    onChanged: (value) {
                                      // text.text = value;
                                      Note = value;
                                    },
                                    cursorColor: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.mainBtnLightMode
                                        : AppColor.mainBtn,
                                    decoration: InputDecoration(
                                      errorText: _notes_validation ? "Plase Enter Notes".tr() : null,
                                      filled: true,
                                      fillColor: CashHelper.getData(key: ChangeTheme)
                                          ? AppColor.LightModeSecTextField
                                          : AppColor.darkModeSeco,
                                      contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? AppColor.LightModeSecTextField
                                                : AppColor.darkModeSeco),
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? AppColor.LightModeSecTextField
                                                : AppColor.darkModeSeco),
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  ButtonTheme(
                                    minWidth: 200.0,
                                    // height: MediaQuery.of(context).size.width/3.7,
                                    child: ElevatedButton(
                                      child: isValid
                                          ? CircularProgressIndicator(
                                              color: CashHelper.getData(key: ChangeTheme)
                                                  ? AppColor.lightModePrim
                                                  : AppColor.darkModePrim,
                                            )
                                          : Text(
                                              'Insert Mood'.tr(),
                                              style: TextStyle(
                                                  color: CashHelper.getData(key: ChangeTheme)
                                                      ? Colors.black
                                                      : AppColor.kTextColor,
                                                  fontSize: 22.sp,
                                                  fontFamily: "Subjective",
                                                  fontWeight: FontWeight.bold),
                                            ),
                                      onPressed: () {
                                        setState(() async {
                                          if (mood_Id == null) {
                                            Toast.show(
                                              'Place Select Your Mood'.tr(),
                                              context,
                                              backgroundColor: Colors.red,
                                              gravity: Toast.BOTTOM,
                                              duration: Toast.LENGTH_LONG,
                                            );
                                            _button_validation = true;
                                          } else
                                            setState(() {
                                              _button_validation = false;
                                            });
                                          /*if (Note == null ||
                                              Note.compareTo("") == 0 ||
                                              Note.compareTo(" ") == 0) {
                                            print(" Note$Note");
                                            setState(() {
                                              _notes_validation = true;
                                            });
                                          } else
                                            setState(() {
                                              _notes_validation = false;
                                            });*/
                                          if ( //!_notes_validation &&
                                              !_button_validation) {
                                            setState(() {
                                              isValid = true;
                                            });
                                            await Future.delayed(Duration(seconds: 2));
                                            setState(() {
                                              isValid = false;
                                            });
                                            _Do_Mood(mood_Id, Note);
                                          }
                                        });
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(
                                            CashHelper.getData(key: ChangeTheme)
                                                ? AppColor.mainBtnLightMode
                                                : AppColor.mainBtn),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100.0.r),
                                            side: BorderSide(
                                                color: CashHelper.getData(key: ChangeTheme)
                                                    ? AppColor.lightModePrim
                                                    : AppColor.darkModePrim),
                                          ),
                                        ),
                                        minimumSize: MaterialStateProperty.all<Size>(Size(222.w, 50.h)),
                                      ),
                                    ),
                                  ),
                                  /*SizedBox(
                                  height: 10,
                                ),*/
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                });
          },
          labelWidget: Container(
            padding: EdgeInsets.all(15),
            height: 50,
            width: 250,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
            child: Center(
              child: Text(
                "New Mood".tr(),
                style: TextStyle(
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    fontFamily: "Subjective",
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SpeedDialChild(
            label: "New Journal Entry".tr(),
            backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
            labelBackgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
            labelStyle: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontFamily: "Subjective",
                fontSize: 14),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
              child: Image(
                image: AssetImage("assets/images/journal.png"),
                width: 24.w,
                height: 24.w,
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fit: BoxFit.contain,
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateJournalPage()));
            },
            labelWidget: Container(
              padding: EdgeInsets.all(15),
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
              child: Center(
                child: Text(
                  "New Journal Entry".tr(),
                  style: TextStyle(
                      color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                      fontFamily: "Subjective",
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
        SpeedDialChild(
          label: "New Goal".tr(),
          backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
          labelBackgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
          labelStyle: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
              fontSize: 14),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
            child: Icon(
              Iconsax.clipboard_tick5,
              size: 24.r,
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateGoalPage(
                          HeaderName: "New Goal".tr(),
                          ButtonName: "Create Goal".tr(),
                          item: new GoalItem(null, null, '', '', null, null, null, null, null, ''),
                        )));
          },
          labelWidget: Container(
            padding: EdgeInsets.all(15),
            height: 50,
            width: 250,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
            child: Center(
              child: Text(
                "New Goal".tr(),
                style: TextStyle(
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    fontFamily: "Subjective",
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        SpeedDialChild(
          label: "Qr Code".tr(),
          backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
          labelBackgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
          labelStyle: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 14),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
            child: Icon(
              Iconsax.code,
              size: 24.r,
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
            ),
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => QrCodeScreen()));
          },
          labelWidget: Container(
            padding: EdgeInsets.all(15),
            height: 50,
            width: 250,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
            child: Center(
              child: Text(
                "Qr Code".tr(),
                style: TextStyle(
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    fontFamily: "Subjective",
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ), //todo
      ],
    );
  }
}
