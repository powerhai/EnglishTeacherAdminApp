class Sentence {
  int id;
  String english;
  String chinese;
  bool isAudioExist;
  bool isChineseChanged = false;
  bool isAudioChanged = false;
  UploadState uploadState = UploadState.Normal;
  AudioLocation audioLocation;

  bool get isChanged => isChineseChanged || isAudioChanged;
  double startAudio;
  double endAudio;
  Sentence(
      {this.id = 0,
      this.english = "",
      this.chinese = "",
      this.isAudioExist = false,
      this.startAudio = 0,
      this.endAudio = 100});

  factory Sentence.fromJson(Map<String, dynamic> json) {
    var c = Sentence(
        id: json["Id"],
        english: json["Eng"],
        chinese: json["Chn"],
        isAudioExist: json["HasAudio"]);
    if (c.isAudioExist) c.audioLocation = AudioLocation.Server;
    return c;
  }
}

enum UploadState { Normal, Uploading, Uploaded, UploadError }
enum AudioLocation { Server, LocalFile }
