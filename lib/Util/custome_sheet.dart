import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';

class CustomSheet<T> extends StatelessWidget {
  const CustomSheet._(
      {Key key,
      this.child,
      this.title,
      this.onClose,
      this.closeButtonColor,
      this.headerStyle,
      this.isDismissible,
      this.topTitle})
      : super(key: key);

  final Widget child;
  final String title;
  final Color closeButtonColor;
  final TextStyle headerStyle;
  final ValueChanged<BuildContext> onClose;
  final bool isDismissible;
  final double topTitle;

  static Future<T> show<T>({
    BuildContext context,
    Widget child,
    String title,
    bool addHeader = true,
    ValueChanged<BuildContext> onClose,
    Color closeButtonColor,
    TextStyle headerStyle,
    double topTitle,
    bool isDismissible = true,
  }) =>
      showModalBottomSheet<T>(
        context: context,
        enableDrag: true,
        isDismissible: isDismissible,
        isScrollControlled: true,
        barrierColor: Colors.grey.withOpacity(0.5),
        //overlay color
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.0.r))),
        builder: (_) => CustomSheet._(
          title: title,
          onClose: onClose,
          closeButtonColor: closeButtonColor,
          headerStyle: headerStyle,
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0.w,
        vertical: 0,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: EdgeInsets.only(top: topTitle ?? 23.h, bottom: 18.h),
                child: Text(title, style: TextStyle(fontSize: 20, color: Colors.blue)
                    //AppTheme.headline1.copyWith(fontSize: 20, color: Colors.blue),
                    ),
              ),
            Flexible(
              child: SingleChildScrollView(child: child),
            ),
            SizedBox(
              height: 10.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget closeWidget() => null;
}
