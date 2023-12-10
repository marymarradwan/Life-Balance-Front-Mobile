import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:life_balancing/Util/AppColor.dart';

class ErrorEmptyItem extends StatelessWidget {
  final String ImagePath;
  final String Title;
  final String SupTitle;
  final Color TitleColor;

  const ErrorEmptyItem(
      {Key key, this.ImagePath, this.Title, this.SupTitle, this.TitleColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 360.h,
        width: 1.sw,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage(ImagePath),
              height: 250.h,
              width: 250.w,
            ),
            Text(
              Title,
              style: TextStyle(
                  color: TitleColor,
                  fontSize: 29.sp,
                  fontFamily: "Subjective",
                  fontWeight: FontWeight.bold),
            ),
            Text(
              SupTitle,
              style: TextStyle(
                  color: AppColor.kTextColor,
                  fontSize: 20.sp,
                  fontFamily: "Subjective",
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
