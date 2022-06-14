class Hash {
  final String hash;
  final String naIdToken;
  final String timestamp;

  const Hash(
      {required this.hash, required this.naIdToken, required this.timestamp});

  factory Hash.fromJson(Map<String, dynamic> json) {
    return Hash(
        hash: json["hash"],
        naIdToken: json["naIdToken"],
        timestamp: json["timestamp"]);
  }
}
