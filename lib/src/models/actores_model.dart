class Cast{

  List<Actor> actores = new List( );
  
  
  Cast.fromJsonList (List<dynamic> jsonList ){
    if(jsonList == null) return;

    jsonList.forEach( (item) {
      final actor = Actor.fromJsonMap(item);
      actores.add(actor);
    });
  }
}

class Actor {
  int castId;
  String character;
  String creditId;
  int gender;
  int id;
  String name;
  int order;
  String profilePath;

  Actor({
    this.character,
    this.castId,
    this.creditId,
    this.gender,
    this.id,
    this.name,
    this.order,
    this.profilePath,
  });

  Actor.fromJsonMap(Map<String, dynamic> json) {
    character = json['character'];
    creditId = json['credit_id'];
    castId = json['cast_id'];
    gender = json['gender'];
    id = json['id'];
    name = json['name'];
    order = json['order'];
    profilePath = json['profile_path'];
  }

  getActorimg(){
    if(profilePath == null){
        return 'https://clipground.com/images/picture-not-available-clipart-12.jpg';
    }else{
        return 'https://image.tmdb.org/t/p/w500/$profilePath';
    }
    
  }
}

enum Department {
  PRODUCTION,
  SOUND,
  WRITING,
  COSTUME_MAKE_UP,
  DIRECTING,
  CAMERA,
  VISUAL_EFFECTS,
  LIGHTING,
  CREW,
  ART,
  EDITING
}
