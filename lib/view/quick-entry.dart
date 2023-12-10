import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/model/activite_Item.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/view/review_quick_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:toast/toast.dart';

import '../Util/ScreenHelper.dart';
import 'MoreActivite.dart';
import 'login.dart';

class QuickEntryPage extends StatefulWidget {
  @override
  _QuickEntryPage createState() => _QuickEntryPage();
}

class _QuickEntryPage extends State<QuickEntryPage> {
  //String Categry_name;
  Map<int, List<singleActivity>> activite_Selected = {};
  List<singleActivity> Emotions = [];
  List<singleActivity> Social = [];
  List<singleActivity> Career = [];
  List<singleActivity> Learning = [];
  List<singleActivity> Spirit = [];
  List<singleActivity> Health = [];
  //int length_Activities;

  List<Emoje> _emoje = [];
  Map<int, SectionActivities> Single_Section_activite = {};
  bool _isLoading = true, _isLoadingMood = true;
  bool _isInit = false;
  bool is_valid = false;

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

  Future _fetchMood() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingMood = true;
      });
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
          'Network Error',
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

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return Scaffold(
      backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              right: ScreenHelper.fromWidth(4.0),
              left: ScreenHelper.fromWidth(4.0),
            ),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10.0.h),
                Center(
                  child: Text(
                    'Tell Us About Your Day '.tr(),
                    style: TextStyle(
                      color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                      fontFamily: "Subjective",
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                Insert_Button(),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget Insert_Button() {
    int length_Activities =
        Social.length + Career.length + Learning.length + Spirit.length + Health.length + Emotions.length;
    return ButtonTheme(
      minWidth: 200.0,
      //height: 100.0,
      child: ElevatedButton(
        child: is_valid
            ? CircularProgressIndicator(
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
              )
            : Text(
                'Continue'.tr(),
                style: TextStyle(
                    color: Colors.white, fontSize: 23.sp, fontFamily: "Subjective", fontWeight: FontWeight.bold),
              ),
        onPressed: length_Activities > 0
            ? () async {
                activite_Selected.putIfAbsent(1, () => Social);
                activite_Selected.putIfAbsent(2, () => Career);
                activite_Selected.putIfAbsent(3, () => Learning);
                activite_Selected.putIfAbsent(4, () => Spirit);
                activite_Selected.putIfAbsent(5, () => Health);
                activite_Selected.putIfAbsent(6, () => Emotions);
                setState(() {
                  is_valid = true;
                });
                await Future.delayed(Duration(seconds: 2));
                setState(() {
                  is_valid = false;
                });
                setState(() {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Review(
                            list: activite_Selected,
                          )));
                });
              }
            : () {
                setState(() {
                  Toast.show(
                    'Place Select At Least One Activity'.tr(),
                    context,
                    backgroundColor: Colors.red,
                    gravity: Toast.BOTTOM,
                    duration: Toast.LENGTH_LONG,
                  );
                });
              },
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
          minimumSize: MaterialStateProperty.all<Size>(Size(308.0.w, 50.0.h)),
        ),
      ),
    );
  }

  Widget build_List_Activites(int Section_id, List<singleActivity> activite_List) {
    return Container(
      height: 200.h,
      padding: EdgeInsets.all(10.w),
      child: _isLoading
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
                return build_Single_Activite(Single_Section_activite[Section_id].activities[index], activite_List);
              },
              separatorBuilder: (context, index) {
                return SizedBox(width: 10.w);
              },
              /*itemExtent: 150,*/

              itemCount: Single_Section_activite[Section_id].activities.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
            ),
    );
  }

  Widget build_Single_Activite(singleActivity item, List<singleActivity> activite_list) {
    return ButtonTheme(
      child: GestureDetector(
        onTap: () {
          setState(() {
            item.isClicked = !item.isClicked;
            if (item.isClicked) {
              //item.Emoji=mode_Active;
              activite_list.add(item);
            } else {
              //item.Emoji.remove(item.Emoji);
              activite_list.remove(item);
            }
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
                      ? AppColor.LightModeSecTextField
                      : AppColor.darkModeSeco),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /*  GestureDetector(
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
                    color: CashHelper.getData(key: ChangeTheme)
                        ? CashHelper.getData(key: ChangeTheme)
                            ? AppColor.kTextColor
                            : Colors.black
                        : CashHelper.getData(key: ChangeTheme)
                            ? Colors.black
                            : AppColor.kTextColor,
                    fontFamily: "Subjective",
                    fontSize: 11.sp),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 5.r,
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
                        CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0.r),
                        side: BorderSide(
                            color:
                                CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim),
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
                    //setState(() {});
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
                          color: AppColor.darkModePrim,
                          size: 16.r,
                        ),
                        decoration: BoxDecoration(
                            color: CashHelper.getData(key: ChangeTheme)
                                ? CashHelper.getData(key: ChangeTheme)
                                    ? AppColor.kTextColor
                                    : Colors.black
                                : CashHelper.getData(key: ChangeTheme)
                                    ? Colors.black
                                    : AppColor.kTextColor,
                            borderRadius: BorderRadius.circular(17.r)),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}
