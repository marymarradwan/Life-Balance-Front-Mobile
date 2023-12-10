import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/Notifications.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/model/goal_item.dart';
import 'package:life_balancing/model/image_item.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/view/PopUpInfo.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../Util/ScreenHelper.dart';
import 'Premium.dart';
import 'login.dart';
import 'main_screen.dart';

class CreateGoalPage extends StatefulWidget {
  final String HeaderName;
  final String ButtonName;
  final int goal_id;
  final GoalItem item;

  const CreateGoalPage({Key key, this.HeaderName, this.ButtonName, this.item, this.goal_id}) : super(key: key);

  @override
  _CreateGoalPage createState() => _CreateGoalPage();
}

class _CreateGoalPage extends State<CreateGoalPage> {
  TextEditingController name_Controler = new TextEditingController();

  TextEditingController Des_Controler = new TextEditingController();

  TextEditingController Duration_Control = new TextEditingController();
  TextEditingController task_name_Controler = new TextEditingController();
  TextEditingController final_date_Controler = new TextEditingController();

  TextEditingController time_of_the_goal_Controler = new TextEditingController();
  TextEditingController Reminder_Controler = new TextEditingController();
  TextEditingController timeinput = new TextEditingController();
  TextEditingController dateinput = new TextEditingController();
  String name_Goals = " ";
  String Description = " ";
  int Section_id;
  String image_Name;
  String imageSelected;
  // Map<int, String> _Images = {};
  String section_Title;
  String time_of_The_goals = "";
  String initDate = '';
  TimeOfDay Reminder;
  DateTime final_Date;
  int duration = 0;
  int points;
  List<bool> Categry = [false, false, false, false, false, false];
  List<bool> isSelected_reward = [false, false, false, false];
  List<Tasks> tasks = [];
  List<TaskWidget> tasksWidget = [];

  //List<Tasks> edittasks = [];

  GoalItem _goal;
  bool DeletedTask = false;

  // List<String> task_title=[];
  DateTime selectedDate = DateTime.now();

  int tasknumber = 0;

  // bool _isCreat_Update_Goals = false;

  //bool error = false;

//  bool is_updating = false;
  bool _isLoadingImages = true;
  bool isInit = false;
  List<ImageItem> _Images = [];
  List<String> results = [];
  List<bool> select = [];
  String image;

  //validation Goals
  bool _goal_name_Validation = false,
      _des_validation = false,
      _final_date_validation = false,
      _duration_validation = false,
      _time_of_the_goal_validation = false,
      _reminder_validation = false,
      _button_validation = false;
  bool isValid = false;

  Future _deleteTask(id, Tasks task) async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingImages = true;
      });
      var res = await updatetask_delete("api/task", id, token);
      print(res.statusCode);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        setState(() {
          tasks.remove(task);
          print(tasksWidget.length);
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

  Future _UpdateTitleAndFinishedTask(id, title, isfinished) async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingImages = true;
      });
      var res = await updatetask_title("api/task", id, title, isfinished, token);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        setState(() {
          /*tasks.remove(task);
          edittasks.remove(task);*/
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
  void dispose() {
    name_Controler.dispose();
    Des_Controler.dispose();
    Duration_Control.dispose();
    task_name_Controler.dispose();
    final_date_Controler.dispose();
    time_of_the_goal_Controler.dispose();
    Reminder_Controler.dispose();
    timeinput.dispose();
    dateinput.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (!isInit) {
      _simulateLoadImage();
    }
    isInit = true;
    if (widget.HeaderName.compareTo("Edit Goal") == 0) {
      name_Controler = new TextEditingController(text: widget.item.goal_Name);
      name_Goals = widget.item.goal_Name;
      Des_Controler == new TextEditingController(text: widget.item.Description);
      Description = widget.item.Description;
      imageSelected = widget.item.image_Path;

      File file = new File(imageSelected);
      image_Name = file.path.split('/').last;

      points = widget.item.points;
      //print("image Selected*************************************************************");
      //print(imageSelected);
      Section_id = widget.item.Section_id;
      Categry[Section_id - 1] = true;
      tasks = widget.item.tasks;
      Future.delayed(Duration.zero, () {
        tasks.forEach((element) {
          tasksWidget.add(TaskWidget(element, CreatTask(element)));
        });
      });
      initDate = DateFormat('yyyy-MM-dd').format(widget.item.final_date);
      final_date_Controler = new TextEditingController(text: initDate);
      duration = widget.item.Duration ?? GoalItem.Calculate_duration(widget.item.final_date);
      final_Date = widget.item.final_date;
      Duration_Control = new TextEditingController(text: duration.toString());
      time_of_The_goals = widget.item.Time_of_the_goal;
      time_of_the_goal_Controler = new TextEditingController(text: widget.item.Time_of_the_goal);
      Reminder = widget.item.Reminder ?? null;
      Reminder_Controler = new TextEditingController(text: Reminder.hour.toString() + ":" + Reminder.minute.toString());
    }

    tasknumber = tasks.length;
    super.initState();
  }

  Future _simulateLoadImage() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);

      var res = await getData("api/images", token);
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
            _isLoadingImages = false;
          });
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

  Future _updategoal(int id, GoalItem item) async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingImages = true;
      });
      print(item.image_Path);
      var res = await updategoals("api/goal", id, item, token);
      print(res.statusCode);
      print("*************************");
      // print(json.decode(res.body)['data']);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        Map<String, dynamic> goalUpdated = json.decode(res.body)['data'];
        /* Tasks task = new Tasks(
          tasks['id'],
          tasks['goal_id'],
          tasks['is_Finished'],
          tasks['title'],
        );*/
        //   print(tasks.length);
        if (mounted)
          setState(() {
            // item.is_Finished = !item.is_Finished;
            //item = task;

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

  Future _CreateTask(Tasks item) async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingImages = true;
      });
      var res = await CreateTask("api/task", item, token);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        Map<String, dynamic> goalUpdated = json.decode(res.body)['data'];
        setState(() {
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

  Future _CreatGoals(GoalItem item) async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingImages = true;
      });
      var res = await createGoal("api/goal", item, token);

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
        if (mounted) {
          setState(() {
            _isLoadingImages = false;
          });
        }
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(
                      TabId: 3,
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

  Widget Circle_Button(int point, bool enable) {
    if (enable) points = point;
    return Container(
      //changed
      width: 36.h,
      height: 36.h,
      child: TextButton(
        onPressed: () {},
        child: Text(
          point.toString(),
          style: TextStyle(
              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
              fontSize: 11.sp,
              fontFamily: "Subjective"),
          textAlign: TextAlign.center,
        ),
        style: ElevatedButton.styleFrom(
          //tapTargetSize: MaterialTapTargetSize.values(0),
          shape: CircleBorder(),
          // padding: EdgeInsets.all(10.w),
          primary: enable
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
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  fontFamily: "Subjective"),
            ),
            PopUpInfo(
              message: "Set a Reminder for your goal",
              child: Material(
                color: Colors.transparent,
                //borderRadius: BorderRadius.circular(25.0),
                child: InkWell(
                  child: Icon(
                    Icons.info_outline,
                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  ),
                  /*onTap: () {
                    FocusScope.of(context).unfocus();
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
                      onSurface:
                          CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
                      background: CashHelper.getData(key: ChangeTheme)
                          ? AppColor.lightModePrim
                          : AppColor.darkModePrim, // body text color
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        primary: CashHelper.getData(key: ChangeTheme)
                            ? AppColor.LightModeSecTextField
                            : AppColor.darkModeSeco, // button text color
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
            if (pickedTime != null) {
              DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
              //converting to DateTime so that we can further format on different pattern.
              String formattedTime = DateFormat('HH:mm ').format(parsedTime);
              //DateFormat() is from intl package, you can format the time on any pattern you need.

              setState(() {
                Reminder_Controler.text = formattedTime;
                //Reminder=DateTime.parse(formattedString)formattedTime;//set the value of text field.
              });
            }
          },

          controller: Reminder_Controler,
          readOnly: true,
          textAlign: TextAlign.left,
          //keyboardType: TextInputType.number,

          style: TextStyle(fontSize: 12.sp, color: AppColor.kTextColor, fontFamily: "Subjective"),
          showCursor: false,
          decoration: InputDecoration(
            filled: true,
            errorText: _reminder_validation //&& error
                ? 'Place Enter Reminder'.tr()
                : null,
            fillColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
            contentPadding: EdgeInsets.only(left: 14.0.w, bottom: 8.0.h, top: 8.0.w),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
            ),
          ),
        ),
      ],
    );
  }

  Widget CreatTask(Tasks task) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      //color: Colors.black45,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: task.is_Finished ? AppColor.mainBtn : AppColor.darkModePrim),
            child: Padding(
              padding: EdgeInsets.all(6.0.w),
              child: task.is_Finished
                  ? Icon(
                      Icons.check,
                      size: 20.r,
                      color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                    )
                  : Icon(
                      Icons.check_box_outline_blank,
                      size: 20.r,
                      color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                    ),
            ),
          ),
          SizedBox(
            width: 25.w,
          ),
          SizedBox(
            width: 175.w,
            child: TextField(
              controller: task.title,
              maxLines: 1,
              style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                fontFamily: "Subjective",
              ),

              /*onSubmitted: (value) {

                                                      },*/
            ),
          ),
          SizedBox(
            width: 30.w,
          ),
          /* IconButton(
            icon: Icon(
              Icons.edit,
              size: 24.r,
              color: AppColor.mainBtn,
            ),
            onPressed: () {
              setState(() {
                task_name_Controler =
                    new TextEditingController(text: task.title);
                showDialog(
                    context: context,
                    builder: (BuildContext context) => new AlertDialog(
                          backgroundColor: AppColor.darkModePrim,
                          scrollable: true,
                          title: const Text('Edit Task '),
                          titleTextStyle: TextStyle(
                            color: AppColor.kTextColor,
                            fontFamily: "Subjective",
                          ),
                          content: Container(
                            color: AppColor.darkModeSeco,
                            child: new Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  new TextField(
                                    controller: task_name_Controler,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: AppColor.kTextColor,
                                      fontFamily: "Subjective",
                                    ),

                                    */ /*onSubmitted: (value) {

                                                  },*/ /*
                                  )
                                ]),
                          ),
                          actions: <Widget>[
                            new TextButton(
                              onPressed: () {
                                setState(() {
                                  //add task id and goal id
                                  if (task_name_Controler.text != "") {
                                    _UpdateTitleAndFinishedTask(
                                        task.id,
                                        task_name_Controler.text,
                                        task.is_Finished);
                                    task.title = task_name_Controler.text;
                                    tasknumber = tasks.length;
                                  }
                                  */ /*if (widget.HeaderName
                                  .compareTo(
                                  "Edit Goal") ==
                                  0) {
                                Tasks t = new Tasks(
                                    1,
                                    widget.goal_id,
                                    false,
                                    task_name_Controler
                                        .text);
                                //replace to update goal button
                                //_CreateTask(t);
                                edittasks.add(t);

                                tasknumber = tasks.length;
                              }*/ /*
                                });
                                Navigator.of(context).pop();
                                task_name_Controler.text = "";
                              },
                              //textColor: Theme.of(context).primaryColor,
                              child: const Text(
                                'update',
                                style: TextStyle(
                                  color: AppColor.kTextColor,
                                  fontFamily: "Subjective",
                                ),
                              ),
                            ),
                            new TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                task_name_Controler.text = "";
                              },
                              //textColor: Theme.of(context).primaryColor,
                              child: const Text(
                                'back',
                                style: TextStyle(
                                  color: AppColor.kTextColor,
                                  fontFamily: "Subjective",
                                ),
                              ),
                            ),
                          ],
                        ));
              });
            },
          ),*/
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
              size: 24.r,
            ),
            onPressed: () {
              /* if (widget.HeaderName.compareTo("New Goal") == 0) {
                setState(() {
                  tasks.remove(task);
                });
              } else*/ /*if (widget.HeaderName.compareTo("Edit Goal") == 0) {*/
              setState(() {
                if (task.id != null) {
                  showDialog(
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:
                              CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                          scrollable: true,
                          title: const Text('Delete Task'),
                          titleTextStyle: TextStyle(
                            color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                            fontFamily: "Subjective",
                          ),
                          content: Text(
                            "Do You Want To Delete This Task !!".tr(),
                            style: TextStyle(
                              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                              fontSize: 15.sp,
                              fontFamily: "Subjective",
                            ),
                          ),
                          actions: <Widget>[
                            new TextButton(
                              onPressed: () {
                                setState(() {
                                  //add task id and goal id
                                  DeletedTask = true;
                                  tasksWidget.removeWhere((element) => element.task == task);

                                  _deleteTask(task.id, task);

                                  Navigator.of(context).pop();
                                  //task_name_Controler.text = "";
                                });
                              },
                              //textColor: Theme.of(context).primaryColor,
                              child: Text(
                                'OK'.tr(),
                                style: TextStyle(
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                  fontFamily: "Subjective",
                                ),
                              ),
                            ),
                            new TextButton(
                              onPressed: () {
                                //add task id and goal id
                                DeletedTask = false;
                                Navigator.of(context).pop();
                                //task_name_Controler.text = "";
                              },
                              //textColor: Theme.of(context).primaryColor,
                              child: Text(
                                'back'.tr(),
                                style: TextStyle(
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                  fontFamily: "Subjective",
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      context: context);
                } else if (task.id == null) {
                  showDialog(
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:
                              CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                          scrollable: true,
                          title: Text('Delete Task'.tr()),
                          titleTextStyle: TextStyle(
                            color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                            fontFamily: "Subjective",
                          ),
                          content: Text(
                            "Do You Want To Delete This Task !!".tr(),
                            style: TextStyle(
                              color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                              fontSize: 15.sp,
                              fontFamily: "Subjective",
                            ),
                          ),
                          actions: <Widget>[
                            new TextButton(
                              onPressed: () {
                                setState(() {
                                  tasksWidget.removeWhere((element) => element.task == task);
                                  tasks.remove(task);

                                  Navigator.of(context).pop();
                                  //task_name_Controler.text = "";
                                });
                              },
                              //textColor: Theme.of(context).primaryColor,
                              child: Text(
                                'OK'.tr(),
                                style: TextStyle(
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                  fontFamily: "Subjective",
                                ),
                              ),
                            ),
                            new TextButton(
                              onPressed: () {
                                //add task id and goal id
                                DeletedTask = false;
                                Navigator.of(context).pop();
                                //task_name_Controler.text = "";
                              },
                              //textColor: Theme.of(context).primaryColor,
                              child: Text(
                                'back'.tr(),
                                style: TextStyle(
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                  fontFamily: "Subjective",
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      context: context);
                }
              });
              //}
            },
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
        body: LoadingOverlay(
          isLoading: _isLoadingImages,
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
                child: Container(
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //SizedBox(height: 400),
                      Text(
                        widget.HeaderName,
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
                            //padding: EdgeInsets.all(30.w),
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
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Subjective",
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
                                        fit: BoxFit.contain,
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
                                        setState(() {
                                          FocusScope.of(context).unfocus();

                                          showDialog(
                                              context: context, builder: (BuildContext context) => buildImageDialog());
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
                                        FocusScope.of(context).unfocus();

                                        setState(() {
                                          showDialog(
                                              context: context, builder: (BuildContext context) => buildImageDialog());
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
                        height: 10.h,
                      ),
                      //first Section
                      Container(
                        padding: EdgeInsets.all(10.0.w),
                        //width: 336.0,
                        //height: 180.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: CashHelper.getData(key: ChangeTheme)
                              ? AppColor.LightModeSecTextField
                              : AppColor.darkModeSeco,
                          boxShadow: [
                            /*BoxShadow(
                              color: AppColor.darkModeSeco.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: Offset(0, 3), // changes position of shadow
                            ),*/
                          ],
                        ),

                        child: Column(
                          children: [
                            Text(
                              "What is your Goal".tr(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                fontFamily: "Subjective",
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            TextField(
                              //scrollPadding: EdgeInsets.all(50),
                              //textAlignVertical: TextAlignVertical.bottom,
                              //initialValue: widget.item.goal_Name,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                fontFamily: "Subjective",
                              ),
                              showCursor: true,
                              controller: name_Controler,

                              onChanged: (value) {
                                name_Goals = value;
                                //name_Controler.text=value;
                              },

                              cursorColor:
                                  CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                              decoration: InputDecoration(
                                filled: true,
                                errorText: _goal_name_Validation //&& error
                                    ? 'Place Enter Name'
                                    : null,
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
                                        : AppColor.darkModePrim,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              "Add Description(Optional)".tr(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                fontFamily: "Subjective",
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            TextField(
                              //scrollPadding: EdgeInsets.all(50),
                              //textAlignVertical: TextAlignVertical.bottom,
                              //initialValue: widget.item.Description,
                              textAlign: TextAlign.left,
                              //maxLines: 6,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                fontFamily: "Subjective",
                              ),
                              showCursor: true,
                              controller: Des_Controler,
                              //enabled: desc_enabl,

                              /* onSubmitted: (value) {
                                Description = value;
                              },*/
                              /*onEditingComplete: (){
                                setState(() {
                                  desc_enabl=false;
                                  print("editing Complet");
                                });
                              },*/
                              onChanged: (value) {
                                Description = value;
                                //Des_Controler.text=value;
                              },
                              /*onTap: (){
                                setState(() {
                                  desc_enabl=true;
                                  print("onTap");
                                });
                              },*/
                              /*onEditingComplete: (){
                                setState(() {
                                  name_Habits = text.text;
                                });
                              },*/

                              cursorColor:
                                  CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                              decoration: InputDecoration(
                                filled: true,
                                errorText: _des_validation //&& error
                                    ? 'Place Add Description'.tr()
                                    : null,
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
                                        : AppColor.darkModePrim,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      //Second Section
                      Container(
                        padding: EdgeInsets.all(10),
                        //width: 336.0,
                        //height: 180.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: CashHelper.getData(key: ChangeTheme)
                              ? AppColor.LightModeSecTextField
                              : AppColor.darkModeSeco,
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Select Cateogry".tr(),
                              style: TextStyle(
                                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                fontSize: 12.sp,
                                fontFamily: "Subjective",
                              ),
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
                                    section_Title = "Social".tr();
                                    Section_id = 1;
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
                                    section_Title = "Career".tr();
                                    Section_id = 2;
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
                                    Section_id = 3;
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
                                    section_Title = "Spirit";
                                    Section_id = 4;
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
                                    section_Title = "Health".tr();
                                    Section_id = 5;
                                    /*if(_Cateogry_validiate)
                                        _Cateogry_validiate=false;

                                      _Cateogry_validiate=true;*/
                                  });
                                }, 4),
                                SizedBox(width: 4.w),
                                Button_Category("assets/images/emotion.png", "Emotions".tr(), AppColor.emotionsSections,
                                    () {
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
                                    Section_id = 6;
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
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      //third Section
                      Container(
                        padding: EdgeInsets.all(15.0.w),
                        //width: 336.0,
                        //height: 180.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            color: CashHelper.getData(key: ChangeTheme)
                                ? AppColor.LightModeSecTextField
                                : AppColor.darkModeSeco),
                        child: Column(
                          children: [
                            ListView.builder(
                              itemCount: tasksWidget.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return tasksWidget[index].child;
                              },
                            ),
                            Divider(),
                            //add task button
                            InkWell(
                              onTap: () {
                                setState(() {
                                  print("88888888888888888888888888888888888888");
                                  //FocusScope.of(context).unfocus();
                                  /*showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          new AlertDialog(
                                            backgroundColor:
                                                AppColor.darkModePrim,
                                            scrollable: true,
                                            title: const Text('Add Task'),
                                            titleTextStyle: TextStyle(
                                              color: AppColor.kTextColor,
                                              fontFamily: "Subjective",
                                            ),
                                            content: Container(
                                              width: 250.w,
                                              //height: MediaQuery.of(context).size.height/2,
                                              color: AppColor.darkModeSeco,
                                              child: new Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    new TextField(
                                                      controller:
                                                          task_name_Controler,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color:
                                                            AppColor.kTextColor,
                                                        fontFamily:
                                                            "Subjective",
                                                      ),

                                                      */ /**/ /*onSubmitted: (value) {

                                                        },*/ /**/ /*
                                                    )
                                                  ]),
                                            ),
                                            actions: <Widget>[
                                              new TextButton(
                                                onPressed: () {*/ /*
                                                  setState(() {*/
                                  //add task id and goal id
                                  if (widget.HeaderName.compareTo("New Goal") == 0) {
                                    Tasks task = new Tasks(null, null, false, new TextEditingController());
                                    int index = tasks.length;
                                    print("index : $index");
                                    tasks.add(task);
                                    tasksWidget.add(TaskWidget(task, CreatTask(task)));
                                    tasknumber = tasks.length;
                                  } else if (widget.HeaderName.compareTo("Edit Goal") == 0) {
                                    Tasks t = new Tasks(null, widget.goal_id, false, task_name_Controler);
                                    tasks.add(t);
                                    int index = tasks.length;
                                    print("index : $index");
                                    tasksWidget.add(TaskWidget(t, CreatTask(t)));
                                    /*tasknumber = tasks.length;*/

                                    tasknumber = tasks.length;
                                  }
                                });
                                // Navigator.of(context).pop();
                                task_name_Controler.text = "";
                                /* },
                                                //textColor: Theme.of(context).primaryColor,
                                                child: const Text(
                                                  'Add',
                                                  style: TextStyle(
                                                    color: AppColor.kTextColor,
                                                    fontFamily: "Subjective",
                                                  ),
                                                ),
                                              ),
                                              new TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  task_name_Controler.text = "";
                                                },
                                                //textColor: Theme.of(context).primaryColor,
                                                child: const Text(
                                                  'back',
                                                  style: TextStyle(
                                                    color: AppColor.kTextColor,
                                                    fontFamily: "Subjective",
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ));
                                });*/
                              },
                              child: Container(
                                color: Colors.transparent,
                                //padding: EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Add A Step".tr(),
                                      style: TextStyle(
                                          color:
                                              CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                          fontFamily: "Subjective",
                                          fontSize: 10.sp),
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Icon(
                                      Iconsax.add_circle5,
                                      size: 18.r,
                                      color: CashHelper.getData(key: ChangeTheme)
                                          ? AppColor.mainBtnLightMode
                                          : AppColor.mainBtn,
                                    ),
                                  ],
                                ),
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
                        //height: 180.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            color: CashHelper.getData(key: ChangeTheme)
                                ? AppColor.LightModeSecTextField
                                : AppColor.darkModeSeco),

                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Final Date of The Goal".tr(),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                    fontFamily: "Subjective",
                                  ),
                                ),
                                PopUpInfo(
                                  message:
                                      "This is the final date to achieve your goal, you will be rewarded 0 points if you exceeded your final due date"
                                          .tr(),
                                  child: Material(
                                    color: Colors.transparent,
                                    //borderRadius: BorderRadius.circular(25.0),
                                    child: InkWell(
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 22.r,
                                        color:
                                            CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                      ),
                                      /*onTap: () {
                                        FocusScope.of(context).unfocus();
                                        */ /* showDialog(
                                            useSafeArea: true,
                                            context: context,
                                            builder: (BuildContext context) =>
                                                PopUpInfo(
                                                  InfoText:
                                                      "This is the final date to achieve your goal, you will be rewarded 0 points if you exceeded your final due date",
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
                            TextField(
                              //scrollPadding: EdgeInsets.all(50),
                              //textAlignVertical: TextAlignVertical.bottom,
                              //initialValue: initDate??final_date_Controler.text,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                fontFamily: "Subjective",
                              ),
                              //showCursor: true,
                              //controller: final_date_Controler,

                              onTap: () async {
                                DateTime pickedTime = await showDatePicker(
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: CashHelper.getData(key: ChangeTheme)
                                                ? AppColor.LightModeSecTextField
                                                : AppColor.darkModeSeco,
                                            // header background color
                                            onPrimary: CashHelper.getData(key: ChangeTheme)
                                                ? Colors.black
                                                : AppColor.kTextColor,
                                            // header text color
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
                                    initialDate: selectedDate,
                                    context: context,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2101));
                                // final_Date=pickedTime;
                                //print(Reminder);
                                if (pickedTime != null) {
                                  DateFormat formatter = DateFormat('yyyy-MM-dd');
                                  String formatted = formatter.format(pickedTime);
                                  /*print(pickedTime.format(context)); //output 10:51 PM
                                  DateTime parsedTime =
                                  DateFormat.jm().parse(pickedTime.format(context).toString());*/
                                  //converting to DateTime so that we can further format on different pattern.
                                  //print(parsedTime); //output 1970-01-01 22:53:00.000
                                  //String formattedTime = DateFormat('HH:mm a').format(formatter);
                                  //(formattedTime); //output 14:59:00
                                  //DateFormat() is from intl package, you can format the time on any pattern you need.

                                  setState(() {
                                    final_date_Controler.text = formatted;
                                    final_Date = pickedTime;
                                    duration = GoalItem.Calculate_duration(pickedTime);
                                    Duration_Control.text = duration.toString();

                                    //Reminder=DateTime.parse(formattedString)formattedTime;//set the value of text field.
                                  });
                                }
                              },

                              controller: final_date_Controler,
                              readOnly: true,
                              enabled: widget.HeaderName.compareTo("New Goal") == 0 ? true : false,
                              //textAlign: TextAlign.center,

                              cursorColor:
                                  CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                              decoration: InputDecoration(
                                filled: true,
                                errorText: _final_date_validation //&& error
                                    ? 'Place Enter Final Date'.tr()
                                    : null,
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
                                        : AppColor.darkModePrim,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Duration".tr(),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.LightModeSecTextField
                                        : AppColor.darkModeSeco,
                                    fontFamily: "Subjective",
                                  ),
                                ),
                                PopUpInfo(
                                  message: "This is the number of days remaining to achieve your goal".tr(),
                                  child: Material(
                                    color: Colors.transparent,
                                    //borderRadius: BorderRadius.circular(25.0),
                                    child: InkWell(
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 22.r,
                                        color: CashHelper.getData(key: ChangeTheme)
                                            ? AppColor.LightModeSecTextField
                                            : AppColor.darkModeSeco,
                                      ),
                                      /*onTap: () {
                                        FocusScope.of(context).unfocus();
                                        */ /* showDialog(
                                            useSafeArea: true,
                                            context: context,
                                            builder: (BuildContext context) =>
                                                PopUpInfo(
                                                  InfoText:
                                                      ,
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
                            TextField(
                              //scrollPadding: EdgeInsets.all(50),
                              //textAlignVertical: TextAlignVertical.bottom,

                              textAlign: TextAlign.left,
                              //initialValue: Duration.toString(),
                              maxLines: 1,
                              enabled: false,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                fontFamily: "Subjective",
                              ),
                              showCursor: true,
                              controller: Duration_Control,

                              /*onSubmitted: (value) {
                                //add duration
                                Duration = int.parse(value);
                              },*/
                              /*onEditingComplete: (){
                                setState(() {
                                  name_Habits = text.text;
                                });
                              },*/

                              cursorColor:
                                  CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                              decoration: InputDecoration(
                                errorText: _duration_validation ? "Place Add A Tasks or Enter Final Date" : null,
                                hintText: duration != 0 ? duration.toString() : 'Number of Days...'.tr(),
                                filled: true,
                                hintStyle: TextStyle(
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                  fontSize: 10.sp,
                                  fontFamily: "Subjective",
                                ),
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
                                        : AppColor.darkModePrim,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
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
                                  "This Goal Awards".tr(),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                    fontFamily: "Subjective",
                                  ),
                                ),
                                PopUpInfo(
                                  message:
                                      "Points are awarded based on the duration to the due date and number of tasks to achieve your goal"
                                          .tr(),
                                  child: Material(
                                    color: Colors.transparent,
                                    //borderRadius: BorderRadius.circular(25.0),
                                    child: InkWell(
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 22.r,
                                        color:
                                            CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                      ),
                                      /* onTap: () {
                                        FocusScope.of(context).unfocus();
                                        */ /* showDialog(
                                            useSafeArea: true,
                                            context: context,
                                            builder: (BuildContext context) =>
                                                PopUpInfo(
                                                  InfoText:
                                                      "Points are awarded based on the duration to the due date and number of tasks to achieve your goal",
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
                            build_Points_Buttons(duration, tasknumber),
                            SizedBox(
                              height: 5.h,
                            ),
                            /*Text(
                              "Time Of The Goal",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColor.kTextColor,
                                fontFamily: "Subjective",
                              ),
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
                                color: AppColor.kTextColor,
                                fontFamily: "Subjective",
                              ),
                              //initialValue: widget.item.Time_of_the_goal??'',
                              showCursor: true,
                              //controller: time_of_the_goal_Controler,

                              onChanged: (valus) {
                                time_of_The_goals = valus;
                                //time_of_The_goals
                                // error =true;
                              },
                              cursorColor: AppColor.mainBtn,
                              decoration: InputDecoration(
                                filled: true,
                                errorText:
                                    _time_of_the_goal_validation //&& error
                                        ? 'Place Enter Time Of The Goal'
                                        : null,
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
                                  borderSide:
                                      BorderSide(color: AppColor.darkModePrim),
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
                            /* Row(
                              children: [
                                Text(
                                  "Add Another Reminder",
                                  style: TextStyle(color: AppColor.kTextColor),
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
                        height: 20.h,
                      ),
                      ButtonTheme(
                        minWidth: 200.0.w,
                        // height: MediaQuery.of(context).size.height/6.4,

                        child: ElevatedButton(
                          child: isValid
                              ? CircularProgressIndicator(
                                  color: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.lightModePrim
                                      : AppColor.darkModePrim,
                                )
                              : Text(
                                  widget.ButtonName,
                                  style: TextStyle(
                                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : Colors.white,
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Subjective",
                                  ),
                                ),
                          onPressed: () async {
                            /* setState(
                              () async {*/
                            if (name_Goals == null || name_Goals.compareTo("") == 0 || name_Goals.compareTo(" ") == 0) {
                              print("name Habits$name_Goals");
                              setState(() {
                                _goal_name_Validation = true;
                              });
                            } else
                              setState(() {
                                _goal_name_Validation = false;
                              });
                            /*if (Description == null ||
                                    Description.compareTo("") == 0 ||
                                    Description.compareTo(" ") == 0) {
                                  print(" time_Remaining$Description");
                                  setState(() {
                                    _des_validation = true;
                                  });
                                } else
                                  setState(() {
                                    _des_validation = false;
                                  });*/
                            if (final_Date == null) {
                              print("time_of_The_Habits$final_Date");
                              setState(() {
                                _final_date_validation = true;
                              });
                            } else
                              setState(() {
                                _final_date_validation = false;
                              });
                            if (duration == null || duration == 0) {
                              print("Reminder$Reminder");
                              setState(() {
                                _duration_validation = true;
                              });
                            } else
                              setState(() {
                                _duration_validation = false;
                              });
                            /*if (time_of_The_goals == null ||
                                    time_of_The_goals.compareTo("") == 0 ||
                                    time_of_The_goals.compareTo(" ") == 0) {
                                  print("Reminder$time_of_The_goals");
                                  setState(() {
                                    _time_of_the_goal_validation = true;
                                  });
                                } else
                                  setState(() {
                                    _time_of_the_goal_validation = false;
                                  });*/
                            /*if (Reminder == null) {
                                  print("Reminder$Reminder");
                                  setState(() {
                                    _reminder_validation = true;
                                  });
                                } else
                                  setState(() {
                                    _reminder_validation = false;
                                  });*/
                            if (imageSelected == null) {
                              Toast.show(
                                'Place Select Image'.tr(),
                                context,
                                backgroundColor: Colors.red,
                                gravity: Toast.BOTTOM,
                                duration: Toast.LENGTH_LONG,
                              );
                              _button_validation = true;
                            } else if (Section_id == null) {
                              print("section_id$Section_id");

                              Toast.show(
                                'Place Select Category'.tr(),
                                context,
                                backgroundColor: Colors.red,
                                gravity: Toast.BOTTOM,
                                duration: Toast.LENGTH_LONG,
                              );
                              _button_validation = true;
                            } else if (tasks.length == 0) {
                              Toast.show(
                                'Place Add At Least One Task'.tr(),
                                context,
                                backgroundColor: Colors.red,
                                gravity: Toast.BOTTOM,
                                duration: Toast.LENGTH_LONG,
                              );
                              _button_validation = true;
                            } else {
                              _button_validation = false;
                            }
                            if (widget.HeaderName.compareTo("New Goal") == 0) {
                              if (!_goal_name_Validation &&
                                      !_button_validation &&
                                      // !_des_validation &&
                                      !_final_date_validation &&
                                      !_duration_validation
                                  // !_time_of_the_goal_validation &&
                                  // !_reminder_validation
                                  ) {
                                GoalItem item = new GoalItem(
                                  1,
                                  Section_id,
                                  image_Name,
                                  name_Goals,
                                  tasks,
                                  Reminder,
                                  points,
                                  duration,
                                  final_Date,
                                  time_of_The_goals,
                                  Description,
                                );
                                // tasks.forEach((element) {task_title.add(element.title);});
                                setState(() {
                                  isValid = true;
                                });
                                await Future.delayed(Duration(seconds: 2));
                                setState(() {
                                  isValid = false;
                                });
                                _CreatGoals(item);
                                Goals.add_goals(item);
                                DateTime newDate = DateTime.now();
                                DateTime formatedDate = new DateTime(
                                    newDate.year,
                                    newDate.month,
                                    newDate.day,
                                    Reminder != null ? Reminder.hour : null,
                                    Reminder != null ? Reminder.minute : null,
                                    newDate.second,
                                    newDate.millisecond,
                                    newDate.microsecond);
                                Notifications.send(formatedDate, name_Goals, 'Let\'s go');
                                if (duration > 1) {
                                  formatedDate = new DateTime(
                                      newDate.year,
                                      newDate.month,
                                      newDate.day + (duration - 1),
                                      Reminder != null ? Reminder.hour : null,
                                      Reminder != null ? Reminder.minute : null,
                                      newDate.second,
                                      newDate.millisecond,
                                      newDate.microsecond);
                                  Notifications.send(formatedDate, name_Goals, 'Don\'t forget your Goal');
                                }
                              }
                            } else if (widget.HeaderName.compareTo("Edit Goal") == 0) {
                              if (!_goal_name_Validation &&
                                      !_button_validation &&
                                      //!_des_validation &&
                                      !_final_date_validation &&
                                      !_duration_validation
                                  // /!_time_of_the_goal_validation &&
                                  //    !_reminder_validation
                                  ) {
                                widget.item.image_Path = image_Name;
                                widget.item.goal_Name = name_Controler.text;
                                widget.item.Description = Description;
                                widget.item.tasks = tasks;
                                widget.item.final_date = DateTime.parse(final_date_Controler.text);
                                widget.item.Duration = int.parse(Duration_Control.text);
                                widget.item.points = points;
                                widget.item.Time_of_the_goal = time_of_the_goal_Controler.text;
                                TimeOfDay time = TimeOfDay(
                                    hour: int.parse(Reminder_Controler.text.split(":")[0]),
                                    minute: int.parse(Reminder_Controler.text.split(":")[1]));

                                widget.item.Reminder = time;
                                for (int i = 0; i < tasks.length; i++) {
                                  if (tasks[i].id == null) {
                                    print(i);
                                    print(tasks[i].id);
                                    print(tasks[i]);
                                    _CreateTask(tasks[i]);
                                  }
                                }
                                setState(() {
                                  isValid = true;
                                });
                                await Future.delayed(Duration(seconds: 2));
                                setState(() {
                                  isValid = false;
                                });
                                _updategoal(widget.goal_id, widget.item);
                                if (!_isLoadingImages)
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainScreen(
                                                TabId: 3,
                                              )));
                              }
                            }
                          },
                          /* );
                          },*/
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.r),
                                side: BorderSide(
                                  color: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.lightModePrim
                                      : AppColor.darkModePrim,
                                ),
                              ),
                            ),
                            minimumSize: MaterialStateProperty.all<Size>(Size(277.w, 50.h)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      //four Section
                    ],
                  )),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget build_Points_Buttons(int Duration, int TaskNumber) {
    int newpoints = GoalItem.Calculate_points(Duration, TaskNumber);
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
              style: TextStyle(
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  fontFamily: "Subjective",
                  fontSize: 10.sp),
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
              style: TextStyle(
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  fontFamily: "Subjective",
                  fontSize: 10.sp),
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
              "Hard".tr(),
              style: TextStyle(
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  fontFamily: "Subjective",
                  fontSize: 10.sp),
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
              "Expert".tr(),
              style: TextStyle(
                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                  fontFamily: "Subjective",
                  fontSize: 10.sp),
            )
          ],
        ),
      ],
    );
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
                        CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0.r),
                        side: BorderSide(
                          color: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
                        ),
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
                                : AppColor.darkModeSeco),
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
          width: 1.sw,
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
}
