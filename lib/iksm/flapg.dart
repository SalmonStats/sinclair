// ignore_for_file: constant_identifier_names

class Flapg {
  final String f;
  final String p1;
  final String p2;
  final String p3;

  const Flapg(
      {required this.f, required this.p1, required this.p2, required this.p3});

  factory Flapg.fromJson(Map<String, dynamic> json) {
    return Flapg(
        f: json["result"]["f"],
        p1: json["result"]["p1"],
        p2: json["result"]["p2"],
        p3: json["result"]["p3"]);
  }
}

enum FlapgType { NSO, APP }

extension FlapgTypeExt on FlapgType {
  String get rawValue {
    switch (this) {
      case FlapgType.APP:
        return "app";
      case FlapgType.NSO:
        return "nso";
    }
  }
}
