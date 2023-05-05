class Gitmoji {
  String emoji;
  String entity;
  String code;
  String description;
  String name;
  String? semver;

  Gitmoji(
      this.emoji,
      this.entity,
      this.code,
      this.description,
      this.name,
      this.semver);

  Gitmoji.fromJson(Map<String, dynamic> json): 
    emoji = json['emoji'],
    entity = json['entity'],
    code = json['code'],
    description = json['description'],
    name = json['name'],
    semver = json['semver'];
  

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emoji'] = emoji;
    data['entity'] = entity;
    data['code'] = code;
    data['description'] = description;
    data['name'] = name;
    data['semver'] = semver;
    return data;
  }

  @override String toString() => '$emoji - $description';
}