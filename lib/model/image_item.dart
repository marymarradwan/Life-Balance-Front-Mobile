class ImageItem {
  int imageId;
  String ImageUrl;
  String ImageName;

  ImageItem(this.imageId, this.ImageUrl, this.ImageName);

  @override
  String toString() {
    // TODO: implement toString
    return "imageId : $imageId,ImageURL : $ImageUrl , imageName : $ImageName";
  }
}
