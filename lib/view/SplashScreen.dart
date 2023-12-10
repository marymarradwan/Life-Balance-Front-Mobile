import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:life_balancing/Util/AppColor.dart';
import 'package:life_balancing/Util/cache_helper.dart';
import 'package:life_balancing/Util/http/constant.dart';
import 'package:life_balancing/model/section_item.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/view/login.dart';
import 'package:life_balancing/view/main_screen.dart';
import 'package:life_balancing/view/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool is_end = false;
  /* final List<List<Emoje>> mode_Active = List.generate(
      24,
          (index) =>
              new List.generate(
                  12,
                      (index) =>
                  new Emoje("https://ai-gym.club/uploads/angel.gif", "Mood", false)));*/
  /* final List<Emoje> mode_Active1 = List.generate(
      12,
          (index) =>
      new Emoje("https://ai-gym.club/uploads/angel.gif", "Mood", false));*/
  @override
  void initState() {
    super.initState();
    Sections.sections.add(new SectionItem(
        Iconsax.people5, "https://ai-gym.club/uploads/soc_1637260013.png", "Social", AppColor.socialSection, 1));
    Sections.sections.add(new SectionItem(
        Iconsax.briefcase5, "https://ai-gym.club/uploads/carer_1637260195.png", "Career", AppColor.careerSections, 2));
    Sections.sections.add(new SectionItem(
        Iconsax.book5, "https://ai-gym.club/uploads/sealf_1637260087.png", "Learn", AppColor.learnSections, 3));
    Sections.sections.add(new SectionItem(
        Iconsax.emoji_normal5, "https://ai-gym.club/uploads/spi_1637260061.png", "Spirit", AppColor.spiritSections, 4));
    Sections.sections.add(new SectionItem(
        Iconsax.weight_15, "https://ai-gym.club/uploads/health_1637260142.png", "Health", AppColor.healthSections, 5));
    Sections.sections.add(new SectionItem(
        Iconsax.lovely5, "https://ai-gym.club/uploads/emo_1637260165.png", "Emotion", AppColor.emotionsSections, 6));

    // Rewards.rewards.add(new RewardItem(
    //     "Moods", 355, false, "https://ai-gym.club/uploads/angel.gif"));
    // Rewards.rewards.add(new RewardItem(
    //     "Habits", 355, false, "https://ai-gym.club/uploads/angel.gif"));
    // Rewards.rewards.add(new RewardItem(
    //     "Dashboard", 355, false, "https://ai-gym.club/uploads/angel.gif"));
    // Rewards.rewards.add(new RewardItem(
    //     "Dashboard", 355, false, "https://ai-gym.club/uploads/angel.gif"));
    // Rewards.rewards.add(new RewardItem(
    //     "Quotes", 355, false, "https://ai-gym.club/uploads/angel.gif"));
    // ////////////***************///////////////
    // Badges.badges = List.generate(9,
    //     (index) => new BadgesItem("assets/images/temp@2x.png", "Badge", 1000));

    // TODO: implement initState

    Timer(Duration(seconds: 3), () {
      SharedPreferences.getInstance().then((prefs) async {
        String token = (prefs.getString('token') ?? null);

        print(token);
        var res;
        if (token != null) {
          res = await config("api/configs", token);
        }

        print(res);
        if (token == null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => OnboardingScreen()));
        } else if (res.statusCode == 401) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
        } else if (res.statusCode == 200) {
          String name = json.decode(res.body)['data']['user']['name'];
          String image = json.decode(res.body)['data']['user']['image'] ??
              'https://images.unsplash.com/photo-1554151228-14d9def656e4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=333&q=80';
          String email = json.decode(res.body)['data']['user']['email'];
          bool is_active = json.decode(res.body)['data']['user']['is_active'];
          print(image);
          await prefs.setString('name', name);
          await prefs.setString('image', image);
          await prefs.setString('email', email);
          await prefs.setBool("is_active", is_active);

          print("is_Active$is_active");
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => MainScreen(
                    TabId: 2,
                  )));
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 200,
                width: 250,
              ),
            ),
          ),
          Align(
            heightFactor: 5.0,
            alignment: Alignment.bottomCenter,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn),
              backgroundColor:
                  CashHelper.getData(key: ChangeTheme) ? AppColor.LightModeSecTextField : AppColor.darkModeSeco,
              color: CashHelper.getData(key: ChangeTheme) ? AppColor.mainBtnLightMode : AppColor.mainBtn,
              strokeWidth: 2,
              // minHeight: 8,
              //minHeight: 20,
            ),
          )
        ],
      ),
    );
  }
}
