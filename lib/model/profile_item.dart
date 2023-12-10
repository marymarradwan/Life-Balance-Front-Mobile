class RewardItem {
  String title;
  int total_Points_Earn;
  bool is_Unlocked;
  String image_path;
  RewardItem(this.title, this.total_Points_Earn, this.is_Unlocked,this.image_path);

  static double get_completion_Rate(RewardItem item , int cur) {
    int end = cur;
    int total = item.total_Points_Earn;
    return end / total;
  }
  @override
  String toString() {
    return '{title: $title,total_Points_Earn: $total_Points_Earn,is_Unlocked: $is_Unlocked,}';
  }
}

class Rewards {
  static List<RewardItem> rewards = [];

  static void add_Rewards(RewardItem item) {
    rewards.add(item);
  }
}

class BadgesItem{
  String image_path;
  String badge_name;
  int quantity_points;

  BadgesItem(this.image_path,this.badge_name , this.quantity_points);
  @override
  String toString() {
    return '{image_path: $image_path,badge_name: $badge_name,}';
  }

}

class Badges{

  static List<BadgesItem> badges=[];

  static void add_Budge(BadgesItem item){
    badges.add(item);
  }
}
