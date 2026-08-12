enum MovieLanguage { english, malayalam, hindi }

enum MovieFormat { twoD, threeD, fourDx3D }

extension MovieLanguageLabel on MovieLanguage {
  String get label => switch (this) {
    MovieLanguage.english => 'English',
    MovieLanguage.malayalam => 'Malayalam',
    MovieLanguage.hindi => 'Hindi',
  };
}

extension MovieFormatLabel on MovieFormat {
  String get label => switch (this) {
    MovieFormat.twoD => '2D',
    MovieFormat.threeD => '3D',
    MovieFormat.fourDx3D => '4DX 3D',
  };
}

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.likes,
    required this.genres,
    required this.description,
    required this.languages,
    required this.formats,
    required this.cast,
    this.bannerUrl,
    this.runtime = '2h 25m',
    this.certificate = 'UA13+',
    this.releaseDate,
  });

  final String id;
  final String title;
  final String posterUrl;
  final String? bannerUrl;
  final String likes;
  final List<String> genres;
  final String description;
  final List<MovieLanguage> languages;
  final List<MovieFormat> formats;
  final List<CastMember> cast;
  final String runtime;
  final String certificate;
  final DateTime? releaseDate;

  bool get isPreRelease => releaseDate != null;

  String? get formattedReleaseDate {
    final date = releaseDate;
    if (date == null) return null;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class CastMember {
  const CastMember({
    required this.name,
    required this.role,
    this.photoUrl,
  });

  final String name;
  final String role;
  final String? photoUrl;
}
