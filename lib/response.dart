class Results {
  final Summary summary;

  const Results({required this.summary});

  factory Results.fromJson(Map<String, dynamic> json) {
    return Results(
      summary: Summary.fromJson(json['summary']),
    );
  }
}

class Summary {
  final Card card;

  const Summary({required this.card});

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      card: Card.fromJson(json['card']),
    );
  }
}

class Card {
  final int goldenIkuraTotal;
  final int ikuraTotal;
  final int helpTotal;
  final int jobNum;
  final int kumaPoint;
  final int kumaPointTotal;

  const Card({
    required this.goldenIkuraTotal,
    required this.ikuraTotal,
    required this.helpTotal,
    required this.jobNum,
    required this.kumaPoint,
    required this.kumaPointTotal,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      goldenIkuraTotal: json['golden_ikura_total'] as int,
      ikuraTotal: json['ikura_total'] as int,
      helpTotal: json['help_total'] as int,
      jobNum: json["job_num"] as int,
      kumaPoint: json['kuma_point'] as int,
      kumaPointTotal: json['kuma_point_total'] as int,
    );
  }
}
