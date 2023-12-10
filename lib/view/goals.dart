import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/appqoutes.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/model/activite_Item.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/shared/empty_error_Image.dart';
import 'package:life_balancing/shared/floating_action_button.dart';
import 'package:life_balancing/shared/header.dart';
import 'package:life_balancing/view/CreateGoal.dart';
import 'package:life_balancing/view/popup_badge.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:toast/toast.dart';

import '../Util/ScreenHelper.dart';
import '../model/goal_item.dart';
import 'Popup_item.dart';
import 'login.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key key}) : super(key: key);
  @override
  _GoalsPage createState() => _GoalsPage();
}

class _GoalsPage extends State<GoalsPage> {
  //TextEditingController text = new TextEditingController();
  List<GoalItem> _goals;
  bool press_X = true;

  //final String image_Name = "assets/images/temp@2x.png";
  final String advice = "The great things always happen outside of your comfort zone";
  String qouts;
  bool edit = false;
  bool _isLoading = true;
  bool _isLoadingtask = false;
  bool _isInit = false;
  String _image = "";
  String _name = "";
  bool is_Win_Badge = false;
  bool is_Win_Reward = false;
  int badge_id;

  TextEditingController text = new TextEditingController();
  String Note;
  int mood_Id;
  List<Emoje> _emoje = [];
  var _isLoadingMood = true;
  var _isLoadingUpdate = false;
  bool isValid = false;

  //validation mood
  bool _button_validation = false, _notes_validation = false;

  // var _isLoading = true, _isInit = false;

  SlidableController slidableController;
  Color _fabColor = CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn;
  Animation<double> _rotationAnimation;
  bool isError = false;
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  Future _fetchMood() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);

      var res = await getData("api/mood", token);
      // print(json.decode(res.body)['data'][0]["id"]);
      print(res.statusCode);
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

  Future _deleteGoal(id, GoalItem item) async {
    Navigator.of(context).pop();
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingtask = true;
      });
      var res = await delete_goal("api/goal", id, token);
      print(res.statusCode);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        setState(() {
          _goals.remove(item);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Deleted ".tr(),
              style: TextStyle(
                color: CashHelper.getData(key: ChangeTheme) ? Colors.white : AppColor.kTextColor,
                fontFamily: "Subjective",
              ),
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 1),
            backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
          ));

          _isLoadingtask = false;
        });
      } else {
        setState(() {
          _isLoadingtask = false;
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

  ConfettiController _controllerCenter;

  Future _is_Complate_Goal(GoalItem item) {
    SharedPreferences.getInstance().then((prefs) async {
      // String image = prefs.getString('image');
      // String name = prefs.getString('name');
      // setState(() {
      //   _name = name;
      //   _image = image;
      // });
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingtask = true;
      });
      var res = await canCompleteGoal("api/goals/complete", item.id, token);
      // print(json.decode(res.body)['data']);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        Map<String, dynamic> goal = json.decode(res.body)['data'];
        is_Win_Badge = json.decode(res.body)["badge"]["isOpenNewBadge"];
        is_Win_Reward = json.decode(res.body)["reword"]["isOpenNewReword"];
        if (is_Win_Badge) {
          badge_id = json.decode(res.body)["badge"]["badgeId"];
        }
        setState(() {
          item.Complete_Goal = goal["is_completed"];
        });
        _goals.sort((a, b) {
          if (a.Complete_Goal) {
            return 1;
          }
          return -1;
        });
        setState(() {
          final List<Emoje> mode_Active1 =
              List.generate(6, (index) => new Emoje(index, "https://ai-gym.club/uploads/angel.gif", "Mood", false));

          showDialog(
            useSafeArea: true,
            context: context,
            builder: (BuildContext context) => PopUpItem(
              context,
              PopupName: "Goals".tr(),
              emoje: _emoje,
              points: item.points,
              entity_id: item.id,
              entity_type: 1,
            ),
          ).then((_) {
            is_Win_Badge
                ? showDialog(
                    useSafeArea: true,
                    context: context,
                    builder: (BuildContext context) => PopUpBadge(
                          context,
                          badgeId: badge_id,
                          emoje: _emoje.map((item) => new Emoje.clone(item)).toList(),
                          entity_id: item.id,
                          entity_type: 3,
                        ))
                : null;
          });
        });

        /*item.is_Finished = !item.is_Finished;
        item = task;*/

        _isLoadingtask = false;

        bool isOpenNewBadge = json.decode(res.body)['isOpenNewBadge'];
        if (isOpenNewBadge) {
          // _controllerCenter.play();
          // Timer(Duration(seconds: 3), () {
          //   _controllerCenter.stop();
          // });

        }
      } else {
        String error = json.decode(res.body)["message"];
        Toast.show(
          '$error',
          context,
          backgroundColor: Colors.red,
          gravity: Toast.BOTTOM,
          duration: Toast.LENGTH_LONG,
        );
        setState(() {
          _isLoadingtask = false;
        });
      }
    });
    //
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
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 1));
    if (!_isInit) {
      _simulateLoad();
      _fetchMood();
    }
    qouts = AppQoutes.qoutesList[AppQoutes.random.nextInt(204)];
    _isInit = true;
    super.initState();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  Future _updatetask(int id, Tasks item, GoalItem goalItem) async {
    SharedPreferences.getInstance().then((prefs) async {
      // String image = prefs.getString('image');
      // String name = prefs.getString('name');
      // setState(() {
      //   _name = name;
      //   _image = image;
      // });
      String token = (prefs.getString('token') ?? null);
      setState(() {
        _isLoadingtask = true;
      });
      var res = await updatetask_finished_or_unFinished("api/tasks/finished-or-unFinished", id, token);
      // print(json.decode(res.body)['data']);
      if (res.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (res.statusCode == 200) {
        int taskCount = goalItem.tasks.length;
        int taskFinishedCount = 0;
        Map<String, dynamic> tasks = json.decode(res.body)['data'];
        Tasks task = new Tasks(
          tasks['id'],
          tasks['goal_id'],
          tasks['is_Finished'],
          new TextEditingController(text: tasks['title']),
        );
        //   print(tasks.length);
        setState(() {
          item.is_Finished = !item.is_Finished;
          item = task;

          _isLoadingtask = false;
        });
        goalItem.tasks.forEach((element) {
          if (element.is_Finished == true) {
            taskFinishedCount += 1;
          }
        });
        if (taskFinishedCount == taskCount) {
          setState(() {
            _is_Complate_Goal(goalItem);
          });
        }
      } else {
        setState(() {
          _isLoadingtask = false;
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

  bool checkDate(DateTime dt1, DateTime dt2) {
    bool res = dt2.isAfter(dt1);
    return res;
  }

  Future _simulateLoad() async {
    SharedPreferences.getInstance().then((prefs) async {
      String token = (prefs.getString('token') ?? null);
      String image = prefs.getString('image');
      String name = prefs.getString('name');
      setState(() {
        _name = name;
        _image = image;
        isError = false;
        _isLoading = true;
      });
      try {
        var res = await getData("api/goal", token);
        print(res.statusCode);
        if (res.statusCode == 401) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
        } else if (res.statusCode == 200) {
          List<dynamic> goals = json.decode(res.body)['data'];
          List<GoalItem> newgoals = [];
          for (var i = 0; i < goals.length; i++) {
            GoalItem goalItem = new GoalItem(
                goals[i]['id'],
                goals[i]['section_id'],
                goals[i]['image'],
                goals[i]['name'],
                (goals[i]['tasks'] as List<dynamic>)
                    .map((item) => Tasks(item['id'], item['goal_id'], item['is_Finished'],
                        new TextEditingController(text: item['title'])))
                    .toList(),
                TimeOfDay.now(),
                goals[i]['points'],
                goals[i]['duration'],
                //new DateFormat('yyyy/MM/dd').parse(goals[i]['final_date']) ,
                DateFormat('yyyy-MM-dd').parse(goals[i]['final_date']),
                null,
                null,
                goals[i]['is_completed']);
            newgoals.add(goalItem);
          }
          newgoals.sort((a, b) {
            if (a.Complete_Goal) {
              return 1;
            }
            return -1;
          });
          setState(() {
            _goals = newgoals;
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

  List<Widget> _buildExpandableContent(GoalItem item, int index) {
    List<Widget> columnContent = [];
    List<String> tasks = [];
    int length = item.tasks.length;
    print(length);

    for (int i = 0; i <= length; i++) {
      //length--;
      //tasks.add(key);
      //print(key + " : " + value.toString());
      columnContent.add(
        Column(
          children: [
            i < length
                ? InkWell(
                    onTap: checkDate(DateTime.now(), _goals[index].final_date) && !_goals[index].Complete_Goal
                        ? () {
                            setState(() {
                              _updatetask(item.tasks[i].id, item.tasks[i], _goals[index]);
                            });
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                "This Goals is Out Of Date".tr(),
                                style: TextStyle(
                                  color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                  fontFamily: "Subjective",
                                ),
                                textAlign: TextAlign.center,
                              ),
                              duration: Duration(seconds: 1),
                              backgroundColor: AppColor.emotionsSections,
                            ));
                          },
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.all(8.0.w),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //crossAxisAlignment: c,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: item.tasks[i].is_Finished
                                      ? CashHelper.getData(key: ChangeTheme)
                                          ? AppColor.mainBtnLightMode
                                          : AppColor.mainBtn
                                      : CashHelper.getData(key: ChangeTheme)
                                          ? AppColor.lightModePrim
                                          : AppColor.darkModePrim),
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(6.0.w),
                                        child: item.tasks[i].is_Finished
                                            ? Icon(
                                                Icons.check,
                                                size: 15.r,
                                                color: CashHelper.getData(key: ChangeTheme)
                                                    ? AppColor.lightModePrim
                                                    : AppColor.darkModePrim,
                                              )
                                            : Icon(
                                                Icons.check_box_outline_blank,
                                                size: 15.r,
                                                color: CashHelper.getData(key: ChangeTheme)
                                                    ? AppColor.lightModePrim
                                                    : AppColor.darkModePrim,
                                              ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 10.h,
                            ),
                            item.tasks[i].is_Finished
                                ? Expanded(
                                    child: Text(
                                      item.tasks[i].title.text,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontFamily: "Subjective",
                                        color:
                                            CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : Expanded(
                                    child: Text(
                                      item.tasks[i].title.text,
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontFamily: "Subjective",
                                          color: CashHelper.getData(key: ChangeTheme)
                                              ? Colors.black
                                              : AppColor.kTextColor),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Divider(),
                      GestureDetector(
                        onTap: checkDate(DateTime.now(), _goals[index].final_date) && !_goals[index].Complete_Goal
                            ? () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CreateGoalPage(
                                              HeaderName: "Edit Goal".tr(),
                                              ButtonName: "Update Goal".tr(),
                                              item: item,
                                              goal_id: item.id,
                                            )));
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    !_goals[index].Complete_Goal
                                        ? "This Goal is Out Of Date".tr()
                                        : "This Goals is Complete".tr(),
                                    style: TextStyle(
                                      color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                      fontFamily: "Subjective",
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: AppColor.emotionsSections,
                                ));
                              },
                        child: Container(
                          color: /*checkDate(
                              DateTime.now(), _goals[index].final_date)?*/
                              Colors.transparent /*:Colors.grey.withOpacity(0.2)*/,
                          padding: EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              //SizedBox(width: MediaQuery.of(context).size.width-550,),
                              Text(
                                "Edit Goal".tr(),
                                style: TextStyle(
                                    color: CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                    fontFamily: "Subjective",
                                    fontSize: 12.sp),
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              CircleAvatar(
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 15.r,
                                  color: CashHelper.getData(key: ChangeTheme)
                                      ? AppColor.LightModeSecTextField
                                      : AppColor.darkModeSeco,
                                ),
                                backgroundColor:
                                    CashHelper.getData(key: ChangeTheme) ? Colors.black : AppColor.kTextColor,
                                radius: 17.r,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
          ],
        ),
      );
    }

    return columnContent;
  }

  /*Widget goal_Item(GoalItem Item_goal) {
    int end_Task_Number = GoalItem.get_end_Task_Number(Item_goal);
    int task_Number = GoalItem.get_task_number(Item_goal);

    print("in"); //GoalItem.get_task_number(Item_goal);
    return ListTile(
      //tileColor:  AppColor.socialSection,
      leading: CircleAvatar(
        radius: 35,
        child: Image(
          image: NetworkImage(Item_goal.image_Path),
        ),
      ),
      title: Text(
        Item_goal.goal_Name,
        style: TextStyle(
            color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 15),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          Text(
            "$end_Task_Number out of $task_Number tasks Remaining",
            style: TextStyle(
                color: AppColor.mainBtn,
                fontFamily: "Subjective",
                fontSize: 10),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: SizedBox(
                width: double.infinity,
                height: 12,
                child: LinearProgressIndicator(
                  value: GoalItem.get_completion_Rate(Item_goal) > 0
                      ? GoalItem.get_completion_Rate(Item_goal)
                      : 0,
                  backgroundColor: AppColor.darkModePrim,
                  color: AppColor.mainBtn,
                  minHeight: 10,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
    return Scaffold(
      floatingActionButton: FloatingActionButtons(),
      //backgroundColor: AppColor.darkModePrim,
      body: LoadingOverlay(
        isLoading: _isLoadingtask,
        opacity: 0.5,
        color: CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
        progressIndicator: CircularProgressIndicator(
          color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
        ),
        child: SmartRefresher(
          header: WaterDropHeader(
              waterDropColor: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
          //physics: BouncingScrollPhysics(),
          enablePullDown: true,
          //enableTwoLevel: true,

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
                    ConfettiWidget(
                      confettiController: _controllerCenter,
                      blastDirectionality: BlastDirectionality.explosive,
                      particleDrag: 0.05,
                      emissionFrequency: 0.05,
                      numberOfParticles: 50,
                      gravity: 0.05,
                      shouldLoop: true,
                      colors: const [
                        Colors.green,
                        Colors.blue,
                        Colors.pink,
                        Colors.orange,
                        Colors.purple
                      ], // manually specify the colors to be used
                    ),
                    HeaderCard(
                      name: _name,
                      image: _image,
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
                        : const SizedBox(height: 0.01),
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
                                              width: 334.w,
                                              height: 97.h,
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
                                highlightColor: AppColor.mainBtn,
                                direction: SkeletonDirection.ltr,
                              ))
                            : _goals.length > 0
                                ? ListView.builder(
                                    itemCount: _goals.length,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      int end_Task_Number = GoalItem.get_end_Task_Number(_goals[index]);
                                      int task_Number = GoalItem.get_task_number(_goals[index]);
                                      return Slidable(
                                        actionPane: SlidableDrawerActionPane(),
                                        actionExtentRatio: 0.25,
                                        controller: slidableController,
                                        closeOnScroll: true,
                                        secondaryActions: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  width: 75.w,
                                                  //height: 80.h,
                                                  margin: EdgeInsets.only(bottom: 14.h),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15.0.r),
                                                    color: checkDate(DateTime.now(), _goals[index].final_date) &&
                                                            !_goals[index].Complete_Goal
                                                        ? CashHelper.getData(key: ChangeTheme)
                                                            ? AppColor.mainBtnLightMode.withOpacity(0.2)
                                                            : AppColor.mainBtn.withOpacity(0.2)
                                                        : CashHelper.getData(key: ChangeTheme)
                                                            ? AppColor.LightModeSecTextField.withOpacity(1)
                                                            : AppColor.darkModeSeco.withOpacity(1),
                                                  ),
                                                  child: IconSlideAction(
                                                    caption: "Delete",
                                                    closeOnTap: true,
                                                    color: Colors.transparent,
                                                    iconWidget: Icon(
                                                      Icons.delete,
                                                      size: 30.r,
                                                      color: AppColor.emotionsSections,
                                                    ),
                                                    onTap: () {
                                                      showDialog(
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              backgroundColor: CashHelper.getData(key: ChangeTheme)
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
                                                                "Do You Want To Delete This Goal !!",
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

                                                                      _deleteGoal(_goals[index].id, _goals[index]);

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
                                                  )

                                                  /*Padding(
                                      padding:  EdgeInsets.only(
                                          bottom: 10.h,left: 10.w),
                                      child: Container(
                                          width: 100.w,
                                          height: 97.h,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(15.0),
                                            color: checkDate(
                                DateTime.now(), _goals[index].final_date)&&!_goals[index].Complete_Goal
                                ? AppColor.darkModeSeco
                                    : Colors.grey.withOpacity(0.2)),

                                          child:
                                    Column(
                                      children: [
                                        Icon(Icons.delete,size: 30.r,color: AppColor.emotionsSections,),
                                        Text("Delete",style: TextStyle(
                                color: AppColor.kTextColor, fontFamily: "Subjective", ),)
                                      ],
                                      mainAxisAlignment: MainAxisAlignment.center,
                                    ),
                                )),*/
                                                  )
                                            ],
                                          ),
                                        ],
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(5.w),
                                              //height: 97,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10.r),
                                                  color: checkDate(DateTime.now(), _goals[index].final_date) &&
                                                          !_goals[index].Complete_Goal
                                                      ? CashHelper.getData(key: ChangeTheme)
                                                          ? AppColor.mainBtnLightMode.withOpacity(0.2)
                                                          : AppColor.mainBtn.withOpacity(0.2)
                                                      : CashHelper.getData(key: ChangeTheme)
                                                          ? AppColor.LightModeSecTextField.withOpacity(1)
                                                          : AppColor.darkModeSeco.withOpacity(1)),
                                              child: ExpansionTile(
                                                tilePadding: EdgeInsets.symmetric(vertical: 5.h),
                                                title: Text(
                                                  _goals[index].goal_Name,
                                                  style: TextStyle(
                                                      color: CashHelper.getData(key: ChangeTheme)
                                                          ? Colors.black
                                                          : AppColor.kTextColor,
                                                      fontFamily: "Subjective",
                                                      fontSize: 15.sp),
                                                ),
                                                children: _buildExpandableContent(_goals[index], index),
                                                iconColor: CashHelper.getData(key: ChangeTheme)
                                                    ? AppColor.LightModeSecTextField
                                                    : AppColor.darkModeSeco,
                                                leading: CircleAvatar(
                                                  radius: 25.r,
                                                  // backgroundImage: NetworkImage(image),
                                                  backgroundColor: Colors.transparent,
                                                  child: CachedNetworkImage(
                                                    imageUrl: _goals[index].image_Path,
                                                    errorWidget: (context, url, error) => Icon(
                                                      Icons.error,
                                                      color: CashHelper.getData(key: ChangeTheme)
                                                          ? AppColor.mainBtnLightMode
                                                          : AppColor.mainBtn,
                                                    ),
                                                  ),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "$end_Task_Number out of $task_Number tasks Remaining",
                                                      style: TextStyle(
                                                          color: CashHelper.getData(key: ChangeTheme)
                                                              ? AppColor.mainBtnLightMode
                                                              : AppColor.mainBtn,
                                                          fontFamily: "Subjective",
                                                          fontSize: 9.sp),
                                                    ),
                                                    SizedBox(
                                                      height: 10.h,
                                                    ),
                                                    Container(
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                                        child: SizedBox(
                                                          width: 216.w,
                                                          height: 11.h,
                                                          child: LinearProgressIndicator(
                                                            value: GoalItem.get_completion_Rate(_goals[index]) > 0
                                                                ? GoalItem.get_completion_Rate(_goals[index])
                                                                : 0,
                                                            backgroundColor: CashHelper.getData(key: ChangeTheme)
                                                                ? AppColor.lightModePrim
                                                                : AppColor.darkModePrim,
                                                            color: CashHelper.getData(key: ChangeTheme)
                                                                ? AppColor.mainBtnLightMode
                                                                : AppColor.mainBtn,
                                                            minHeight: 11.h,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Divider()
                                          ],
                                        ),
                                      );
                                    })
                                : ErrorEmptyItem(
                                    ImagePath: "assets/images/Goals2x.png",
                                    Title: "No Goals Yet!!!".tr(),
                                    SupTitle: "Set your first Goal by pressing the button and selecting new Goal.".tr(),
                                    TitleColor: CashHelper.getData(key: ChangeTheme)
                                        ? AppColor.mainBtnLightMode
                                        : AppColor.mainBtn,
                                  )
                        : ErrorEmptyItem(
                            ImagePath: "assets/images/error2x.png",
                            Title: "An Error Occured".tr(),
                            SupTitle:
                                "this time it's our Mistake, sorry for inconvenience and we will fix this issue Asap!!!"
                                    .tr(),
                            TitleColor:
                                CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
