import 'dart:async';
import 'dart:convert';
//import 'dart:ffi';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/ScreenHelper.dart';
import 'package:life_balancing/model/activite_Item.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/view/main_screen.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'PopUpInfo.dart';
import 'Premium.dart';
import 'login.dart';

class InsertCustomActivity extends StatefulWidget {
  final int Section_id;
  final String Section_name;
  final IconData Section_image;
  //final List<Emoje> emoje;

  const InsertCustomActivity({Key key, this.Section_id, this.Section_name, this.Section_image /*,this.emoje*/})
      : super(key: key);

  @override
  _InsertCustomActivityState createState() => _InsertCustomActivityState();
}

class _InsertCustomActivityState extends State<InsertCustomActivity> {
  String name_Activity, Icon_name;
  int points;
  List<bool> isSelected_reward = [false, false, false, false];
  String imageSelected;
  bool isInit = false;
  List<String> results = [];
  List<bool> select = [];
  String image;
  Map<int, String> _Images = {};
  bool _isLoadingImages = true;
  int Emoje_index;
  Color color_Section;

// validation
  bool _name_validation = false, _icon_name_validation = false, _emoje_validation = false;

  List<Emoje> _emoje = [
    new Emoje(null, "assets/images/Injured.gif", "Not Very Important", false),
    new Emoje(null, "assets/images/Smirking.gif", "Neutral", false),
    new Emoje(null, "assets/images/Sad.gif", "Important", false),
    new Emoje(null, "assets/images/Sweet.gif", "Extreamly Important", false),
  ];

  int getPoints(int Emoje_index) {
    int points = 0;
    if (Emoje_index == 0)
      points = 25;
    else if (Emoje_index == 1)
      points = 50;
    else if (Emoje_index == 2)
      points = 75;
    else if (Emoje_index == 3) points = 100;

    return points;
  }

  Future _simulateLoadImage() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);

      var res = await getData("api/images", token);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        List<dynamic> images = json.decode(res.body)['data'];
        Map<int, String> newImages = {};
        for (var i = 0; i < images.length; i++) {
          newImages.putIfAbsent(images[i]['id'], () => images[i]['image']);
          select.add(false);
        }
        setState(() {
          _Images = newImages;
          results = _Images.values.toList();
          _isLoadingImages = false;
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
    if (!isInit) {
      _simulateLoadImage();
    }
    isInit = true;
    switch (widget.Section_id) {
      case 1:
        {
          color_Section = AppColor.socialSection;
          break;
        }
      case 2:
        {
          color_Section = AppColor.careerSections;
          break;
        }

      case 3:
        {
          color_Section = AppColor.learnSections;
          break;
        }
      case 4:
        {
          color_Section = AppColor.spiritSections;
          break;
        }
      case 5:
        {
          color_Section = AppColor.healthSections;
          break;
        }
      case 6:
        {
          color_Section = AppColor.emotionsSections;
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return Scaffold(
      // backgroundColor: AppColor.darkModePrim,
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: _isLoadingImages,
          // additional parameters
          opacity: 0.5,
          color: AppColor.darkModeSeco,
          progressIndicator: CircularProgressIndicator(
            color: AppColor.mainBtn,
          ),
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.only(
                  right: ScreenHelper.fromWidth(4.0),
                  left: ScreenHelper.fromWidth(4.0),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      "New Custom Activity".tr(),
                      style: TextStyle(
                          color: AppColor.mainBtn,
                          fontSize: 18.sp,
                          fontFamily: "Subjective",
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Container(
                      padding: EdgeInsets.all(10.0.w),
                      //height: 260,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppColor.darkModeSeco),
                      child: Column(
                        children: [
                          Text(
                            "Activity Category".tr(),
                            style: TextStyle(
                              color: AppColor.kTextColor,
                              fontSize: 12.sp,
                              fontFamily: "Subjective",
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                            width: 294.w,
                            height: 62.h,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: color_Section),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 40.w),
                                  child: Row(
                                    children: [
                                      widget.Section_id == 2 || widget.Section_id == 3
                                          ? SizedBox(
                                              width: 30.w,
                                            )
                                          : Container(),
                                      Icon(
                                        widget.Section_image,
                                        size: 65.r,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  widget.Section_name,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 21.sp,
                                      fontFamily: "Subjective",
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "Activity Name".tr(),
                            style: TextStyle(
                              color: AppColor.kTextColor,
                              fontSize: 12.sp,
                              fontFamily: "Subjective",
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          TextField(
                            //scrollPadding: EdgeInsets.all(50),
                            //textAlignVertical: TextAlignVertical.bottom,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.sp, fontFamily: "Subjective", color: AppColor.kTextColor),
                            showCursor: true,
                            //controller: text,

                            onChanged: (value) {
                              name_Activity = value;
                            },
                            /*onEditingComplete: (){
                                  setState(() {
                                    name_Habits = text.text;
                                  });
                                },*/

                            cursorColor: AppColor.mainBtn,
                            decoration: InputDecoration(
                              errorText: _name_validation ? "Place Enter Name".tr() : null,
                              filled: true,
                              fillColor: AppColor.darkModePrim,
                              contentPadding: EdgeInsets.only(left: 14.0.w, bottom: 8.0.h, top: 8.0.h),
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
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "Activity Icon".tr(),
                            style: TextStyle(
                              color: AppColor.kTextColor,
                              fontSize: 12.sp,
                              fontFamily: "Subjective",
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          TextField(
                            //scrollPadding: EdgeInsets.all(50),
                            //textAlignVertical: TextAlignVertical.bottom,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.sp, fontFamily: "Subjective", color: AppColor.kTextColor),
                            //showCursor: true,
                            //controller: text,
                            showCursor: false,

                            onTap: () {
                              setState(() {
                                showDialog(context: context, builder: (BuildContext context) => buildImageDialog());
                              });
                            },
                            /*onEditingComplete: (){
                                  setState(() {
                                    name_Habits = text.text;
                                  });
                                },*/

                            //cursorColor: AppColor.mainBtn,
                            decoration: InputDecoration(
                              hintText: image != null ? image : "Choose Icon".tr(),
                              filled: true,
                              errorText: _icon_name_validation ? "Place Select Image".tr() : null,
                              hintStyle:
                                  TextStyle(fontSize: 12.sp, fontFamily: "Subjective", color: AppColor.kTextColor),
                              fillColor: AppColor.darkModePrim,
                              contentPadding: EdgeInsets.only(left: 14.0.w, bottom: 8.0.h, top: 8.0.h),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColor.mainBtn),
                                borderRadius: BorderRadius.all(Radius.circular(10.r)),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColor.darkModePrim),
                                borderRadius: BorderRadius.all(Radius.circular(10.r)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Container(
                      padding: EdgeInsets.all(10.w),
                      //height: 260,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppColor.darkModeSeco),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10.h,
                          ),

                          Text(
                            "How Important This Activity To You !".tr(),
                            style: TextStyle(
                              color: AppColor.kTextColor,
                              fontSize: 12.sp,
                              fontFamily: "Subjective",
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          //SizedBox(height: 90,),
                          Container(
                            height: 90.h,
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                return build_Single_Emoje(_emoje[index], () {
                                  setState(() {
                                    _emoje.forEach((element) {
                                      element.isClicked = false;
                                    });
                                    _emoje[index].isClicked = true;
                                  });
                                  //image_mood_path = _emoje[index].emoje_path;
                                  //image_mood_name = _emoje[index].emoje_name;
                                  //image_mood_Clicked = _emoje[index].isClicked;
                                  Emoje_index = index;
                                  //print(Emoje_index);
                                });
                              },
                              itemCount: 4,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              separatorBuilder: (BuildContext context, int index) {
                                return SizedBox(
                                  width: 12.w,
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 0.20.sw),
                                child: Text(
                                  "This Activity Will Award You !".tr(),
                                  style: TextStyle(
                                    color: AppColor.kTextColor,
                                    fontSize: 12.sp,
                                    fontFamily: "Subjective",
                                  ),
                                ),
                              ),
                              PopUpInfo(
                                message:
                                    "Points are awarded based on how important this activity to you, Be honest :)".tr(),
                                child: Material(
                                  color: Colors.transparent,
                                  //borderRadius: BorderRadius.circular(25.0),
                                  child: InkWell(
                                    child: Icon(
                                      Icons.info_outline,
                                      color: AppColor.kTextColor,
                                      size: 21.r,
                                    ),
                                    /*  onTap: () {
                                      */ /* showDialog(
                                          useSafeArea: true,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              PopUpInfo(
                                                InfoText:
                                                    "Points are awarded based on how important this activity to you, Be honest :)",
                                              ));*/ /*
                                    },*/
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          build_Points_Buttons(),
                          SizedBox(
                            height: 10.h,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Insert_Button("Continue", () {
                      if (name_Activity == null || name_Activity == "" || name_Activity == " ") {
                        setState(() {
                          _name_validation = true;
                        });
                      } else {
                        setState(() {
                          _name_validation = false;
                        });
                      }
                      if (image == null) {
                        setState(() {
                          _icon_name_validation = true;
                        });
                      } else {
                        setState(() {
                          _icon_name_validation = false;
                        });
                      }
                      if (Emoje_index == null) {
                        setState(() {
                          Toast.show(
                            'Place Select Your Mood'.tr(),
                            context,
                            backgroundColor: Colors.red,
                            gravity: Toast.BOTTOM,
                            duration: Toast.LENGTH_LONG,
                          );
                          _emoje_validation = true;
                        });
                      } else {
                        setState(() {
                          _emoje_validation = false;
                        });
                      }
                      if (!_emoje_validation && !_icon_name_validation && !_name_validation) {
                        _Insert_Custom_Activity(name_Activity, image, points, widget.Section_id);
                      }
                    }, 222),
                  ],
                )),
          ),
        ),
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
              style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 10.sp),
            )
          ],
        ),
      ),
    );
  }

  Widget build_Points_Buttons() {
    int newpoints = getPoints(Emoje_index);
    if (newpoints == 25) {
      isSelected_reward[0] = true;
    } else if (newpoints == 50) {
      isSelected_reward[1] = true;
    } else if (newpoints == 75) {
      isSelected_reward[2] = true;
    } else if (newpoints == 100) {
      isSelected_reward[3] = true;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Circle_Button(25, newpoints == 25),
            SizedBox(
              height: 3.h,
            ),
            Text(
              "Easy".tr(),
              style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 10.sp),
            )
          ],
        ),
        Column(
          children: [
            Circle_Button(50, newpoints == 50),
            SizedBox(
              height: 3.h,
            ),
            Text(
              "Normal".tr(),
              style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 10.sp),
            )
          ],
        ),
        Column(
          children: [
            Circle_Button(75, newpoints == 75),
            SizedBox(
              height: 3.h,
            ),
            Text(
              "Hard",
              style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 10.sp),
            )
          ],
        ),
        Column(
          children: [
            Circle_Button(100, newpoints == 100),
            SizedBox(
              height: 3.h,
            ),
            Text(
              "Expert",
              style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 10.sp),
            )
          ],
        ),
      ],
    );
  }

  Widget Circle_Button(int point, bool enable) {
    if (enable) points = point;
    return Container(
      width: 36.h,
      height: 36.h,
      child: TextButton(
        onPressed: () {},
        child: Text(
          point.toString(),
          style: TextStyle(color: AppColor.kTextColor, fontSize: 11.sp, fontFamily: "Subjective"),
        ),
        style: ElevatedButton.styleFrom(
          //tapTargetSize: MaterialTapTargetSize.values(0),
          shape: CircleBorder(),

          primary: enable ? AppColor.mainBtn : AppColor.darkModePrim,

          //onPrimary: clicked_Color,
        ),
      ),
    );
  }

  Widget Insert_Button(String name, VoidCallback function, double width) {
    return ButtonTheme(
      minWidth: 200.0,
      // height: 100.0,
      child: ElevatedButton(
        child: Text(
          name,
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontFamily: "Subjective", fontWeight: FontWeight.bold),
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
          minimumSize: MaterialStateProperty.all<Size>(Size(width.w, 50.h)),
        ),
      ),
    );
  }

  AlertDialog buildImageDialog() {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
      contentPadding: EdgeInsets.all(15.w),
      //clipBehavior: Clip.antiAliasWithSaveLayer,

      backgroundColor: AppColor.darkModePrim,
      scrollable: true,
      // title: Center(child: const Text('Select Image')),
      titleTextStyle: TextStyle(
        color: AppColor.kTextColor,
        fontFamily: "Subjective",
      ),

      content: StatefulBuilder(
        builder: (context, setState) => Container(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 5, childAspectRatio: 0.8),
            itemBuilder: (context, index) {
              //print(Categry_name);
              return ButtonTheme(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      //selected=true;
                      imageSelected = results[index];
                      /*File file = new File(imageSelected);
                      image  = file.path.split('/').last;*/
                      //select.forEach((element) {element=false;});
                      for (int i = 0; i < select.length; i++) {
                        select[i] = false;
                      }
                      select[index] = !select[index];
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(AppColor.darkModeSeco),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0.r),
                        side: BorderSide(color: AppColor.darkModePrim),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(Size(150.w, 50.h)),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
                  ),
                  child: Container(
                    //padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    //width: 160.0,
                    //height: 160.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: select[index] ? AppColor.mainBtn : AppColor.darkModeSeco),
                    child: SizedBox(
                      width: 100.w,
                      height: 100.w,
                      child: Image(
                        image: NetworkImage(results[index]),
                        // height:90,
                        //width: 90,
                      ),
                    ),
                  ),
                ),
              );
            },
            // itemCount: Single_Section_activite[Section_index].activities.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: _Images.length,
          ),
          width: 1.sw,
          height: 0.7.sh,
        ),
      ),
      actions: <Widget>[
        Center(
            child: ButtonTheme(
                minWidth: 200.0,
                // height: 100.0,
                child: ElevatedButton(
                  child: Text(
                    'Continue'.tr(),
                    style: TextStyle(
                        color: AppColor.darkModePrim,
                        fontSize: 22.sp,
                        fontFamily: "Subjective",
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    setState(() {
                      File file = new File(imageSelected);
                      image = file.path.split('/').last;

                      //image=imageSelected.s;
                      Navigator.of(context).pop();
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainBtn),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0.r),
                        side: BorderSide(color: AppColor.darkModePrim),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(Size(150.w, 50.h)),
                  ),
                )))
      ],
    );
  }

  Future _Insert_Custom_Activity(String name, String imagePath, int points, int Section_id) async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingImages = true;
      });
      var res = await CreateCustomActivity("api/activity", name, imagePath, points, Section_id, token);
      // print(json.decode(res.body)['data'][0]["id"]);

      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 402) {
        setState(() {
          _isLoadingImages = false;
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
        /*single_Activite = new singleActivity(
            activite.id,
            activite.Section_id,
            activite.name,
            activite.image,
            activite.points,
            activite.isClicked);*/

        /* activite,
                new Emoje(image_mood_path, image_mood_name, image_mood_Clicked),
                from_time,
                to_Time,
                notes*/ /*);*/
        // print(image_mood_path);
        // print(image_mood_path);
        setState(() {
          _isLoadingImages = false;
        });
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => MainScreen(
                  TabId: 2,
                )));
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
}
