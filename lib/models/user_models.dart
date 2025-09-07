import 'genre.dart';

class UserProfile {
  final String id;
  final String name;
  final Set<Genre> favoriteGenres;
  final String? avatarURL;

  UserProfile({
    required this.id,
    required this.name,
    this.favoriteGenres = const {},
    this.avatarURL,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'favoriteGenres': favoriteGenres.map((g) => g.name).toList(),
    'avatarURL': avatarURL,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    favoriteGenres: (json['favoriteGenres'] as List?)
        ?.map((g) => Genre.values.byName(g))
        .toSet() ?? {},
    avatarURL: json['avatarURL'],
  );

  UserProfile copyWith({
    String? id,
    String? name,
    Set<Genre>? favoriteGenres,
    String? avatarURL,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    favoriteGenres: favoriteGenres ?? this.favoriteGenres,
    avatarURL: avatarURL ?? this.avatarURL,
  );
}

class Friend {
  final String id;
  final String name;
  final String? avatarURL;

  Friend({
    required this.id,
    required this.name,
    this.avatarURL,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarURL': avatarURL,
  };

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
    id: json['id'],
    name: json['name'],
    avatarURL: json['avatarURL'],
  );
}
