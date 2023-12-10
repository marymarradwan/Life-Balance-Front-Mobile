import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/ScreenHelper.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/view/popup_badge.dart';
import 'package:life_balancing/view/result_Quick_Entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../model/activite_Item.dart';
import 'Premium.dart';
import 'login.dart';

class Review extends StatefulWidget {
  final Map<int, List<singleActivity>> list;

  const Review({Key key, this.list}) : super(key: key);

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  //List<String> Mood_Image=List.generate(widget.list., (index) => null);
  //List<TextEditingController> text ;
  bool enable = true;
  int Index = 0;
  String s = "";

  List<singleActivity> Activities = [];

  /*List<Emoje>  mode_Active = List.generate(
      12,
          (index) => new Emoje(
          "https://ai-gym.club/uploads/angel.gif",
          "Mood",
          false));*/
  bool expanded = false;
  var counter = 0;
  bool _isLoading = false;

  //validation
  bool is_valid = false;
  List<bool> _button_valid;
  List<bool> _notes_valid;
  int length = 0;

  bool is_Win_Badge = false;
  bool is_Win_Reward = false;
  int badge_id;
  List<Emoje> _emoje = [];
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
  void initState() {
    widget.list.forEach((key, value) {
      value.forEach((element) {
        length++;
      });
    });
    _notes_valid = List.filled(length, false);
    _button_valid = List.filled(length, false);
    //_button_valid=new List(widget.list.values.length);
    //print(_button_valid.length);
    _fetchMood();
    super.initState();
  }

  Future _Do_Activity(List<singleActivity> list) async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoading = true;
      });
      var res = await createQuickEntryActivities("api/activities/do-quick-entry-activity", "", list, token);
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
              color: AppColor.kTextColor,
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
        is_Win_Badge = json.decode(res.body)["badge"]["isOpenNewBadge"];
        is_Win_Reward = json.decode(res.body)["reword"]["isOpenNewReword"];
        if (is_Win_Badge) {
          badge_id = json.decode(res.body)["badge"]["badgeId"];
        }
        if (mounted)
          setState(() {
            _isLoading = false;
          });
        if (is_Win_Badge) {
          showDialog(
              useSafeArea: true,
              context: context,
              builder: (BuildContext context) => PopUpBadge(
                    context,
                    badgeId: badge_id,
                    emoje: _emoje.map((item) => new Emoje.clone(item)).toList(),
                    entity_id: null,
                    entity_type: 3,
                  )).then(
              (_) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ResultQuickEntry())));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ResultQuickEntry()));
        }
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
    return Scaffold(
      //  backgroundColor: AppColor.darkModePrim,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              right: ScreenHelper.fromWidth(4.0),
              left: ScreenHelper.fromWidth(4.0),
            ),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    "Review And Add More Info".tr(),
                    style: TextStyle(color: AppColor.mainBtn, fontFamily: "Subjective", fontSize: 18.sp),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  build_Category_List("Emotions".tr(), 6),
                  SizedBox(
                    height: 10.h,
                  ),
                  build_Category_List("Career".tr(), 2),
                  SizedBox(
                    height: 10.h,
                  ),
                  build_Category_List("Social".tr(), 1),
                  SizedBox(
                    height: 10.h,
                  ),
                  build_Category_List("Spirit".tr(), 4),
                  SizedBox(
                    height: 10.h,
                  ),
                  build_Category_List("Learning".tr(), 3),
                  SizedBox(
                    height: 10,
                  ),
                  build_Category_List("Health".tr(), 5),
                  SizedBox(
                    height: 10.h,
                  ),
                  widget.list.length > 0
                      ? Insert_Button("Continue".tr(), () async {
                          Activities.clear();
                          widget.list.forEach((key, value) {
                            value.forEach((element) {
                              Activities.add(element);
                            });
                          });
                          //_button_valid=new List(Activities.length);
                          // print(_button_valid.length);
                          //_notes_valid=new List(Activities.length);
                          //test it
                          /*for (int i = 0; i < Activities.length; i++) {
                            if (Activities[i].trailing_path == null ||
                                Activities[i].trailing_path == '' ||
                                Activities[i].trailing_path == " ") {
                              setState(() {
                                Toast.show(
                                  'Place Select Mood For All Activity',
                                  context,
                                  backgroundColor: Colors.red,
                                  gravity: Toast.BOTTOM,
                                  duration: Toast.LENGTH_LONG,
                                );
                                _button_valid[i] = true;
                              });
                            } else
                              setState(() {
                                _button_valid[i] = false;
                              });
                            if (Activities[i].notes == null ||
                                Activities[i].notes == "" ||
                                Activities[i].notes == " ") {
                              print("Notes $i" + Activities[i].notes);
                              setState(() {
                                _notes_valid[i] = true;
                              });
                            } else
                              setState(() {
                                _notes_valid[i] = false;
                              });
                          }
                          _button_valid.forEach((element) {
                            if (element == true) {
                              is_valid = false;
                              print("4545454");
                            } else
                              is_valid = true;
                          });
                          _notes_valid.forEach((element) {
                            if (element == true) {
                              is_valid = false;
                              //print("4545454");
                            } else
                              is_valid = true;
                          });
                         */
                          _Do_Activity(Activities);

                          // print(Activities.toString());
                          setState(() {
                            is_valid = true;
                          });
                          await Future.delayed(Duration(seconds: 2));
                          setState(() {
                            is_valid = false;
                          });
                        }, 308)
                      : Container(
                          child: Text("No Thing To Found".tr()),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget build_Category_List(String name_Category, int Section_id) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.list[Section_id].length > 0
            ? Text(
                name_Category,
                style: TextStyle(
                  color: AppColor.kTextColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Subjective",
                  fontSize: 18.sp,
                ),
              )
            : Container(),
        widget.list[Section_id].length > 0
            ? SizedBox(
                height: 10.h,
              )
            : Container(),
        widget.list[Section_id].length > 0
            ? ListView.separated(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 10.h,
                  );
                },
                itemCount: widget.list[Section_id].length,
                itemBuilder: (context, index) {
                  //String image_path = "";
                  // print(widget.list[name_Category].length.toString());
                  return build_Expansion_Item_List(widget.list[Section_id], index, new TextEditingController());
                },
              )
            : Container(),
      ],
    );
  }

  Widget build_Expansion_Item_List(List<singleActivity> item, int index, TextEditingController text) {
    String path = "";
    return Container(
      // padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: AppColor.darkModeSeco,
        /*boxShadow: [
          BoxShadow(
            color: AppColor.darkModeSeco.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 2,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],*/
      ),
      child: ExpansionTile(
        /*initiallyExpanded: item[index].expanded,
        onExpansionChanged: (value){
   item[index].expanded=value;
   print(value);
        },*/
        leading: CircleAvatar(
          radius: 30.r,
          child: Image(
            image: NetworkImage(item[index].image),
          ),
        ),
        title: Text(
          item[index].name,
          style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 18.sp),
        ),
        subtitle: Text("+" + item[index].points.toString() + "pts",
            style: TextStyle(color: AppColor.mainBtn, fontFamily: "Subjective", fontSize: 16.sp)),
        trailing: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.r), color: AppColor.darkModePrim),
          child: item[index].trailing_path != null
              ? Image(
                  image: NetworkImage(item[index].trailing_path),
                  height: 30.w,
                  width: 30.w,
                )
              : null,
          /*child: ,*/
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Column(
              children: [
                Text(
                  "How This Activity Make You Fell? ".tr(),
                  style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 13.sp),
                ),
                SizedBox(
                  height: 5.h,
                ),
                build_grid_Emoji(item[index]),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  "Additional Notes Or Comments".tr(),
                  style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 13.sp),
                ),
                SizedBox(
                  height: 5.h,
                ),
                TextField(
                  style: TextStyle(fontSize: 15.sp, fontFamily: "Subjective", color: AppColor.kTextColor),
                  showCursor: true,
                  controller: text,
                  onChanged: (value) {
                    //text.text = value;
                    item[index].notes = value;
                  },
                  cursorColor: AppColor.mainBtn,
                  decoration: InputDecoration(
                    errorText: _notes_valid[index] ? "Place Enter Notes".tr() : null,
                    filled: true,
                    fillColor: AppColor.darkModePrim,
                    contentPadding: EdgeInsets.only(left: 14.0.w, bottom: 8.0.h, top: 8.0.w),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.mainBtn),
                      borderRadius: BorderRadius.all(Radius.circular(30.r)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColor.darkModeSeco),
                      borderRadius: BorderRadius.all(Radius.circular(30.r)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                /* Insert_Button("Save", () {
                   setState(() {
                     item[index].expanded=false;
                   });
                 }, 100),*/
              ],
            ),
          ),
        ],
        iconColor: AppColor.darkModeSeco,
      ),
    );
  }

  Widget build_grid_Emoji(singleActivity item) {
    return Container(
      //width: MediaQuery.of(context).size.width,
      width: 1.sw,
      height: 150.h,
      child: Padding(
        padding: EdgeInsets.all(2.0.w),
        child: GridView.builder(
          //physics:  NeverScrollableScrollPhysics(),
          //itemCount: 12,
          physics: BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            childAspectRatio: 0.5,
          ),
          scrollDirection: Axis.vertical,
          itemCount: item.Emoji.length,
          itemBuilder: (context, index) {
            //print(item.activite_name);
            return build_Single_Emoje(item, index);
          },
        ),
      ),
    );
  }

  Widget Insert_Button(String name, VoidCallback function, double width) {
    return ButtonTheme(
      minWidth: 200.0,
      // height: 100.0,
      child: ElevatedButton(
        child: is_valid
            ? CircularProgressIndicator(
                color: AppColor.darkModePrim,
              )
            : Text(
                name,
                style: TextStyle(
                    color: Colors.white, fontSize: 23.sp, fontFamily: "Subjective", fontWeight: FontWeight.bold),
              ),
        onPressed: function,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainBtn),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0.r),
              side: BorderSide(color: AppColor.darkModePrim),
            ),
          ),
          minimumSize: MaterialStateProperty.all<Size>(Size(width.w, 50.0.h)),
        ),
      ),
    );
  }

  Widget build_Single_Emoje(singleActivity item, int index) {
    return GestureDetector(
        onTap: () {
          setState(() {
            item.Emoji.forEach((element) {
              element.isClicked = false;
              item.trailing_path = " ";
            });
            item.Emoji[index].isClicked = !item.Emoji[index].isClicked;
            item.trailing_path = item.Emoji[index].emoje_path;
            item.Emoje_id = item.Emoji[index].id;
          });
        },
        child: Material(
          color: item.Emoji[index].isClicked ? AppColor.mainBtn : Colors.transparent,
          borderRadius: BorderRadius.circular(5.r),
          child: InkWell(
            // onTap: function,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Colors.transparent,
                  child: CachedNetworkImage(
                      imageUrl: item.Emoji[index].emoje_path, errorWidget: (context, string, _) => Icon(Icons.error)),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  item.Emoji[index].emoje_name,
                  style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 10.sp),
                )
              ],
            ),
          ),
        ));
  }
}
