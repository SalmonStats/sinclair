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
  final int goldenIkuraNum;
  final int ikuraNum;
  final int helpTotal;
  final int deadTotal;
  final int kumaPoint;
  final int kumaPointTotal;

  const Card({
    required this.goldenIkuraNum,
    required this.ikuraNum,
    required this.helpTotal,
    required this.deadTotal,
    required this.kumaPoint,
    required this.kumaPointTotal,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      goldenIkuraNum: json['golden_ikura_num'] as int,
      ikuraNum: json['ikura_num'] as int,
      helpTotal: json['help_total'] as int,
      deadTotal: json['dead_total'] as int,
      kumaPoint: json['kuma_point'] as int,
      kumaPointTotal: json['kuma_point_total'] as int,
    );
  }
}
