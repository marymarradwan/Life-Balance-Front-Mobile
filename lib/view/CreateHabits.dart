import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/Notifications.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/model/habits_item.dart';
import 'package:life_balancing/model/image_item.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/view/main_screen.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../Util/ScreenHelper.dart';
import 'PopUpInfo.dart';
import 'Premium.dart';
import 'login.dart';

class CreateHabitsPage extends StatefulWidget {
  final String HeaderName;
  final String ButtonNamr;
  final HabitItem item;

  const CreateHabitsPage({Key key, this.HeaderName, this.ButtonNamr, this.item}) : super(key: key);

  @override
  _CreateHabitsPage createState() => _CreateHabitsPage();
}

class _CreateHabitsPage extends State<CreateHabitsPage> {
  TextEditingController Habitsname_Controller = new TextEditingController();
  TextEditingController NumberOF_time_Controller = new TextEditingController();
  TextEditingController TimeOfTheHabits_Controller = new TextEditingController();
  TextEditingController Reminder_Controller = new TextEditingController();

  //TextEditingController timeinput = TextEditingController();
  String image_Name = "assets/images/temp@2x.png";

  String name_Habits;

  String section_Title;
  int section_id;
  int time_Remaining;

  int points;
  DateTime starting_Day;
  int dateType;

  String time_of_The_Habits;
  TimeOfDay Reminder;
  PerformHabits perform_habits;
  String repeat = "Daily";
  int repeatType;

  List<String> days = List<String>();
  List<bool> isSelected_Starting_Day = [false, false, false];
  List<bool> isSelected_repetition = [false, false, false];

  List<bool> isSelected_reward = [false, false, false, false];

  //int count_Remender;
  List<bool> Categry = [false, false, false, false, false, false];

  String imageSelected;

  bool _isLoadingImages = true, _isInit = false;
  List<ImageItem> _Images = [];
  List<String> results = [];
  List<bool> select = [];

  // bool selected = false;
  String image;

  //Validation the Habits
  bool _button_Validatio = false,
      _habits_name_validiate = false,
      _number_of_time_validiate = false,
      _time_of_habits_validiate = false,
      _reminder_validiate = false;
  bool isValid = false;

  @override
  void dispose() {
    Habitsname_Controller.dispose();
    NumberOF_time_Controller.dispose();
    TimeOfTheHabits_Controller.dispose();
    Reminder_Controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    //timeinput.text = "";
    if (!_isInit) {
      _simulateLoadImage();
    }
    _isInit = true;
    if (widget.HeaderName.compareTo("Edit Habit") == 0) {
      name_Habits = widget.item.habits_name ?? "Habits Name";
      Habitsname_Controller = new TextEditingController(text: widget.item.habits_name);
      NumberOF_time_Controller = new TextEditingController(text: widget.item.times_Remaining.toString());
      TimeOfTheHabits_Controller = new TextEditingController(text: widget.item.time_Of_The_Habits ?? '');
      // Reminder = widget.item.Reminder;
      // Reminder_Controller = new TextEditingController(
      //     text: Reminder.hour.toString() + ":" + Reminder.minute.toString());
      isSelected_Starting_Day[widget.item.date_type - 1] = true;
      isSelected_repetition[widget.item.repetition - 1] = true;
      time_Remaining = widget.item.times_Remaining;
      imageSelected = widget.item.image;
      time_of_The_Habits = widget.item.time_Of_The_Habits;
      //image_Name=widget.item.image;
      //if(widget.item.starting_Day)
      section_id = widget.item.section_id ?? 0;
      print(section_id.toString());
      Categry[section_id - 1] = true;
      //imageSelected=widget.item.image;
      points = widget.item.points;
      if (points == 25)
        isSelected_reward[0] = true;
      else if (points == 50)
        isSelected_reward[1] = true;
      else if (points == 75)
        isSelected_reward[2] = true;
      else if (points == 100) isSelected_reward[3] = true;
      dateType = widget.item.date_type;
      //change to repition type
      repeatType = widget.item.date_type;
    }
    //tasknumber = tasks.length;

    super.initState();
  }

  Future _updateHabits(int id, HabitApi item) async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingImages = true;
      });
      print(item.toString());
      var res = await updateHabitItem("api/update-habit", id, item, token);
      print(res.statusCode);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        List<dynamic> habitsUpdated = json.decode(res.body)['data'];
        print(habitsUpdated.toString());
        /* print(habitsUpdated.toString());
         Tasks task = new Tasks(
          tasks['id'],
          tasks['goal_id'],
          tasks['is_Finished'],
          tasks['title'],
        );*/
        //   print(tasks.length);
        setState(() {
          // item.is_Finished = !item.is_Finished;
          //item = task;

          _isLoadingImages = false;
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

  Future _simulateLoadImage() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);

      var res = await getData("api/images", token);
      print(json.decode(res.body)['data']);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        List<dynamic> images = json.decode(res.body)['data'];
        List<ImageItem> newImages = [];
        for (var i = 0; i < images.length; i++) {
          newImages.add(ImageItem(images[i]['id'], images[i]['image'], images[i]['image_name']));
          select.add(false);
        }
        setState(() {
          _Images = newImages;
          _Images.forEach((element) {
            results.add(element.ImageUrl);
          });
          // results =
          print(results);
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

  Future _createHabits(HabitApi habitItem) async {
    setState(() {
      _isLoadingImages = true;
    });
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      print("test11");
      print(habitItem.toString());
      var res = await createHabit("api/habit", habitItem, token);
      print("StatusCode${res.statusCode}");
      print(res.body);
      print("test22");
      if (res.statusCode == 401) {
        print("in401");
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
      } else if (res.statusCode == 200 && res.statusCode != 402) {
        print("in200");
        setState(() {
          _isLoadingImages = false;
        });
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => MainScreen(
                  TabId: 1,
                )));
      } else {
        print("inelse");
        Toast.show(
          'Network Error'.tr(),
          context,
          backgroundColor: Colors.red,
          gravity: Toast.BOTTOM,
          duration: Toast.LENGTH_LONG,
        );
        setState(() {
          _isLoadingImages = false;
        });
      }
    });
  }

  AlertDialog buildImageDialog() {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
      contentPadding: EdgeInsets.all(15.w),
      //clipBehavior: Clip.antiAliasWithSaveLayer,

      backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
      scrollable: true,
      // title: Center(child: const Text('Select Image')),
      titleTextStyle: TextStyle(
        color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
        fontFamily: "Subjective",
      ),

      content: StatefulBuilder(
        builder: (context, setState) => Container(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 5, childAspectRatio: 0.8),
            itemBuilder: (context, index) {
              //print(Categry_name);
              return ButtonTheme(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      //selected=true;
                      imageSelected = results[index];
                      image_Name = _Images[index].ImageName;
                      print(_Images[index]);
                      if (imageSelected != null)
                        //_image_validiate=true;
                        //select.forEach((element) {element=false;});
                        for (int i = 0; i < select.length; i++) {
                          select[i] = false;
                        }
                      select[index] = !select[index];
                      print(results[index]);
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0.r),
                        side: BorderSide(
                            color:
                                CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim),
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
                      color: select[index]
                          ? CashHelper.getData(key: ChangeTheme)
                              ? AppColor.mainBtnLightMode
                              : AppColor.mainBtn
                          : CashHelper.getData(key: ChangeTheme)
                              ? AppColor.LightModeSecTextField
                              : AppColor.darkModeSeco,
                    ),
                    child: SizedBox(
                      width: 150.w,
                      height: 150.w,
                      child: CircleAvatar(
                        radius: 30.r,
                        // backgroundImage: NetworkImage(image),
                        backgroundColor: Colors.transparent,
                        child: CachedNetworkImage(
                          imageUrl: results[index],
                          errorWidget: (context, url, error) => Icon(
                            Icons.error,
                            color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                          ),
                        ),
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
          width: MediaQuery.of(context).size.width,
          height: 0.7.sh,
        ),
      ),
      actions: <Widget>[
        Center(
            child: ButtonTheme(
                minWidth: 200.0,
                //  height: 100.0,
                child: ElevatedButton(
                  child: Text(
                    'Continue'.tr(),
                    style: TextStyle(
                        color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                        fontSize: 22.sp,
                        fontFamily: "Subjective",
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    setState(() {
                      File file = new File(imageSelected);
                      image = file.path.split('/').last;

                      Navigator.of(context).pop();
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0.r),
                        side: BorderSide(
                          color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                        ),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(Size(150.w, 50.h)),
                  ),
                )))
      ],
    );
  }

  Widget Remainder() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Set A Reminder".tr(),
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: "Subjective",
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              ),
            ),
            PopUpInfo(
              message: "When you would like to be reminded to do your habit".tr(),
              child: Material(
                color: Colors.transparent,
                //borderRadius: BorderRadius.circular(25.0),
                child: InkWell(
                  child: Icon(
                    Icons.info_outline,
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                    size: 21.r,
                  ),
                  /*onTap: () {
                    */ /*  showDialog(
                        useSafeArea: true,
                        context: context,
                        builder: (BuildContext context) => PopUpInfo(
                              InfoText:

                            ));*/ /*
                    //info button
                    //print(Reminder.hour);
                    //print(Reminder.minute);
                  },*/
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5.h,
        ),
        TextField(
          //scrollPadding: EdgeInsets.all(50),
          //textAlignVertical: TextAlignVertical.bottom,
          onTap: () async {
            TimeOfDay pickedTime = await showTimePicker(
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
              initialTime: TimeOfDay.now(),
              context: context,
            );
            Reminder = pickedTime;
            //print(Reminder);
            if (pickedTime != null) {
              //_reminder_validiate=true;
              print(pickedTime.format(context)); //output 10:51 PM
              DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
              //converting to DateTime so that we can further format on different pattern.
              String formattedTime = DateFormat('HH:mm a').format(parsedTime);
              //DateFormat() is from intl package, you can format the time on any pattern you need.

              setState(() {
                Reminder_Controller.text = formattedTime;
                //Reminder=DateTime.parse(formattedString)formattedTime;//set the value of text field.
              });
            }
          },

          controller: Reminder_Controller,
          readOnly: true,
          textAlign: TextAlign.left,
          //keyboardType: TextInputType.number,

          style: TextStyle(
              fontSize: 12.sp,
              fontFamily: "Subjective",
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
          showCursor: false,
          decoration: InputDecoration(
            errorText: _reminder_validiate ? "Plase Add Reminder".tr() : null,
            filled: true,
            fillColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
            contentPadding: EdgeInsets.only(left: 14.0.w, bottom: 8.0.h, top: 8.0.h),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim),
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
            ),
          ),
        ),
      ],
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

  Widget Circle_Button(String day, VoidCallback function, int day_index, List list) {
    return Container(
      width: 36.h,
      height: 36.h,
      child: TextButton(
        onPressed: function,
        child: Text(
          day,
          style: TextStyle(
            color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
            fontFamily: "Subjective",
            fontWeight: FontWeight.bold,
            fontSize: 11.sp,
          ),
        ),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          //padding: EdgeInsets.all(10.h),
          primary: list[day_index]
              ? CashHelper.getData(key: ChangeTheme)
                  ? AppColor.mainBtnLightMode
                  : AppColor.mainBtn
              : CashHelper.getData(key: ChangeTheme)
                  ? AppColor.lightModePrim
                  : AppColor.darkModePrim,
          //onPrimary: clicked_Color,
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    ScreenHelper(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
        body: LoadingOverlay(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  right: ScreenHelper.fromWidth(4.0),
                  left: ScreenHelper.fromWidth(4.0),
                ),
                child: Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /*SizedBox(height: 30.0,),*/
                        Text(
                          widget.HeaderName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Subjective",
                            fontSize: 18.sp,
                            color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Stack(
                          children: [
                            Container(
                              width: 156.h,
                              height: 156.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0.r),
                                color: CashHelper.getData(key: ChangeTheme)
                                    ? AppColor.LightModeSecTextField
                                    : AppColor.darkModeSeco,
                              ),
                              //  padding: EdgeInsets.all(30.w),
                              child: Container(
                                /*width: 100.0,
                                  height: 100.0,*/
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0.r),
                                ),
                                child: imageSelected == null
                                    ? Center(
                                        child: Text(
                                        "Select Image".tr(),
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            fontFamily: "Subjective",
                                            fontWeight: FontWeight.bold,
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? Colors.black
                                                : AppColor.kTextColor),
                                      ))
                                    : CircleAvatar(
                                        radius: 30.r,
                                        // backgroundImage: NetworkImage(image),
                                        backgroundColor: Colors.transparent,
                                        child: CachedNetworkImage(
                                          imageUrl: imageSelected,
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.error,
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? AppColor.mainBtnLightMode
                                                : AppColor.mainBtn,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            imageSelected == null
                                ? Padding(
                                    padding: EdgeInsets.only(left: 100.h, top: 100.h),
                                    child: Container(
                                      width: 46.h,
                                      height: 46.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100.0.r),
                                        color: CashHelper.getData(key: ChangeTheme)
                                            ? AppColor.lightModePrim
                                            : AppColor.darkModePrim,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          setState(() {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) => buildImageDialog());
                                          });
                                        },
                                        child: Icon(
                                          Icons.edit,
                                          size: 34.r,
                                          color: CashHelper.getData(key: ChangeTheme)
                                              ? AppColor.mainBtnLightMode
                                              : AppColor.mainBtn,
                                        ),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(left: 100.h, top: 100.h),
                                    child: Container(
                                      width: 46.h,
                                      height: 46.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100.0.r),
                                        color: CashHelper.getData(key: ChangeTheme)
                                            ? AppColor.lightModePrim.withOpacity(0.3)
                                            : AppColor.darkModePrim.withOpacity(0.3),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            FocusScope.of(context).unfocus();
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) => buildImageDialog());
                                          });
                                        },
                                        child: Icon(
                                          Icons.edit,
                                          size: 34.r,
                                          color: CashHelper.getData(key: ChangeTheme)
                                              ? AppColor.mainBtnLightMode
                                              : AppColor.mainBtn,
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        /*Text(
                          name_Habits ?? "Habits Name",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width/15,
                              fontFamily: "Subjective",
                              fontWeight: FontWeight.bold,
                              color: AppColor.kTextColor),
                        ),*/
                        /* SizedBox(
                          height: 10,
                        ),*/
                        Container(
                          padding: EdgeInsets.all(10.0.w),
                          //width: 336.0,
                          //height: 180.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: CashHelper.getData(key: ChangeTheme)
                                  ? AppColor.LightModeSecTextField
                                  : AppColor.darkModeSeco),
                          child: Column(
                            children: [
                              Text(
                                "Habit Name".tr(),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontFamily: "Subjective",
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              TextField(
                                //scrollPadding: EdgeInsets.all(50),
                                //textAlignVertical: TextAlignVertical.bottom,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: "Subjective",
                                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
                                showCursor: true,
                                controller: Habitsname_Controller,
                                /* onTap: () {
                                  FocusScope.of(context).unfocus();
                                },*/
                                onChanged: (value) {
                                  setState(() {
                                    name_Habits = value;
                                    //_habits_name_validiate=true;
                                  });
                                },
                                /*onEditingComplete: (){
                                setState(() {
                                  name_Habits = text.text;
                                });
                              },*/

                                cursorColor:
                                    CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                                decoration: InputDecoration(
                                  errorText: _habits_name_validiate ? "Place Enter Name".tr() : null,
                                  filled: true,
                                  fillColor: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.lightModePrim
                                      : AppColor.darkModePrim,
                                  contentPadding: EdgeInsets.only(left: 14.0.w, bottom: 8.0.h, top: 8.0.h),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: CashHelper.getData(key: ChangeTheme)
                                            ? AppColor.mainBtnLightMode
                                            : AppColor.mainBtn),
                                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: CashHelper.getData(key: ChangeTheme)
                                            ? AppColor.lightModePrim
                                            : AppColor.darkModePrim),
                                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Text(
                                "Starting Day".tr(),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontFamily: "Subjective",
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.r),
                                  color: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.lightModePrim
                                      : AppColor.darkModePrim,
                                ),
                                child: ToggleButtons(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Text(
                                        "\tToday\t",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: "Subjective",
                                          color:
                                              CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0.w),
                                      child: Text(
                                        "Tomorrow".tr(),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: "Subjective",
                                          color:
                                              CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0.w),
                                      child: Text(
                                        "NextWeek".tr(),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: "Subjective",
                                          color:
                                              CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                  isSelected: isSelected_Starting_Day,
                                  selectedColor: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.LightModeSecTextField
                                      : AppColor.darkModeSeco,
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                  borderRadius: BorderRadius.circular(25.r),
                                  fillColor: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.mainBtnLightMode
                                      : AppColor.mainBtn,
                                  borderColor: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.LightModeSecTextField
                                      : AppColor.darkModeSeco,
                                  onPressed: (int newIndex) {
                                    FocusScope.of(context).unfocus();
                                    DateTime now = DateTime.now();
                                    setState(() {
                                      for (int index = 0; index < isSelected_Starting_Day.length; index++) {
                                        if (index == newIndex && widget.HeaderName.compareTo("New Habit") == 0) {
                                          isSelected_Starting_Day[index] = !isSelected_Starting_Day[index];
                                          /*  if(_starting_day_validiate)
                                            _starting_day_validiate=false;

                                          _starting_day_validiate=true;*/
                                        } else if (widget.HeaderName.compareTo("New Habit") == 0) {
                                          isSelected_Starting_Day[index] = false;
                                        }
                                      }
                                    });
                                    if (newIndex == 0 && widget.HeaderName.compareTo("New Habit") == 0) {
                                      starting_Day = now;
                                      dateType = 1;
                                    } else if (newIndex == 1 && widget.HeaderName.compareTo("New Habit") == 0) {
                                      starting_Day = DateTime(now.year, now.month, now.day + 1);
                                      dateType = 2;
                                    } else if (newIndex == 2 && widget.HeaderName.compareTo("New Habit") == 0) {
                                      starting_Day = DateTime(now.year, now.month, now.day + 7);
                                      dateType = 3;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          padding: EdgeInsets.all(10.0.w),
                          //width: 336.0,
                          //height: 150.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: CashHelper.getData(key: ChangeTheme)
                                  ? AppColor.LightModeSecTextField
                                  : AppColor.darkModeSeco),
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
                                height: 5.h,
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
                                      section_Title = "Social".tr();
                                      section_id = 1;
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
                                      "Carrer".tr(),
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
                                      section_Title = "Career";
                                      section_id = 2;
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
                                      section_Title = "Learn".tr();
                                      section_id = 3;
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
                                  Button_Category("assets/images/spirit.png", "Spirit".tr(), AppColor.spiritSections,
                                      () {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      for (int index = 0; index < Categry.length; index++) {
                                        if (index == 3) {
                                          Categry[3] = true;
                                        } else {
                                          Categry[index] = false;
                                        }
                                      }
                                      section_Title = "Spirit".tr();
                                      section_id = 4;
                                      /*if(_Cateogry_validiate)
                                        _Cateogry_validiate=false;

                                      _Cateogry_validiate=true;*/
                                    });
                                  }, 3),
                                  SizedBox(
                                    width: 4.h,
                                  ),
                                  Button_Category("assets/images/health.png", "Health".tr(), AppColor.healthSections,
                                      () {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      for (int index = 0; index < Categry.length; index++) {
                                        if (index == 4) {
                                          Categry[4] = true;
                                        } else {
                                          Categry[index] = false;
                                        }
                                      }
                                      section_Title = "Health";
                                      section_id = 5;
                                      /*if(_Cateogry_validiate)
                                        _Cateogry_validiate=false;

                                      _Cateogry_validiate=true;*/
                                    });
                                  }, 4),
                                  SizedBox(width: 4.w),
                                  Button_Category(
                                      "assets/images/emotion.png", "Emotions".tr(), AppColor.emotionsSections, () {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      for (int index = 0; index < Categry.length; index++) {
                                        if (index == 5) {
                                          Categry[5] = true;
                                        } else {
                                          Categry[index] = false;
                                        }
                                      }
                                      section_Title = "Emotions".tr();
                                      section_id = 6;
                                      /* if(_Cateogry_validiate)
                                        _Cateogry_validiate=false;

                                      _Cateogry_validiate=true;*/
                                    });
                                  }, 5),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12.h,
                        ),
                        Container(
                          padding: EdgeInsets.all(10.0.w),
                          //width: 336.0,
                          //height: 180.0,
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
                                "How Often do you want to Perform this Habit?".tr(),
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: "Subjective",
                                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.r),
                                  color: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.lightModePrim
                                      : AppColor.darkModePrim,
                                ),
                                child: ToggleButtons(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Text(
                                        "Daily".tr(),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: "Subjective",
                                          color:
                                              CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Text(
                                        "Weekly".tr(),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: "Subjective",
                                          color:
                                              CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(14.w),
                                      child: Text(
                                        "Monthly".tr(),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: "Subjective",
                                          color:
                                              CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                  isSelected: isSelected_repetition,
                                  selectedColor: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.LightModeSecTextField
                                      : AppColor.darkModeSeco,
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                  borderRadius: BorderRadius.circular(25.r),
                                  fillColor: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.mainBtnLightMode
                                      : AppColor.mainBtn,
                                  borderColor: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.LightModeSecTextField
                                      : AppColor.darkModeSeco,
                                  onPressed: (int newIndex) {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      for (int index = 0; index < isSelected_repetition.length; index++) {
                                        if (index == newIndex && widget.HeaderName.compareTo("New Habit") == 0) {
                                          isSelected_repetition[index] = !isSelected_repetition[index];
                                          /* if(_repition_validiate)
                                            _repition_validiate=false;

                                          _repition_validiate=true;*/
                                        } else if (widget.HeaderName.compareTo("New Habit") == 0) {
                                          isSelected_repetition[index] = false;
                                        }
                                      }
                                    });
                                    if (newIndex == 0 && widget.HeaderName.compareTo("New Habit") == 0) {
                                      repeat = "Daily".tr();
                                      repeatType = 1;
                                      if (time_Remaining != null) {
                                        if (time_Remaining == 3 || time_Remaining > 3) {
                                          points = 100;
                                          setState(() {
                                            for (int index = 0; index < isSelected_reward.length; index++) {
                                              if (index == 3) {
                                                isSelected_reward[index] = true;
                                                // !isSelected_reward[index];
                                              } else {
                                                isSelected_reward[index] = false;
                                              }
                                            }
                                          });
                                        } else if (time_Remaining == 2) {
                                          points = 75;
                                          setState(() {
                                            for (int index = 0; index < isSelected_reward.length; index++) {
                                              if (index == 2) {
                                                isSelected_reward[index] = true;
                                                // isSelected_reward[index] =
                                                // !isSelected_reward[index];
                                              } else {
                                                isSelected_reward[index] = false;
                                              }
                                            }
                                          });
                                        } else {
                                          points = 50;
                                          setState(() {
                                            for (int index = 0; index < isSelected_reward.length; index++) {
                                              if (index == 1) {
                                                isSelected_reward[index] = true;
                                              } else {
                                                isSelected_reward[index] = false;
                                              }
                                            }
                                          });
                                        }
                                      }
                                    } else if (newIndex == 1 && widget.HeaderName.compareTo("New Habit") == 0) {
                                      repeat = "Weekly".tr();
                                      repeatType = 2;
                                      if (time_Remaining != null) {
                                        if (time_Remaining == 5 || time_Remaining > 5) {
                                          points = 100;
                                          setState(() {
                                            for (int index = 0; index < isSelected_reward.length; index++) {
                                              if (index == 3) {
                                                isSelected_reward[index] = true;
                                                // !isSelected_reward[index];
                                              } else {
                                                isSelected_reward[index] = false;
                                              }
                                            }
                                          });
                                        } else if (time_Remaining == 3 || time_Remaining == 4) {
                                          points = 75;
                                          setState(() {
                                            for (int index = 0; index < isSelected_reward.length; index++) {
                                              if (index == 2) {
                                                isSelected_reward[index] = true;
                                                // isSelected_reward[index] =
                                                // !isSelected_reward[index];
                                              } else {
                                                isSelected_reward[index] = false;
                                              }
                                            }
                                          });
                                        } else {
                                          points = 50;
                                          setState(() {
                                            for (int index = 0; index < isSelected_reward.length; index++) {
                                              if (index == 1) {
                                                isSelected_reward[index] = true;
                                              } else {
                                                isSelected_reward[index] = false;
                                              }
                                            }
                                          });
                                        }
                                      }
                                    } else if (newIndex == 2 && widget.HeaderName.compareTo("New Habit") == 0) {
                                      repeat = "Monthly".tr();
                                      repeatType = 3;
                                      if (time_Remaining != null) {
                                        if (time_Remaining == 10 || time_Remaining > 10) {
                                          points = 100;
                                          setState(() {
                                            for (int index = 0; index < isSelected_reward.length; index++) {
                                              if (index == 3) {
                                                isSelected_reward[index] = true;
                                                // !isSelected_reward[index];
                                              } else {
                                                isSelected_reward[index] = false;
                                              }
                                            }
                                          });
                                        } else if (time_Remaining >= 5 && time_Remaining < 10) {
                                          points = 75;
                                          setState(() {
                                            for (int index = 0; index < isSelected_reward.length; index++) {
                                              if (index == 2) {
                                                isSelected_reward[index] = true;
                                                // isSelected_reward[index] =
                                                // !isSelected_reward[index];
                                              } else {
                                                isSelected_reward[index] = false;
                                              }
                                            }
                                          });
                                        } else {
                                          points = 50;
                                          setState(() {
                                            for (int index = 0; index < isSelected_reward.length; index++) {
                                              if (index == 1) {
                                                isSelected_reward[index] = true;
                                              } else {
                                                isSelected_reward[index] = false;
                                              }
                                            }
                                          });
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 20, right: 10, top: 5, bottom: 5),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              //     children: [
                              //       Circle_Button("Mon", () {
                              //         setState(() {isSelected_Day_Of_Week[0] =
                              //         !isSelected_Day_Of_Week[0];
                              //         if(isSelected_Day_Of_Week[0])
                              //           days.add("Mon");
                              //         else if(!isSelected_Day_Of_Week[0])
                              //           days.remove("Mon");
                              //
                              //         } );
                              //       }, 0, isSelected_Day_Of_Week),
                              //       Circle_Button("Tue", () {
                              //         setState(() {isSelected_Day_Of_Week[1] =
                              //         !isSelected_Day_Of_Week[1];
                              //         if(isSelected_Day_Of_Week[1])
                              //           days.add("Tue");
                              //         else if(!isSelected_Day_Of_Week[1])
                              //           days.remove("Tue");
                              //         } );
                              //       }, 1, isSelected_Day_Of_Week),
                              //       Circle_Button("Wed", () {
                              //         setState(() { isSelected_Day_Of_Week[2] =
                              //             !isSelected_Day_Of_Week[2];
                              //         if(isSelected_Day_Of_Week[2])
                              //           days.add("Wed");
                              //         else if(!isSelected_Day_Of_Week[2])
                              //           days.remove("Wed");
                              //         }
                              //             );
                              //       }, 2, isSelected_Day_Of_Week),
                              //       Circle_Button("Thu", () {
                              //         setState(() { isSelected_Day_Of_Week[3] =
                              //             !isSelected_Day_Of_Week[3];
                              //         if(isSelected_Day_Of_Week[3])
                              //           days.add("Thu");
                              //         else if(!isSelected_Day_Of_Week[3])
                              //           days.remove("Thu");
                              //         });
                              //       }, 3, isSelected_Day_Of_Week),
                              //       Circle_Button("Fri", () {
                              //         setState(() { isSelected_Day_Of_Week[4] =
                              //             !isSelected_Day_Of_Week[4];
                              //         if(isSelected_Day_Of_Week[4])
                              //           days.add("Fri");
                              //         else if(!isSelected_Day_Of_Week[4])
                              //           days.remove("Fri");
                              //         });
                              //       }, 4, isSelected_Day_Of_Week),
                              //       Circle_Button("Sat", () {
                              //         setState(() { isSelected_Day_Of_Week[5] =
                              //             !isSelected_Day_Of_Week[5];
                              //         if(isSelected_Day_Of_Week[5])
                              //           days.add("Sat");
                              //         else if(!isSelected_Day_Of_Week[5])
                              //           days.remove("Sat");
                              //         });
                              //       }, 5, isSelected_Day_Of_Week),
                              //       Circle_Button("San", () {
                              //         setState(() { isSelected_Day_Of_Week[6] =
                              //             !isSelected_Day_Of_Week[6];
                              //         if(isSelected_Day_Of_Week[6])
                              //           days.add("San");
                              //         else if(!isSelected_Day_Of_Week[6])
                              //           days.remove("San");
                              //         });
                              //       }, 6, isSelected_Day_Of_Week),
                              //     ],
                              //   ),
                              // ),
                              SizedBox(height: 5.h),
                              Text(
                                "Number Of times $repeat",
                                style: TextStyle(
                                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                    fontFamily: "Subjective",
                                    fontSize: 12.sp),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              TextField(
                                //scrollPadding: EdgeInsets.all(50),
                                //textAlignVertical: TextAlignVertical.bottom,
                                textAlign: TextAlign.left,
                                keyboardType: TextInputType.number,
                                enabled: widget.HeaderName.compareTo("New Habit") == 0 ? true : false,
                                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: "Subjective",
                                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
                                showCursor: true,
                                controller: NumberOF_time_Controller,
                                cursorColor:
                                    CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                                onTap: () {
                                  perform_habits = new PerformHabits(repeat, days);
                                },
                                onChanged: (value) {
                                  time_Remaining = int.tryParse(value);
                                  if (time_Remaining != null) {
                                    if (repeatType == 1) {
                                      if (time_Remaining == 3 || time_Remaining > 3) {
                                        points = 100;
                                        setState(() {
                                          for (int index = 0; index < isSelected_reward.length; index++) {
                                            if (index == 3) {
                                              isSelected_reward[index] = true;
                                              // !isSelected_reward[index];
                                            } else {
                                              isSelected_reward[index] = false;
                                            }
                                          }
                                        });
                                      } else if (time_Remaining == 2) {
                                        points = 75;
                                        setState(() {
                                          for (int index = 0; index < isSelected_reward.length; index++) {
                                            if (index == 2) {
                                              isSelected_reward[index] = true;
                                              // isSelected_reward[index] =
                                              // !isSelected_reward[index];
                                            } else {
                                              isSelected_reward[index] = false;
                                            }
                                          }
                                        });
                                      } else {
                                        points = 50;
                                        setState(() {
                                          for (int index = 0; index < isSelected_reward.length; index++) {
                                            if (index == 1) {
                                              isSelected_reward[index] = true;
                                            } else {
                                              isSelected_reward[index] = false;
                                            }
                                          }
                                        });
                                      }
                                    } else if (repeatType == 2) {
                                      if (time_Remaining == 5 || time_Remaining > 5) {
                                        points = 100;
                                        setState(() {
                                          for (int index = 0; index < isSelected_reward.length; index++) {
                                            if (index == 3) {
                                              isSelected_reward[index] = true;
                                              // !isSelected_reward[index];
                                            } else {
                                              isSelected_reward[index] = false;
                                            }
                                          }
                                        });
                                      } else if (time_Remaining == 3 || time_Remaining == 4) {
                                        points = 75;
                                        setState(() {
                                          for (int index = 0; index < isSelected_reward.length; index++) {
                                            if (index == 2) {
                                              isSelected_reward[index] = true;
                                              // isSelected_reward[index] =
                                              // !isSelected_reward[index];
                                            } else {
                                              isSelected_reward[index] = false;
                                            }
                                          }
                                        });
                                      } else {
                                        points = 50;
                                        setState(() {
                                          for (int index = 0; index < isSelected_reward.length; index++) {
                                            if (index == 1) {
                                              isSelected_reward[index] = true;
                                            } else {
                                              isSelected_reward[index] = false;
                                            }
                                          }
                                        });
                                      }
                                    } else if (repeatType == 3) {
                                      if (time_Remaining == 10 || time_Remaining > 10) {
                                        points = 100;
                                        setState(() {
                                          for (int index = 0; index < isSelected_reward.length; index++) {
                                            if (index == 3) {
                                              isSelected_reward[index] = true;
                                              // !isSelected_reward[index];
                                            } else {
                                              isSelected_reward[index] = false;
                                            }
                                          }
                                        });
                                      } else if (time_Remaining >= 5 && time_Remaining < 10) {
                                        points = 75;
                                        setState(() {
                                          for (int index = 0; index < isSelected_reward.length; index++) {
                                            if (index == 2) {
                                              isSelected_reward[index] = true;
                                              // isSelected_reward[index] =
                                              // !isSelected_reward[index];
                                            } else {
                                              isSelected_reward[index] = false;
                                            }
                                          }
                                        });
                                      } else {
                                        points = 50;
                                        setState(() {
                                          for (int index = 0; index < isSelected_reward.length; index++) {
                                            if (index == 1) {
                                              isSelected_reward[index] = true;
                                            } else {
                                              isSelected_reward[index] = false;
                                            }
                                          }
                                        });
                                      }
                                    }
                                  }
                                  // time_Remaining=value as int;
                                },

                                decoration: InputDecoration(
                                  errorText: _number_of_time_validiate ? "Place Enter Number Of Time".tr() : null,
                                  filled: true,
                                  fillColor: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.lightModePrim
                                      : AppColor.darkModePrim,
                                  contentPadding: EdgeInsets.only(left: 14.0.w, bottom: 8.0.h, top: 8.0.h),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: CashHelper.getData(key: ChangeTheme)
                                            ? AppColor.mainBtnLightMode
                                            : AppColor.mainBtn),
                                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: CashHelper.getData(key: ChangeTheme)
                                            ? AppColor.lightModePrim
                                            : AppColor.darkModePrim),
                                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.0.h,
                        ),
                        Container(
                          // width: 336,
                          //height: 400,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: CashHelper.getData(key: ChangeTheme)
                                  ? AppColor.LightModeSecTextField
                                  : AppColor.darkModeSeco),
                          padding: EdgeInsets.all(10.w),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "This Habit Awards".tr(),
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontFamily: "Subjective",
                                        color:
                                            CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor),
                                  ),
                                  PopUpInfo(
                                    message:
                                        "Points are awarded based on the Frequency and number of times you do your habit"
                                            .tr(),
                                    child: Material(
                                      color: Colors.transparent,
                                      //borderRadius: BorderRadius.circular(25.0),
                                      child: InkWell(
                                        child: Icon(
                                          Icons.info_outline,
                                          color:
                                              CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                          size: 21.r,
                                        ),
                                        /*  onTap: () {
                                          */ /* showDialog(
                                              useSafeArea: true,
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  PopUpInfo(
                                                    InfoText:

                                                  ));*/ /*
                                        },*/
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Circle_Button("25", () {
                                        /* setState(() {
                                          for (int index = 0;
                                              index < isSelected_reward.length;
                                              index++) {
                                            if (index == 0) {
                                              isSelected_reward[index] =
                                                  !isSelected_reward[index];
                                            } else {
                                              isSelected_reward[index] = false;
                                            }
                                          }
                                        });
                                        points = 25;*/
                                      }, 0, isSelected_reward),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      Text(
                                        "Easy".tr(),
                                        style: TextStyle(
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? Colors.black
                                                : AppColor.kTextColor,
                                            fontFamily: "Subjective",
                                            fontSize: 10.sp),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Circle_Button("50", () {
                                        /*setState(() {
                                          for (int index = 0;
                                              index < isSelected_reward.length;
                                              index++) {
                                            if (index == 1) {
                                              isSelected_reward[index] =
                                                  !isSelected_reward[index];
                                            } else {
                                              isSelected_reward[index] = false;
                                            }
                                          }
                                        });
                                        points = 50;*/
                                      }, 1, isSelected_reward),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      Text(
                                        "Normal".tr(),
                                        style: TextStyle(
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? Colors.black
                                                : AppColor.kTextColor,
                                            fontFamily: "Subjective",
                                            fontSize: 10.sp),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Circle_Button("75", () {
                                        /*setState(() {
                                          for (int index = 0;
                                              index < isSelected_reward.length;
                                              index++) {
                                            if (index == 2) {
                                              isSelected_reward[index] =
                                                  !isSelected_reward[index];
                                            } else {
                                              isSelected_reward[index] = false;
                                            }
                                          }
                                        });
                                        points = 75;*/
                                      }, 2, isSelected_reward),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      Text(
                                        "Hard".tr(),
                                        style: TextStyle(
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? Colors.black
                                                : AppColor.kTextColor,
                                            fontFamily: "Subjective",
                                            fontSize: 10.sp),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Circle_Button("100", () {
                                        /*setState(() {
                                          for (int index = 0;
                                              index < isSelected_reward.length;
                                              index++) {
                                            if (index == 3) {
                                              isSelected_reward[index] =
                                                  !isSelected_reward[index];
                                            } else {
                                              isSelected_reward[index] = false;
                                            }
                                          }
                                        });
                                        points = 100;*/
                                      }, 3, isSelected_reward),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      Text(
                                        "Expert".tr(),
                                        style: TextStyle(
                                            color: CashHelper.getData(key: ChangeTheme)
                                                ? Colors.black
                                                : AppColor.kTextColor,
                                            fontFamily: "Subjective",
                                            fontSize: 10.sp),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
/*                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Time Of The Habits",
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontFamily: "Subjective",
                                        color: AppColor.kTextColor),
                                  ),
                                  PopUpInfo(
                                    message:
                                        "When you would like to do your habit",
                                    child: Material(
                                      color: Colors.transparent,
                                      //borderRadius: BorderRadius.circular(25.0),
                                      child: InkWell(
                                        child: Icon(
                                          Icons.info_outline,
                                          color: AppColor.kTextColor,
                                          size: 21.r,
                                        ),
                                        */ /* onTap: () {
                                          */ /* */ /*showDialog(
                                              useSafeArea: true,
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  PopUpInfo(
                                                    InfoText:

                                                  ));*/ /* */ /*
                                        },*/ /*
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              TextField(
                                //scrollPadding: EdgeInsets.all(50),
                                //textAlignVertical: TextAlignVertical.bottom,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: "Subjective",
                                    color: AppColor.kTextColor),

                                showCursor: true,
                                controller: TimeOfTheHabits_Controller,
                                onChanged: (valus) {
                                  time_of_The_Habits = valus;
                                },
                                cursorColor: AppColor.mainBtn,
                                decoration: InputDecoration(
                                  errorText: _time_of_habits_validiate
                                      ? "Place Enter Time Of The Habits"
                                      : null,
                                  filled: true,
                                  fillColor: AppColor.darkModePrim,
                                  contentPadding: EdgeInsets.only(
                                      left: 14.0.w, bottom: 8.0.h, top: 8.0.h),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColor.mainBtn),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.r)),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColor.darkModePrim),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.r)),
                                  ),
                                ),
                              ),*/
                              SizedBox(
                                height: 5.h,
                              ),
                              Remainder(),
                              SizedBox(
                                height: 5.h,
                              ),
                              /*Row(
                                children: [
                                  Text(
                                    "Add Another Reminder",
                                    style: TextStyle(color: AppColor.kTextColor,fontFamily: "Subjective",),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.add_circle,
                                        color: AppColor.mainBtn,
                                      )),
                                ],
                              )*/
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        ButtonTheme(
                          minWidth: 200.0.w,
                          // height: 100.0,
                          child: ElevatedButton(
                            child: isValid
                                ? CircularProgressIndicator(
                                    color: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.lightModePrim
                                        : AppColor.darkModePrim,
                                  )
                                : Text(
                                    widget.ButtonNamr,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Subjective",
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                            onPressed: () async {
                              if (name_Habits == null ||
                                  name_Habits.compareTo("") == 0 ||
                                  name_Habits.compareTo(" ") == 0) {
                                print("name Habits$name_Habits");
                                setState(() {
                                  _habits_name_validiate = true;
                                });
                              } else
                                setState(() {
                                  _habits_name_validiate = false;
                                });
                              if (time_Remaining == null || time_Remaining == 0) {
                                print(" time_Remaining$time_Remaining");
                                setState(() {
                                  _number_of_time_validiate = true;
                                });
                              } else
                                setState(() {
                                  _number_of_time_validiate = false;
                                });
                              /* if (time_of_The_Habits == null ||
                                  time_of_The_Habits.compareTo("") == 0 ||
                                  time_of_The_Habits.compareTo(" ") == 0) {
                                print("time_of_The_Habits$time_of_The_Habits");
                                setState(() {
                                  _time_of_habits_validiate = true;
                                });
                              } else
                                setState(() {
                                  _time_of_habits_validiate = false;
                                });*/
                              /* if (Reminder == null) {
                                print("Reminder$Reminder");
                                setState(() {
                                  _reminder_validiate = true;
                                });
                              } else
                                setState(() {
                                  _reminder_validiate = false;
                                });*/
                              if (imageSelected == null) {
                                Toast.show(
                                  'Place Select Image'.tr(),
                                  context,
                                  backgroundColor: Colors.red,
                                  gravity: Toast.BOTTOM,
                                  duration: Toast.LENGTH_LONG,
                                );
                                _button_Validatio = true;
                              } else if (dateType == null) {
                                Toast.show(
                                  'Place Select Starting Date'.tr(),
                                  context,
                                  backgroundColor: Colors.red,
                                  gravity: Toast.BOTTOM,
                                  duration: Toast.LENGTH_LONG,
                                );
                                _button_Validatio = true;
                              } else if (section_id == null) {
                                print("section_id$section_id");

                                Toast.show(
                                  'Place Select Category'.tr(),
                                  context,
                                  backgroundColor: Colors.red,
                                  gravity: Toast.BOTTOM,
                                  duration: Toast.LENGTH_LONG,
                                );
                                _button_Validatio = true;
                              } else if (repeatType == null) {
                                Toast.show(
                                  'Place Select Perform Of The Habits'.tr(),
                                  context,
                                  backgroundColor: Colors.red,
                                  gravity: Toast.BOTTOM,
                                  duration: Toast.LENGTH_LONG,
                                );
                                _button_Validatio = true;
                              } else {
                                _button_Validatio = false;
                              }

                              if (widget.HeaderName.compareTo("New Habit") == 0) {
                                if ( //!_time_of_habits_validiate &&
                                    !_number_of_time_validiate &&
                                        !_habits_name_validiate &&
                                        //!_reminder_validiate &&
                                        !_button_Validatio) {
                                  HabitApi habit = new HabitApi(
                                      image_Name,
                                      time_Remaining,
                                      points,
                                      name_Habits,
                                      section_id,
                                      dateType,
                                      repeatType,
                                      time_of_The_Habits,
                                      Reminder != null ? Reminder.hour : null,
                                      Reminder != null ? Reminder.minute : null);
                                  setState(() {
                                    isValid = true;
                                  });
                                  await Future.delayed(Duration(seconds: 2));
                                  setState(() {
                                    isValid = false;
                                  });
                                  _createHabits(habit);

                                  DateTime newDate = DateTime.now();

                                  if (dateType == 1) {
                                    DateTime formatedDate = new DateTime(
                                        newDate.year,
                                        newDate.month,
                                        newDate.day,
                                        Reminder != null ? Reminder.hour : newDate.hour,
                                        Reminder != null ? Reminder.minute : newDate.minute,
                                        newDate.second,
                                        newDate.millisecond,
                                        newDate.microsecond);
                                    Notifications.send(formatedDate, name_Habits, 'Don\'t forget your habit');
                                  } else if (dateType == 2) {
                                    DateTime formatedDate = new DateTime(
                                        newDate.year,
                                        newDate.month,
                                        newDate.day + 1,
                                        Reminder != null ? Reminder.hour : newDate.hour,
                                        Reminder != null ? Reminder.minute : newDate.minute,
                                        newDate.second,
                                        newDate.millisecond,
                                        newDate.microsecond);
                                    Notifications.send(formatedDate, name_Habits, 'Don\'t forget your habit');
                                  } else {
                                    DateTime formatedDate = new DateTime(
                                        newDate.year,
                                        newDate.month,
                                        newDate.day + 7,
                                        Reminder != null ? Reminder.hour : newDate.hour,
                                        Reminder != null ? Reminder.minute : newDate.minute,
                                        newDate.second,
                                        newDate.millisecond,
                                        newDate.microsecond);
                                    Notifications.send(formatedDate, name_Habits, 'Don\'t forget your habit');
                                  }
                                  /*   Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainScreen(
                                                TabId: 1,
                                              )));*/
                                }
                              } else if (widget.HeaderName.compareTo("Edit Habit") == 0) {
                                if ( //!_time_of_habits_validiate &&
                                    !_number_of_time_validiate &&
                                        !_habits_name_validiate &&
                                        // !_reminder_validiate &&
                                        !_button_Validatio) {
                                  print("Edited");
                                  HabitApi habit = new HabitApi(
                                      image_Name,
                                      time_Remaining,
                                      points,
                                      name_Habits,
                                      section_id,
                                      dateType,
                                      repeatType,
                                      time_of_The_Habits,
                                      Reminder != null ? Reminder.hour : null,
                                      Reminder != null ? Reminder.minute : null);
                                  setState(() {
                                    isValid = true;
                                  });
                                  await Future.delayed(Duration(seconds: 2));
                                  setState(() {
                                    isValid = false;
                                  });
                                  _updateHabits(widget.item.id, habit);

                                  DateTime newDate = DateTime.now();
                                  if (dateType == 1) {
                                    DateTime formatedDate = new DateTime(
                                        newDate.year,
                                        newDate.month,
                                        newDate.day,
                                        Reminder != null ? Reminder.hour : newDate.hour,
                                        Reminder != null ? Reminder.minute : newDate.minute,
                                        newDate.second,
                                        newDate.millisecond,
                                        newDate.microsecond);
                                    Notifications.send(formatedDate, name_Habits, 'Don\'t forget your habit');
                                  } else if (dateType == 2) {
                                    DateTime formatedDate = new DateTime(
                                        newDate.year,
                                        newDate.month,
                                        newDate.day + 1,
                                        Reminder != null ? Reminder.hour : newDate.hour,
                                        Reminder != null ? Reminder.minute : newDate.minute,
                                        newDate.second,
                                        newDate.millisecond,
                                        newDate.microsecond);
                                    Notifications.send(formatedDate, name_Habits, 'Don\'t forget your habit');
                                  } else {
                                    DateTime formatedDate = new DateTime(
                                        newDate.year,
                                        newDate.month,
                                        newDate.day + 7,
                                        Reminder != null ? Reminder.hour : newDate.hour,
                                        Reminder != null ? Reminder.minute : newDate.minute,
                                        newDate.second,
                                        newDate.millisecond,
                                        newDate.microsecond);
                                    Notifications.send(formatedDate, name_Habits, 'Don\'t forget your habit');
                                  }
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainScreen(
                                                TabId: 1,
                                              )));
                                }
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.0.r),
                                  side: BorderSide(
                                      color: CashHelper.getData(key: ChangeTheme)
                                          ? AppColor.lightModePrim
                                          : AppColor.darkModePrim),
                                ),
                              ),
                              minimumSize: MaterialStateProperty.all<Size>(Size(276.w, 50.h)),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          isLoading: _isLoadingImages,
          // additional parameters
          opacity: 0.5,
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
          progressIndicator: CircularProgressIndicator(
            color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
          ),
        ),
      ),
    );
  }
}
