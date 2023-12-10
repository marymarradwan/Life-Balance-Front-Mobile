import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/model/activite_Item.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/view/login.dart';
import 'package:life_balancing/view/main_screen.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:toast/toast.dart';

import '../Util/ScreenHelper.dart';
import 'MoreActivite.dart';
import 'Premium.dart';

class CreateJournalPage extends StatefulWidget {
  @override
  _CreateJournalPage createState() => _CreateJournalPage();
}

class _CreateJournalPage extends State<CreateJournalPage> {
  //static List<SingleEvent> Event = [];

  TextEditingController dateinput = new TextEditingController();
  TextEditingController timeinput = new TextEditingController();
  DateTime JournalDate;

  //DateTime selectedDate = DateTime.now();
  TimeOfDay Reminder;
  List<bool> type_Selected = [true, false, false];

  String Categry_name;
  String Mood_Note;
  Map<int, List<singleActivity>> activite_Selected = {};
  List<singleActivity> Emotions = [];
  List<singleActivity> Social = [];
  List<singleActivity> Career = [];
  List<singleActivity> Learning = [];
  List<singleActivity> Spirit = [];
  List<singleActivity> Health = [];

  singleActivity single_Activite;
  String image_Name = "assets/images/temp@2x.png";
  String image_mood_path;
  String image_mood_name;
  bool image_mood_Clicked;

  singleActivity activite;
  Emoje mood;

  bool is_Clicked_Category = false;
  List<bool> Categry = [false, false, false, false, false, false];

  /*List<Emoje> mode_Active = List.generate(
      18,
      (index) =>
          new Emoje(index,"https://ai-gym.club/uploads/angel.gif", "Mood", false));*/
  String name;
  TextEditingController time_from = new TextEditingController();
  TextEditingController time_to = new TextEditingController();

  int Section_index;
  int Activity_id;
  int Emoje_index;
  DateTime from_time;
  DateTime to_Time;
  /* TimeOfDay FromDate;
  TimeOfDay TODate;*/
  String Single_Activity_Note;

  //String Notes_or_Comments;
  final List<bool> emoje_Clicked = [];
  bool init = true;
  int MoodId;
//change to true after connected to api
  bool _isLoading = false;
  bool _isLoadingSingleActivity = false;
  bool _isLoadingmultyActivity = true;
  bool _isLoadingMood = true, _isInit = false;
  List<Emoje> _emoje = [];
  Map<int, SectionActivities> Single_Section_activite = {};

  TextEditingController text = TextEditingController();

  //Date And Time Journal Validation
  bool _date_valid = false, _time_valid = false;

  //SingleActivity Validation
  bool _button_SingleActivity_validation = false,
      _fromTime_validation = false,
      _toTimevalidation = false,
      _notes_SingleActivity_validation = false;

  //Mood Validation
  bool _button_Mood_validation = false, _notes_Mood_validation = false;
  //QuickEntry Validation
  bool _Leangth_QuickEntry_valid = false;

  bool isValid = false;

  @override
  void initState() {
    if (!_isInit) {
      _fetchMood();
      _LoadSectionActivity();
    }
    _isInit = true;

    //print(" The State" + (_isLoading && _isLoadingMood).toString());
    super.initState();
  }

  Future _Do_Mood(int mode_id, String note) async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoading = true;
      });
      var res = await Do_mode("api/moods/do-mood", mode_id, note, dateinput.text, token);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 402) {
        setState(() {
          _isLoading = false;
        });
        print("in402");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Upgrade to Premium".tr(),
            style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
            ),
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
          backgroundColor: AppColor.emotionsSections,
        ));
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PremiumPage()));
        });
      } else if (res.statusCode == 200) {
        print("\ndone\n\n"); //print(res.body.toString());
        print(res.body.toString());
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => MainScreen(
                  TabId: 4,
                )));
      } else {
        setState(() {
          _isLoading = false;
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

  Future _Do_Multy_Activity(List<singleActivity> list, String date) async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoading = true;
      });
      var res = await createQuickEntryActivities("api/activities/do-quick-entry-activity", date, list, token);
      // print(json.decode(res.body)['data'][0]["id"]);
      print(res.statusCode);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 402) {
        setState(() {
          _isLoading = false;
        });
        print("in402");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Upgrade to Premium".tr(),
            style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
            ),
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
          backgroundColor: AppColor.emotionsSections,
        ));
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PremiumPage()));
        });
      } else if (res.statusCode == 200) {
        print("\ndone\n\n"); //print(res.body.toString());
        print(res.body.toString());
        if (mounted)
          setState(() {
            _isLoading = false;
          });
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => MainScreen(
                  TabId: 4,
                )));
      } else {
        setState(() {
          _isLoading = false;
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

  Future _Do_Activity() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoading = true;
      });
      var res = await createSingleActivite("api/activities/do-activity", Activity_id, Emoje_index, Single_Activity_Note,
          time_from.text, time_to.text, dateinput.text, token);
      // print(json.decode(res.body)['data'][0]["id"]);

      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 402) {
        setState(() {
          _isLoading = false;
        });
        print("in402");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Upgrade to Premium".tr(),
            style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
            ),
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
          backgroundColor: AppColor.emotionsSections,
        ));
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PremiumPage()));
        });
      } else if (res.statusCode == 200) {
        print("\ndone\n\n"); //print(res.body.toString());
        print(res.body.toString());
        single_Activite = new singleActivity(activite.id, activite.Section_id, activite.name, activite.image,
            activite.points, activite.isClicked, false);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => MainScreen(
                  TabId: 4,
                )));
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
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

  Future _LoadSectionActivity() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);

      var res = await getData("api/section", token);
      print("Section State QuickEntry" + res.statusCode.toString());
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        var Section = json.decode(res.body)['data'] as List<dynamic>;
        //print(Section.toString());
        // Map<int, Activite> _newactivities = {};
        Map<int, SectionActivities> _newactivities = {};

        Section.forEach((element) {
          var secondList = _emoje.map((item) => new Emoje.clone(item)).toList();
          // print(secondList.toString());
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
                              secondList,
                              null,
                              DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                              DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                              null,
                            ))
                        .toList(),
                  ));
        });
        setState(() {
          //  _habits = newHabits;
          Single_Section_activite = _newactivities;
          _isLoadingmultyActivity = false;
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
      print("mood State QuickEntry" + res.statusCode.toString());
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

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return Scaffold(
      //  backgroundColor: AppColor.darkModePrim,
      body: LoadingOverlay(
        isLoading: _isLoading,
        // additional parameters
        opacity: 0.5,
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
        progressIndicator: CircularProgressIndicator(
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                right: ScreenHelper.fromWidth(4.0),
                left: ScreenHelper.fromWidth(4.0),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10.0.h),
                    Text(
                      'New Journal Entry'.tr(),
                      style: TextStyle(
                        color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                        fontFamily: "Subjective",
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Container(
                      // height: 290,
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: CashHelper.getData(key: ChangeTheme)
                              ? AppColor.LightModeSecTextField
                              : AppColor.darkModeSeco),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                            "Select Date".tr(),
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: "Subjective",
                                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          build_date_Time(context),
                          SizedBox(
                            height: 10.h,
                          ),
                          /* Text(
                            "Select Time",
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: "Subjective",
                                color: AppColor.kTextColor),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),*/
                          //  Remainder(),
                          SizedBox(
                            height: 15.h,
                          ),
                          Text(
                            "Select Entry Type".tr(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: "Subjective",
                              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              build_Button_Entre_Type("Single Activity", Iconsax.document_text5, () {
                                setState(() {
                                  FocusScope.of(context).unfocus();
                                  type_Selected[0] = !type_Selected[0];
                                  type_Selected[1] = false;
                                  type_Selected[2] = false;
                                });
                              }, type_Selected[0]),
                              build_Button_Entre_Type("Mood", Iconsax.smileys5, () {
                                setState(() {
                                  FocusScope.of(context).unfocus();
                                  type_Selected[1] = !type_Selected[1];
                                  type_Selected[0] = false;
                                  type_Selected[2] = false;
                                });
                              }, type_Selected[1]),
                              build_Button_Entre_Type("Multiple Activities", Iconsax.document_copy5, () {
                                setState(() {
                                  FocusScope.of(context).unfocus();
                                  type_Selected[2] = !type_Selected[2];
                                  type_Selected[1] = false;
                                  type_Selected[0] = false;
                                });
                              }, type_Selected[2]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    type_Selected[0]
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color:
                                  CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                            ),
                            child: build_Single_Activity(context))
                        : const SizedBox(
                            height: 0.01,
                          ),
                    type_Selected[1]
                        ? Container(
                            // height: 475,
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: CashHelper.getData(key: ChangeTheme)
                                    ? AppColor.LightModeSecTextField
                                    : AppColor.darkModeSeco),
                            child: build_Mood(context))
                        : SizedBox(
                            height: 0.01,
                          ),
                    type_Selected[2]
                        ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: CashHelper.getData(key: ChangeTheme)
                                    ? AppColor.LightModeSecTextField
                                    : AppColor.darkModeSeco),
                            child: build_Multiple_Activity(context))
                        : const SizedBox(
                            height: 0.01,
                          ),
                    /*SizedBox(
                      height: 20.h,
                    ),*/
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget build_Multiple_Activity(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      //crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 10.h,
        ),
        build_Header_List(context, 6, "Emotions".tr()),
        build_List_Activites(6, Emotions),
        SizedBox(
          height: 20,
        ),
        build_Header_List(context, 2, "Career".tr()),
        build_List_Activites(2, Career),
        SizedBox(
          height: 20,
        ),
        build_Header_List(context, 1, "Social".tr()),
        build_List_Activites(1, Social),
        SizedBox(
          height: 20,
        ),
        build_Header_List(context, 4, "Spirit".tr()),
        build_List_Activites(4, Spirit),
        SizedBox(
          height: 20,
        ),
        build_Header_List(context, 3, "Learning".tr()),
        build_List_Activites(3, Learning),
        SizedBox(
          height: 20,
        ),
        build_Header_List(context, 5, "Health".tr()),
        build_List_Activites(5, Health),
        SizedBox(
          height: 10,
        ),
        Insert_Button("Insert Entry", () async {
          List<singleActivity> Activities = [];
          //int length_Activities=Social.length+Career.length+Learning.length+Spirit.length+Health.length+Emotions.length;
          activite_Selected.putIfAbsent(1, () => Social);
          activite_Selected.putIfAbsent(2, () => Career);
          activite_Selected.putIfAbsent(3, () => Learning);
          activite_Selected.putIfAbsent(4, () => Spirit);
          activite_Selected.putIfAbsent(5, () => Health);
          activite_Selected.putIfAbsent(6, () => Emotions);
          activite_Selected.forEach((key, value) {
            value.forEach((element) {
              Activities.add(element);
            });
          });
          //  print(Activities.toString());
          if (Activities.length > 0) {
            setState(() {
              _Leangth_QuickEntry_valid = false;
            });
          } else {
            Toast.show(
              'Place Select At Least One Activity'.tr(),
              context,
              backgroundColor: Colors.red,
              gravity: Toast.BOTTOM,
              duration: Toast.LENGTH_LONG,
            );
            _Leangth_QuickEntry_valid = true;
          }
          if (JournalDate == null || JournalDate == 0) {
            print(JournalDate);
            setState(() {
              _date_valid = true;
            });
          } else
            setState(() {
              _date_valid = false;
            });
          /*if (Reminder == null || Reminder == 0) {
            setState(() {
              _time_valid = true;
            });
          } else
            setState(() {
              _time_valid = false;
            });*/
          if (!_Leangth_QuickEntry_valid && !_date_valid /*&& !_time_valid*/) {
            print("done");
            setState(() {
              isValid = true;
            });
            await Future.delayed(Duration(seconds: 2));
            setState(() {
              isValid = false;
            });
            _Do_Multy_Activity(Activities, dateinput.text);
          }
        }, 256),
        SizedBox(
          height: 10.h,
        ),
      ],
    );
  }

  Widget build_Mood(BuildContext context) {
    return Column(
      children: [
        Text(
          "How This Activity Make You Fell? ".tr(),
          style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontFamily: "Subjective",
              fontSize: 18.sp),
        ),
        SizedBox(
          height: 5.h,
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
                  highlightColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                  direction: SkeletonDirection.ltr,
                  childAspectRatio: 0.5,
                  baseColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                )),
              )
            : Container(
                width: 1.sw,
                height: 275.h,
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
                      MoodId = _emoje[index].id;
                      print(Emoje_index);
                    });
                  },
                ),
              ),
        SizedBox(
          height: 15.h,
        ),
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
        TextField(
          style: TextStyle(
              fontSize: 12.sp,
              fontFamily: "Subjective",
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
          showCursor: true,
          controller: text,
          onChanged: (value) {
            Mood_Note = value;
            //text.text = value;
          },
          cursorColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
          decoration: InputDecoration(
            errorText: _notes_Mood_validation ? "Place Enter Notes" : null,
            filled: true,
            fillColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
            contentPadding: EdgeInsets.only(left: 14.0.w, bottom: 8.0.h, top: 8.0.h),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
              borderRadius: BorderRadius.all(Radius.circular(15.r)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco),
              borderRadius: BorderRadius.all(Radius.circular(15.r)),
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        Insert_Button("Insert Mood", () async {
          if (JournalDate == null || JournalDate == 0) {
            print(JournalDate);
            setState(() {
              _date_valid = true;
            });
          } else
            setState(() {
              _date_valid = false;
            });
          /* if (Reminder == null || Reminder == 0) {
            setState(() {
              _time_valid = true;
            });
          } else
            setState(() {
              _time_valid = false;
            });*/
          if (MoodId == null) {
            Toast.show(
              'Place Add Your Mood'.tr(),
              context,
              backgroundColor: Colors.red,
              gravity: Toast.BOTTOM,
              duration: Toast.LENGTH_LONG,
            );
            setState(() {
              _button_Mood_validation = true;
            });
          } else {
            setState(() {
              _button_Mood_validation = false;
            });
          }
          /*if (Mood_Note == null || Mood_Note == "" || Mood_Note == " ") {
            setState(() {
              _notes_Mood_validation = true;
            });
          } else
            setState(() {
              _notes_Mood_validation = false;
            });*/
          if (!_button_Mood_validation &&
              // !_notes_Mood_validation &&
              !_date_valid /* !_time_valid*/) {
            setState(() {
              isValid = true;
            });
            await Future.delayed(Duration(seconds: 2));
            setState(() {
              isValid = false;
            });
            _Do_Mood(MoodId, Mood_Note);
          }
        }, 222),
        SizedBox(
          height: 10.h,
        ),
      ],
    );
  }

  Widget build_Single_Activity(BuildContext context) {
    return Column(
      children: [
        // SizedBox(height: 10.0.h),
        Text(
          'New Action'.tr(),
          style: TextStyle(
            color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
            fontFamily: "Subjective",
            fontSize: 16.sp,
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
                            color:
                                CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                            border: Border.all(color: Colors.black)),
                      ),
                      items: 1,
                      period: Duration(seconds: 1),
                      highlightColor:
                          CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                      direction: SkeletonDirection.ltr,
                      baseColor:
                          CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
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
                            color:
                                CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                            border:
                                Border.all(color: CashHelper.getData(key: ChangeTheme) ? Colors.white : Colors.black)),
                      ),
                      items: 1,
                      period: Duration(seconds: 1),
                      highlightColor:
                          CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                      direction: SkeletonDirection.ltr,
                      baseColor:
                          CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
                    ),
                  )
                : ButtonTheme(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(CashHelper.getData(key: ChangeTheme)
                            ? AppColor.LightModeSecTextField
                            : AppColor.darkModeSeco),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0.r),
                            side: BorderSide(
                              color:
                                  CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                            ),
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
                                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                fontFamily: "Subjective",
                                fontSize: 16.sp),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Container(
                            child: Icon(
                              Icons.arrow_forward,
                              color:
                                  CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                              size: 16.r,
                            ),
                            decoration: BoxDecoration(
                                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            scrollDirection: Axis.horizontal,
            child: Categry_name != null
                ? build_Activite_Section(Single_Section_activite)
                : _isLoading
                    ? LimitedBox(
                        maxHeight: 400.w,
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
                          highlightColor:
                              CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
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
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
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
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco),
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
                          height: 1.sh / 8,
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
                        highlightColor:
                            CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                        direction: SkeletonDirection.ltr,
                        childAspectRatio: 0.5,
                        baseColor:
                            CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                      )),
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
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco),
          child: Column(
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
        ),
        SizedBox(
          height: 20.h,
        ),

        Insert_Button('Insert Entry'.tr(), () async {
          if (Section_index == 0 || Section_index == null) {
            setState(() {
              Toast.show(
                'Place Select Category'.tr(),
                context,
                backgroundColor: Colors.red,
                gravity: Toast.BOTTOM,
                duration: Toast.LENGTH_LONG,
              );
              _button_SingleActivity_validation = true;
            });
          } else
            setState(() {
              _button_SingleActivity_validation = false;
            });
          if (Activity_id == null) {
            for (int i = 0; i < Single_Section_activite[Section_index].activities.length; i++) {
              if (Single_Section_activite[Section_index].activities[i].isClicked == true) {
                print("innnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
                Activity_id = Single_Section_activite[Section_index].activities[i].id;
                activite = Single_Section_activite[Section_index].activities[i];
                _button_SingleActivity_validation = false;
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
            _button_SingleActivity_validation = true;
          } else
            setState(() {
              _button_SingleActivity_validation = false;
            });
          /*if (Emoje_index == null) {
            setState(() {
              Toast.show(
                'Place Add Your Mood',
                context,
                backgroundColor: Colors.red,
                gravity: Toast.BOTTOM,
                duration: Toast.LENGTH_LONG,
              );
              _button_SingleActivity_validation = true;
            });
          } else
            setState(() {
              _button_SingleActivity_validation = false;
            });*/
          /* if (time_from.text == null ||
              time_from.text == "" ||
              time_from.text == " ") {
            setState(() {
              _fromTime_validation = true;
            });
          } else {
            setState(() {
              _fromTime_validation = false;
            });
          }
          if (time_to.text == null ||
              time_to.text == "" ||
              time_to.text == " ") {
            setState(() {
              _toTimevalidation = true;
            });
          } else {
            setState(() {
              _toTimevalidation = false;
            });
          }*/
          /* if (Single_Activity_Note == null ||
              Single_Activity_Note == "" ||
              Single_Activity_Note == " ") {
            setState(() {
              _notes_SingleActivity_validation = true;
            });
          } else
            setState(() {
              _notes_SingleActivity_validation = false;
            });*/
          if (JournalDate == null || JournalDate == 0) {
            print(JournalDate);
            setState(() {
              _date_valid = true;
            });
          } else
            setState(() {
              _date_valid = false;
            });
          /*if (Reminder == null || Reminder == 0) {
            setState(() {
              _time_valid = true;
            });
          } else
            setState(() {
              _time_valid = false;
            });*/
          if (!_date_valid &&
                  //  !_time_valid &&
                  !_button_SingleActivity_validation
              //!_fromTime_validation &&
              //!_toTimevalidation &&
              /* !_notes_SingleActivity_validation*/) {
            print("done");
            setState(() {
              isValid = true;
            });
            await Future.delayed(Duration(seconds: 2));
            setState(() {
              isValid = false;
            });
            _Do_Activity();
          }
        }, 276),
        SizedBox(
          height: 20.h,
        ),
      ],
    );
  }

  Widget build_Button_Entre_Type(String name, IconData icon, VoidCallback function, bool select) {
    return Container(
      width: 95.w,
      height: 55.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        color: select
            ? CashHelper.getData(key: ChangeTheme)
                ? AppColor.mainBtnLightMode
                : AppColor.mainBtn
            : CashHelper.getData(key: ChangeTheme)
                ? AppColor.lightModePrim
                : AppColor.darkModePrim,
      ),
      child: InkWell(
        onTap: function,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 27.r,
            ),
            Text(
              name,
              style: TextStyle(
                  fontSize: 10.sp,
                  fontFamily: "Subjective",
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

/*
  Widget Remainder() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: TextField(
        //scrollPadding: EdgeInsets.all(50),
        //textAlignVertical: TextAlignVertical.bottom,
        onTap: () async {
          TimeOfDay pickedTime = await showTimePicker(
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppColor.darkModeSeco, // header background color
                    onPrimary: AppColor.kTextColor, // header text color
                    onSurface: AppColor.darkModeSeco, // body text color
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      primary: AppColor.darkModeSeco, // button text color
                    ),
                  ),
                  //canvasColor: Color(0xFF00A7A3),
                  //highlightColor: Color(0xFF00A7A3),
                ),
                child: child,
              );
            },
            initialTime: TimeOfDay.now(),
            context: context,
          );
          Reminder = pickedTime;
          //print(Reminder);
          if (pickedTime != null) {
            DateTime parsedTime =
                DateFormat.jm().parse(pickedTime.format(context).toString());
            //converting to DateTime so that we can further format on different pattern.
            String formattedTime = DateFormat('HH:mm a').format(parsedTime);
            //DateFormat() is from intl package, you can format the time on any pattern you need.

            setState(() {
              timeinput.text = formattedTime;
              //Reminder=DateTime.parse(formattedString)formattedTime;//set the value of text field.
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
            color: AppColor.kTextColor),
        showCursor: false,
        decoration: InputDecoration(
          errorText: _time_valid ? "place Enter Time" : null,
          filled: true,
          fillColor: AppColor.darkModePrim,
          contentPadding:
              EdgeInsets.only(left: 14.0.w, bottom: 8.0.h, top: 8.0.h),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.mainBtn),
            borderRadius: BorderRadius.all(Radius.circular(10.r)),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColor.darkModePrim),
            borderRadius: BorderRadius.all(Radius.circular(10.r)),
          ),
        ),
      ),
    );
  }
*/

  Widget build_date_Time(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: TextField(
        //scrollPadding: EdgeInsets.all(50),
        //textAlignVertical: TextAlignVertical.bottom,
        textAlign: TextAlign.left,
        style: TextStyle(
            fontSize: 12.sp,
            fontFamily: "Subjective",
            color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
        //showCursor: true,
        //controller: text,

        onTap: () async {
          DateTime pickedTime = await showDatePicker(
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: CashHelper.getData(key: ChangeTheme)
                          ? AppColor.LightModeSecTextField
                          : AppColor.darkModeSeco, // header background color
                      onPrimary: CashHelper.getData(key: ChangeTheme)
                          ? Colors.black
                          : AppColor.kTextColor, // header text color
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
                    //canvasColor: AppColor.mainBtn,
                    //highlightColor: AppColor.mainBtn,
                  ),
                  child: child,
                );
              },
              initialDate: DateTime.now(),
              context: context,
              firstDate: DateTime.utc(2000, 1, 1),
              lastDate: DateTime(2300, 12, 30));
          //Reminder=pickedTime;
          //print(Reminder);
          if (pickedTime != null) {
            DateFormat formatter = DateFormat('yyyy-MM-dd');
            String formatted = formatter.format(pickedTime);

            setState(() {
              dateinput.text = formatted;
              JournalDate = pickedTime;
              print(dateinput.text);
              //Reminder=DateTime.parse(formattedString)formattedTime;//set the value of text field.
            });
          }
        },
        controller: dateinput,
        readOnly: true,
        //textAlign: TextAlign.center,

        cursorColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
        decoration: InputDecoration(
          errorText: _date_valid ? "Place Enter Date".tr() : null,
          filled: true,
          fillColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
          contentPadding: EdgeInsets.only(left: 14.0.w, bottom: 8.0.h, top: 8.0.h),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
            borderRadius: BorderRadius.all(Radius.circular(10.r)),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim),
            borderRadius: BorderRadius.all(Radius.circular(10.r)),
          ),
        ),
      ),
    );
  }

  GridView build_Activite_Section(Map<int, SectionActivities> items) {
    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15),
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
      textAlign: TextAlign.center,
      maxLines: 3,
      style: TextStyle(
          fontSize: 12.sp,
          fontFamily: "Subjective",
          color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
      showCursor: true,
      onChanged: (value) {
        Single_Activity_Note = value;
      },
      cursorColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
      decoration: InputDecoration(
        errorText: _notes_SingleActivity_validation ? "Place Enter Notes".tr() : null,
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
                  "Social",
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
                  Categry_name = "Social".tr();
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
              Button_Category("assets/images/learn.png", "Learn", AppColor.learnSections, () {
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
                  Categry_name = "Spirit";
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
                  Categry_name = "Emotions";
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

  Widget build_Remainder(DateTime Date, TextEditingController timeinput, bool validation_Timer) {
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
          });
        }
      },

      controller: timeinput,
      readOnly: true,
      textAlign: TextAlign.center,
      //keyboardType: TextInputType.number,

      style: TextStyle(
        fontSize: 12.sp,
        fontFamily: "Subjective",
        color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
      ),
      showCursor: false,
      decoration: InputDecoration(
        errorText: validation_Timer ? "Place Enter Time".tr() : null,
        filled: true,
        fillColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
        /*errorText: textEditingController.text.isEmpty && error
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

  Widget build_Single_Activite_Quick_Entry(
      singleActivity item, int SectionIndex, List<singleActivity> activite_list, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          //item.isClicked = !item.isClicked;
          for (int i = 0; i < Single_Section_activite[SectionIndex].activities.length; i++) {
            if (item == Single_Section_activite[SectionIndex].activities[i]) {
              item.isClicked = !item.isClicked;
              if (item.isClicked) {
                //item.Emoji=mode_Active;

                activite_list.add(item);
              } else {
                //item.Emoji.remove(item.Emoji);
                activite_list.remove(item);
              }
            }
          }
          // item.Emoje_id = 2;
          // item.notes = "test";
        });
      },
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
                    ? AppColor.lightModePrim
                    : AppColor.darkModePrim),
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
              textAlign: TextAlign.center,
              maxLines: 2,
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
    );
  }

  Widget build_Single_Activite(singleActivity item) {
    return ButtonTheme(
      child: GestureDetector(
        onTap: () {
          setState(() {
            FocusScope.of(context).unfocus();
            //item.isClicked = !item.isClicked;

            for (int i = 0; i < Single_Section_activite[Section_index].activities.length; i++) {
              if (item == Single_Section_activite[Section_index].activities[i]) {
                Activity_id = item.id;
                item.isClicked = !item.isClicked;
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
          width: 138.w,
          height: 138.w,
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
              /* GestureDetector(
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

  Widget Insert_Button(String name, VoidCallback function, double width) {
    return ButtonTheme(
      //minWidth: MediaQuery.of(context).size.width/2,
      //height: 100.0,
      child: ElevatedButton(
        child: isValid
            ? CircularProgressIndicator(
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
              )
            : Text(
                name,
                style: TextStyle(
                    color: Colors.white, fontSize: 20.sp, fontFamily: "Subjective", fontWeight: FontWeight.bold),
              ),
        onPressed: function,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0.r),
              side: BorderSide(
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim),
            ),
          ),
          minimumSize: MaterialStateProperty.all<Size>(Size(width.w, 50.h)),
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
                      : Colors.black,
                  fontFamily: "Subjective"),
            ),
          ],
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

  Widget build_List_Activites(int SectionIndex, List<singleActivity> activite_List) {
    return Container(
      height: 200.h,
      padding: EdgeInsets.all(10.w),
      child: _isLoadingmultyActivity
          ? LimitedBox(
              maxHeight: 400.h,
              maxWidth: 1.sw,
              child: (SkeletonGridLoader(
                builder: Container(
                  height: 138.w,
                  width: 138.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                      border: Border.all(color: Colors.black)),
                ),
                items: 3,
                itemsPerRow: 3,
                period: Duration(seconds: 1),
                highlightColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                direction: SkeletonDirection.ltr,
                childAspectRatio: 1,
                baseColor:
                    CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
              )),
            )
          : ListView.separated(
              /*gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),*/

              itemBuilder: (context, index) {
                return build_Single_Activite_Quick_Entry(
                    Single_Section_activite[SectionIndex].activities[index], SectionIndex, activite_List, index);
              },
              separatorBuilder: (context, index) {
                return SizedBox(width: 10.w);
              },
              /*itemExtent: 150,*/

              itemCount: Single_Section_activite[SectionIndex].activities.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
            ),
    );
  }

  Widget build_Header_List(BuildContext context, int Section_id, String Categry_name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                        border: Border.all(color: Colors.black)),
                  ),
                  items: 1,
                  period: Duration(seconds: 1),
                  highlightColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                  direction: SkeletonDirection.ltr,
                  baseColor:
                      CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
                ),
              )
            : Text(
                Categry_name,
                style: TextStyle(
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    fontSize: 18.sp,
                    fontFamily: "Subjective",
                    fontWeight: FontWeight.bold),
              ),
        SizedBox(
          width: 70.w,
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
                        color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                        border: Border.all(color: Colors.black)),
                  ),
                  items: 1,
                  period: Duration(seconds: 1),
                  highlightColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                  direction: SkeletonDirection.ltr,
                  baseColor:
                      CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
                ),
              )
            : ButtonTheme(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.r),
                        //side: BorderSide(color: AppColor.darkModePrim),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(Size(111.w, 32.h)),
                  ),
                  onPressed: () async {
                    var val = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MoreActivite(
                                  name_Activite: Categry_name,
                                  activite: Single_Section_activite[Section_id].activities,
                                  Section_id: Single_Section_activite[Section_id].id,
                                  Section_image: "assets/images/temp@2x.png",
                                  type: 2,
                                ))).then((value) {
                      setState(() {
                        for (int i = 1; i < Single_Section_activite.length + 1; i++) {
                          switch (i) {
                            case 1:
                              {
                                Single_Section_activite[1].activities.forEach((element) {
                                  if (element.isClicked == true) {
                                    if (!Social.contains(element)) {
                                      Social.add(element);
                                    }
                                  }
                                });
                                break;
                              }
                            case 2:
                              {
                                Single_Section_activite[2].activities.forEach((element) {
                                  if (element.isClicked == true) {
                                    if (!Career.contains(element)) {
                                      Career.add(element);
                                    }
                                  }
                                });
                                break;
                              }
                            case 3:
                              {
                                Single_Section_activite[3].activities.forEach((element) {
                                  if (element.isClicked == true) {
                                    if (!Learning.contains(element)) {
                                      Learning.add(element);
                                    }
                                  }
                                });
                                break;
                              }
                            case 4:
                              {
                                Single_Section_activite[4].activities.forEach((element) {
                                  if (element.isClicked == true) {
                                    if (!Spirit.contains(element)) {
                                      Spirit.add(element);
                                    }
                                  }
                                });
                                break;
                              }
                            case 5:
                              {
                                Single_Section_activite[5].activities.forEach((element) {
                                  if (element.isClicked == true) {
                                    if (!Health.contains(element)) {
                                      Health.add(element);
                                    }
                                  }
                                });
                                break;
                              }
                            case 6:
                              {
                                Single_Section_activite[6].activities.forEach((element) {
                                  if (element.isClicked == true) {
                                    if (!Emotions.contains(element)) {
                                      Emotions.add(element);
                                    }
                                  }
                                });
                                break;
                              }
                          }
                        }
                      });
                    });
                    //add then and add to lists
                    //   setState(() {});
                  },
                  child: Row(
                    children: [
                      Text(
                        "More Activites".tr(),
                        style: TextStyle(
                            color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                            fontFamily: "Subjective",
                            fontSize: 16.sp),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Container(
                        child: Icon(
                          Icons.arrow_forward,
                          color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                          size: 16.r,
                        ),
                        decoration: BoxDecoration(
                            color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                            borderRadius: BorderRadius.circular(17.r)),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
    ;
  }
}
