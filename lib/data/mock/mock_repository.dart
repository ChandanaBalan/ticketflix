import '../../shared/models.dart';

class MockRepository {
  const MockRepository();

  List<Movie> get movies => const [
    Movie(
      id: 'balan-the-boy',
      title: 'Balan: The Boy',
      posterAsset: 'assets/images/balan.jpg',
      likes: '25.2K+',
      genres: ['Drama', 'Family'],
    ),
    Movie(
      id: 'unmadham',
      title: 'Unmadham',
      posterAsset: 'assets/images/unmadham.jpg',
      likes: '22.2K+',
      genres: ['Crime', 'Thriller'],
    ),
    Movie(
      id: 'spider-man-brand-new-day',
      title: 'Spider-Man: Brand New Day',
      posterAsset: 'assets/images/spiderman_hero.jpg',
      heroAsset: 'assets/images/spiderman_hero.jpg',
      likes: '1M+',
      genres: ['Action', 'Adventure', 'Sci-Fi'],
    ),
    Movie(
      id: 'lurk',
      title: 'Lurk',
      posterAsset: 'assets/images/lurk.jpg',
      likes: '18.8K+',
      genres: ['Horror', 'Mystery'],
    ),
  ];

  Movie movie(String id) =>
      movies.firstWhere((movie) => movie.id == id, orElse: () => movies[2]);

  List<CastMember> get cast => const [
    CastMember(
      name: 'Tom Holland',
      role: 'Peter Parker',
      asset: 'assets/images/cast_tom.jpg',
    ),
    CastMember(
      name: 'Zendaya',
      role: 'MJ',
      asset: 'assets/images/cast_zendaya.jpg',
    ),
    CastMember(
      name: 'Sadie Sink',
      role: 'Cast',
      asset: 'assets/images/cast_sadie.jpg',
    ),
    CastMember(
      name: 'Jacob Batalon',
      role: 'Ned',
      asset: 'assets/images/cast_jacob.jpg',
    ),
  ];

  List<Cinema> get cinemas => const [
    Cinema(
      id: 'pvr-forum',
      name: 'PVR: Forum Mall, Kochi',
      showtimes: [
        Showtime(
          id: '06-50',
          time: '06:50 AM',
          experience: 'LUXE PRIME',
          price: 880,
        ),
        Showtime(id: '07-00', time: '07:00 AM', experience: 'LUXE', price: 780),
        Showtime(
          id: '07-30',
          time: '07:30 AM',
          experience: 'PXL',
          price: 650,
          fillingFast: true,
        ),
        Showtime(
          id: '08-15',
          time: '08:15 AM',
          experience: 'PXL',
          price: 650,
          fillingFast: true,
        ),
        Showtime(id: '09-55', time: '09:55 AM', experience: '', price: 620),
        Showtime(id: '10-00', time: '10:00 AM', experience: 'LUXE', price: 780),
        Showtime(
          id: '10-40',
          time: '10:40 AM',
          experience: 'PXL',
          price: 650,
          fillingFast: true,
        ),
        Showtime(
          id: '11-20',
          time: '11:20 AM',
          experience: '',
          price: 620,
          fillingFast: true,
        ),
        Showtime(id: '13-05', time: '01:05 PM', experience: 'LUXE', price: 780),
        Showtime(
          id: '13-45',
          time: '01:45 PM',
          experience: 'PXL',
          price: 650,
          fillingFast: true,
        ),
        Showtime(
          id: '14-25',
          time: '02:25 PM',
          experience: '',
          price: 620,
          fillingFast: true,
        ),
        Showtime(
          id: '16-05',
          time: '04:05 PM',
          experience: '',
          price: 620,
          fillingFast: true,
        ),
        Showtime(
          id: '16-10',
          time: '04:10 PM',
          experience: 'LUXE',
          price: 780,
          fillingFast: true,
        ),
        Showtime(
          id: '16-50',
          time: '04:50 PM',
          experience: 'PXL',
          price: 650,
          fillingFast: true,
        ),
        Showtime(
          id: '17-30',
          time: '05:30 PM',
          experience: '',
          price: 620,
          fillingFast: true,
        ),
        Showtime(
          id: '19-10',
          time: '07:10 PM',
          experience: '',
          price: 620,
          fillingFast: true,
        ),
        Showtime(
          id: '19-10-luxe',
          time: '07:10 PM',
          experience: 'LUXE',
          price: 780,
          soldOut: true,
        ),
        Showtime(
          id: '19-55',
          time: '07:55 PM',
          experience: 'PXL',
          price: 650,
          fillingFast: true,
        ),
      ],
    ),
  ];
}
