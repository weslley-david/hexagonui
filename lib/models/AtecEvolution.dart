class AtecEvolution {
  List<Evolution>? evolution;

  AtecEvolution({this.evolution});

  AtecEvolution.fromJson(Map<String, dynamic> json) {
    if (json['evolution'] != null) {
      evolution = <Evolution>[];
      json['evolution'].forEach((v) {
        evolution!.add(new Evolution.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.evolution != null) {
      data['evolution'] = this.evolution!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Evolution {
  String? area;
  List<int>? score;

  Evolution({this.area, this.score});

  Evolution.fromJson(Map<String, dynamic> json) {
    area = json['area'];
    score = json['score'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['area'] = this.area;
    data['score'] = this.score;
    return data;
  }
}
