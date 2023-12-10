import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/ScreenHelper.dart';
import 'package:life_balancing/model/activite_Item.dart';
import 'package:life_balancing/model/section_item.dart';

import 'InsertCustomActivity.dart';

class MoreActivite extends StatefulWidget {
  final String name_Activite;
//final int index;
  final List<singleActivity> activite;
  final int Section_id;
  final String Section_image;
  //add type to multy select
  final int type;
  const MoreActivite({Key key, this.name_Activite, this.activite, this.Section_image, this.Section_id, this.type})
      : super(key: key);
  @override
  _MoreActiviteState createState() => _MoreActiviteState();
}

class _MoreActiviteState extends State<MoreActivite> {
  @override
  Widget build(BuildContext context) {
    ScreenHelper(context);
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
                  Text(
                    "More ".tr() + widget.name_Activite + " Activate".tr(),
                    style: TextStyle(color: AppColor.mainBtn, fontFamily: "Subjective", fontSize: 18.sp),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      return build_Single_Activite(widget.activite[index]);
                    },
                    itemCount: widget.activite.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    "Didn\'t Find What You Are Looking For ?".tr(),
                    style: TextStyle(color: AppColor.mainBtn, fontFamily: "Subjective", fontSize: 16.sp),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => InsertCustomActivity(
                                Section_id: widget.Section_id,
                                Section_image: Sections.sections[widget.Section_id - 1].icon,
                                Section_name: widget.name_Activite,
                              )));
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(AppColor.darkModeSeco),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0.r),
                          side: BorderSide(color: AppColor.darkModePrim),
                        ),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(Size(1.sw, 60.h)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Insert Custom Activate".tr(),
                          style: TextStyle(color: Colors.white, fontFamily: "Subjective", fontSize: 18.sp),
                        ),
                        Icon(
                          Iconsax.coffee5,
                          color: AppColor.kTextColor,
                          size: 34.r,
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

  Widget build_Single_Activite(singleActivity item) {
    return ButtonTheme(
      child: GestureDetector(
        onTap: () {
          setState(() {
            //item.isClicked = !item.isClicked;
            if (widget.type == 1) {
              for (int i = 0; i < widget.activite.length; i++) {
                if (item == widget.activite[i]) {
                  item.isClicked = !item.isClicked;
                } else
                  widget.activite[i].isClicked = false;
              }
            } else {
              item.isClicked = !item.isClicked;
            }
          });
        },
        child: Container(
          padding: EdgeInsets.all(1),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: item.isClicked ? AppColor.mainBtn : AppColor.darkModeSeco),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 40.r,
                backgroundColor: Colors.transparent,
                child: CachedNetworkImage(
                    imageUrl: item.image,
                    errorWidget: (context, string, _) => Icon(
                          Icons.error,
                          color: AppColor.mainBtn,
                        )),
              ),
              Text(
                item.name,
                style: TextStyle(color: AppColor.kTextColor, fontFamily: "Subjective", fontSize: 10.sp),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              Text(
                "+" + item.points.toString() + "pts",
                style: TextStyle(
                    color: item.isClicked ? AppColor.kTextColor : AppColor.mainBtn,
                    fontFamily: "Subjective",
                    fontSize: 12.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget Insert_Button() {
    return ButtonTheme(
      minWidth: 200.0,
      //height: 100.0,
      child: ElevatedButton(
        child: Text(
          'Back',
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontFamily: "Subjective", fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pop(context);
          /*HabitItem item=new HabitItem(image_Name, section_Title, time_Remaining, points, name_Habits, Reminder, starting_Day, time_of_The_Habits, perform_habits);
            //var res=JsonEncoder(item.toJson());
            print(item.toString());
            Habits.add_Habits(item);
            Navigator.of(context).pop();*/
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(AppColor.mainBtn),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0.r),
              side: BorderSide(color: AppColor.darkModePrim),
            ),
          ),
          minimumSize: MaterialStateProperty.all<Size>(Size(222.w, 50.h)),
        ),
      ),
    );
  }
}
