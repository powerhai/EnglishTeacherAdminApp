class TextLight {
  int id;
  String title;
  int sort;
  TextLight({this.id, this.title, this.sort});
  factory TextLight.fromJson(Map<String, dynamic> json){
    return TextLight(id:json["Id"], title:json["Title"] , sort: 0);
  }

}
