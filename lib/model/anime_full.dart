class AnimeFull {
  final String name;
  final String image;
  final String description;
  final List data;
  final int total;

  AnimeFull(
      {required this.total,
      required this.name,
      required this.image,
      required this.description,
      required this.data});

  factory AnimeFull.fromJson(Map json) {
    return AnimeFull(
      name: json['name'],
      image: json['image'],
      description: json['description'],
      data: json['data'],
      total: json['total'] ?? 0,
    );
  }
}