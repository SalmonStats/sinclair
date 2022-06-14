class Version {
  final String version;
  final String currentVersionReleaseDate;
  final String minimumOsVersion;

  const Version(
      {required this.version,
      required this.currentVersionReleaseDate,
      required this.minimumOsVersion});

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
        version: json["results"][0]["version"],
        currentVersionReleaseDate: json["results"][0]
            ["currentVersionReleaseDate"],
        minimumOsVersion: json["results"][0]["minimumOsVersion"]);
  }
}
