import '../../shared/models.dart';

class MockRepository {
  const MockRepository();

  List<Movie> get movies => const [
    Movie(
      id: 'chithram',
      title: 'Chithram',
      posterUrl:
          'https://i.pinimg.com/474x/af/b1/63/afb16363561e9030a1514a5e0f99444f.jpg',
      bannerUrl:
          'https://i.pinimg.com/736x/50/54/b4/5054b4af988a1c4f88424193eac21720.jpg',
      likes: '42.1K+',
      genres: ['Classic', 'Comedy'],
      description:
          'A charming classic about an unexpected marriage of convenience that turns into a warm, hilarious journey of trust, friendship, and love.',
      languages: [MovieLanguage.malayalam],
      formats: [MovieFormat.twoD],
      cast: [
        CastMember(name: 'Mohanlal', role: 'Vishnu'),
        CastMember(name: 'Ranjini', role: 'Kalyani'),
        CastMember(name: 'Nedumudi Venu', role: 'Cast'),
        CastMember(name: 'Jagathy Sreekumar', role: 'Cast'),
      ],
      runtime: '2h 30m',
    ),
    Movie(
      id: 'premam',
      title: 'Premam',
      posterUrl:
          'https://i.pinimg.com/736x/f6/cd/6f/f6cd6f2a9f655ebe75247d0048bd4d89.jpg',
      bannerUrl:
          'https://i.pinimg.com/736x/76/7b/05/767b058fa36d7bc40a2251892045616e.jpg',
      likes: '86.4K+',
      genres: ['Romance', 'Drama'],
      description:
          'George David grows through three chapters of love, heartbreak, and self-discovery as life takes him from his hometown to new beginnings.',
      languages: [MovieLanguage.malayalam],
      formats: [MovieFormat.twoD, MovieFormat.threeD],
      cast: [
        CastMember(name: 'Nivin Pauly', role: 'George'),
        CastMember(name: 'Sai Pallavi', role: 'Malar'),
        CastMember(name: 'Anupama Parameswaran', role: 'Mary'),
        CastMember(name: 'Madonna Sebastian', role: 'Celine'),
      ],
      runtime: '2h 36m',
    ),
    Movie(
      id: 'kumbalangi-nights',
      title: 'Kumbalangi Nights',
      posterUrl:
          'https://i.pinimg.com/736x/84/bd/24/84bd24ad2f7360cc3c4226aad9183618.jpg',
      bannerUrl:
          'https://i.pinimg.com/736x/39/29/d7/3929d7573f5dc0f9add74043806ee28f.jpg',
      likes: '31.8K+',
      genres: ['Comedy', 'Romance'],
      description:
          'Four brothers with very different personalities navigate family tensions, new love, and second chances in the beautiful coastal village of Kumbalangi.',
      languages: [MovieLanguage.malayalam],
      formats: [MovieFormat.twoD],
      cast: [
        CastMember(name: 'Fahadh Faasil', role: 'Shammi'),
        CastMember(name: 'Soubin Shahir', role: 'Saji'),
        CastMember(name: 'Shane Nigam', role: 'Bobby'),
        CastMember(name: 'Anna Ben', role: 'Baby'),
      ],
      runtime: '2h 38m',
    ),
    Movie(
      id: 'nadodikkattu',
      title: 'Nadodikkattu',
      posterUrl:
          'https://i.pinimg.com/736x/06/25/99/0625997bf708e7cf115c5ba1947bff2a.jpg',
      bannerUrl:
          'https://i.pinimg.com/736x/d3/de/36/d3de361bb0f96948deef5ef54d6e34a9.jpg',
      likes: '18.6K+',
      genres: ['Mystery', 'Drama'],
      description:
          'When two jobless friends are tricked into believing they are headed to Dubai, their search for a better life becomes a wonderfully comic adventure.',
      languages: [MovieLanguage.malayalam],
      formats: [MovieFormat.twoD],
      cast: [
        CastMember(name: 'Mohanlal', role: 'Dasan'),
        CastMember(name: 'Sreenivasan', role: 'Vijayan'),
        CastMember(name: 'Shobana', role: 'Radha'),
        CastMember(name: 'Thilakan', role: 'Cast'),
      ],
      runtime: '2h 10m',
    ),
    Movie(
      id: 'bangalore-days',
      title: 'Bangalore Days',
      posterUrl:
          'https://i.pinimg.com/736x/ee/b3/94/eeb394ce18818d3fe5ee423e3feffb4e.jpg',
      bannerUrl:
          'https://i.pinimg.com/736x/d4/69/ff/d469ff3099c9ccec0926188398f4f856.jpg',
      likes: '74.5K+',
      genres: ['Drama', 'Romance'],
      description:
          'Three cousins reunite in Bangalore and find their ideas of love, ambition, and family changing as they chase new dreams in the city.',
      languages: [MovieLanguage.malayalam],
      formats: [MovieFormat.twoD, MovieFormat.threeD],
      cast: [
        CastMember(name: 'Dulquer Salmaan', role: 'Arjun'),
        CastMember(name: 'Nivin Pauly', role: 'Kuttan'),
        CastMember(name: 'Nazriya Nazim', role: 'Divya'),
        CastMember(name: 'Parvathy Thiruvothu', role: 'Sarah'),
      ],
      runtime: '2h 52m',
    ),
    Movie(
      id: 'ambili',
      title: 'Ambili',
      posterUrl:
          'https://i.pinimg.com/736x/65/88/94/6588945f9970de031a7e1a7dde580824.jpg',
      bannerUrl:
          'https://i.pinimg.com/736x/6f/b3/b1/6fb3b143e6547b03eea4ed5f6e46043b.jpg',
      likes: '28.9K+',
      genres: ['Romance', 'Family'],
      description:
          'A kind-hearted free spirit finds his world changing when a childhood friend returns, bringing old memories, new feelings, and a chance to grow up.',
      languages: [MovieLanguage.malayalam],
      formats: [MovieFormat.twoD, MovieFormat.threeD],
      cast: [
        CastMember(name: 'Soubin Shahir', role: 'Ambili'),
        CastMember(name: 'Tanvi Ram', role: 'Teena'),
        CastMember(name: 'Naveen Nazim', role: 'Boban'),
        CastMember(name: 'Jaffer Idukki', role: 'Cast'),
      ],
      runtime: '2h 22m',
    ),
  ];

  Movie movie(String id) =>
      movies.firstWhere((movie) => movie.id == id, orElse: () => movies[0]);

  List<Cinema> get cinemas => const [
    Cinema(
      id: 'pvr-forum',
      shortName: 'PVR',
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
    Cinema(
      id: 'inox-lulu',
      shortName: 'INOX',
      name: 'INOX: Lulu Mall, Edappally',
      showtimes: [
        Showtime(
          id: 'inox-09-10',
          time: '09:10 AM',
          experience: '2D',
          price: 240,
        ),
        Showtime(
          id: 'inox-11-40',
          time: '11:40 AM',
          experience: '3D',
          price: 340,
        ),
        Showtime(
          id: 'inox-02-20',
          time: '02:20 PM',
          experience: '2D',
          price: 260,
        ),
        Showtime(
          id: 'inox-05-05',
          time: '05:05 PM',
          experience: '3D',
          price: 340,
          fillingFast: true,
        ),
        Showtime(
          id: 'inox-08-15',
          time: '08:15 PM',
          experience: '2D',
          price: 280,
        ),
      ],
    ),
    Cinema(
      id: 'cinepolis-centre-square',
      shortName: 'CINEPOLIS',
      name: 'Cinepolis: Centre Square Mall, Kochi',
      showtimes: [
        Showtime(
          id: 'cinepolis-10-20',
          time: '10:20 AM',
          experience: '2D',
          price: 220,
        ),
        Showtime(
          id: 'cinepolis-01-15',
          time: '01:15 PM',
          experience: '3D',
          price: 320,
        ),
        Showtime(
          id: 'cinepolis-04-30',
          time: '04:30 PM',
          experience: '2D',
          price: 240,
          fillingFast: true,
        ),
        Showtime(
          id: 'cinepolis-07-45',
          time: '07:45 PM',
          experience: '3D',
          price: 350,
          soldOut: true,
        ),
        Showtime(
          id: 'cinepolis-10-35',
          time: '10:35 PM',
          experience: '2D',
          price: 220,
        ),
      ],
    ),
    Cinema(
      id: 'vanitha-vineetha',
      shortName: 'V&V',
      name: 'Vanitha-Vineetha Cineplex: MG Road, Kochi',
      cancellationAvailable: false,
      showtimes: [
        Showtime(
          id: 'vv-09-30',
          time: '09:30 AM',
          experience: '2D',
          price: 180,
        ),
        Showtime(
          id: 'vv-12-45',
          time: '12:45 PM',
          experience: '2D',
          price: 200,
        ),
        Showtime(
          id: 'vv-03-45',
          time: '03:45 PM',
          experience: '2D',
          price: 220,
          fillingFast: true,
        ),
        Showtime(
          id: 'vv-06-50',
          time: '06:50 PM',
          experience: '2D',
          price: 220,
        ),
        Showtime(
          id: 'vv-09-40',
          time: '09:40 PM',
          experience: '2D',
          price: 200,
        ),
      ],
    ),
  ];
}
