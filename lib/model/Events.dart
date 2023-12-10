class EventsForDate {
  List<SingleEvent> eventForDayList = [];
  EventsForDate(this.eventForDayList);
}

class SingleEvent {
  int id;
  DateTime date;
  String iconType;
  String nameType;
  String Image;
  String MoodImage;
  String Item_Title;
  String Item_Sup_Tilte;
  String Description;
  SingleEvent(this.id, this.iconType, this.nameType, this.Image, this.MoodImage,
      this.Item_Title, this.Item_Sup_Tilte, this.Description, this.date);
  @override
  String toString() {
    //String Event=Event[key]
    return "{id:$id,iconType:$iconType,nameType:$nameType,Image:$Image,MoodImage:$MoodImage,Item_Title:$Item_Title,Item_Sup_Tilte:$Item_Sup_Tilte,Description:$Description,date:$date}";
  }
}

class Event {
  String title;
  //Color color;
  Event(this.title);
}
