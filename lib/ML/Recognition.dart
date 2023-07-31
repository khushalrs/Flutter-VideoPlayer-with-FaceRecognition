import 'dart:convert';
import 'dart:ui';

class Recognition {
  String name;
  Rect location;
  List<double> embeddings;
  double distance;
  /// Constructs a Category.
  Recognition(this.name, this.location,this.embeddings,this.distance);

  factory Recognition.fromJson(Map<String, dynamic> json){
    return Recognition(
        json['name'],
        parseJson(json['location']),
        json['embeddings'].cast<double>(),
        json['distance']
    );
  }

  Map<String, dynamic> toJson() =>  {
    'name' : name,
    'location' : location.toString(),
    'embeddings' : embeddings,
    'distance' : distance,
  };

  static parseJson(String s) {
    String s1 = s.substring(s.indexOf("(")+1, s.indexOf(")"));
    List<String> l = s1.split(", ");
    print("Parsed Location : $l");
    return Rect.fromLTRB(double.parse(l[0]), double.parse(l[1]), double.parse(l[2]), double.parse(l[3]));
  }

}
