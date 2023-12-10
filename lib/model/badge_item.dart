class BadgeItem {
  String image;
  String name;
  bool isOpen;

  BadgeItem(this.image, this.name, this.isOpen);

  @override
  String toString() {
    return 'BadgeItem{image: $image, name: $name}';
  }
}
