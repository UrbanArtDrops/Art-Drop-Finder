import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:art_drop_finder/features/auth/data/datasources/auth_appwrite_data_source.dart';
import 'package:art_drop_finder/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:art_drop_finder/features/auth/domain/usecases/login_artist.dart';
import 'package:art_drop_finder/features/auth/presentation/controllers/auth_controller.dart';
import 'package:art_drop_finder/features/drops/data/datasources/art_drop_remote_data_source.dart';
import 'package:art_drop_finder/features/drops/data/datasources/drop_extras_remote_data_source.dart';
import 'package:art_drop_finder/features/drops/data/repositories/art_drop_repository_impl.dart';
import 'package:art_drop_finder/features/drops/data/repositories/drop_extras_repository_impl.dart';
import 'package:art_drop_finder/features/drops/data/services/image_storage.dart';
import 'package:art_drop_finder/features/drops/data/services/location_service.dart';
import 'package:art_drop_finder/features/drops/data/services/social_publisher.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/create_art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/create_drop_claim.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/create_drop_image.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/delete_art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/delete_drop_image.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/list_drop_claims.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/list_art_drops.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/list_drop_images.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/list_social_posts.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/mark_all_found.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/update_art_drop.dart';
import 'package:art_drop_finder/features/drops/domain/usecases/update_drops_available.dart';
import 'package:art_drop_finder/features/drops/presentation/controllers/drops_controller.dart';
import 'package:art_drop_finder/features/drops/presentation/pages/claim_drop_page.dart';
import 'package:art_drop_finder/features/drops/presentation/pages/drops_home_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final DropsController _controller;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();

    final authRepository = AuthRepositoryImpl(AuthAppwriteDataSource());
    _authController = AuthController(LoginArtist(authRepository));

    final repository = ArtDropRepositoryImpl(ArtDropRemoteDataSource());
    final extrasRepository =
        DropExtrasRepositoryImpl(DropExtrasRemoteDataSource());
    _controller = DropsController(
      createArtDrop: CreateArtDrop(repository),
      createDropClaim: CreateDropClaim(extrasRepository),
      createDropImage: CreateDropImage(extrasRepository),
      deleteArtDrop: DeleteArtDrop(repository),
      deleteDropImage: DeleteDropImage(extrasRepository),
      listArtDrops: ListArtDrops(repository),
      listDropClaims: ListDropClaims(extrasRepository),
      listDropImages: ListDropImages(extrasRepository),
      listSocialPosts: ListSocialPosts(extrasRepository),
      updateArtDrop: UpdateArtDrop(repository),
      updateDropsAvailable: UpdateDropsAvailable(repository),
      markAllFound: MarkAllFound(repository),
      socialPublisher: const SocialPublisher(),
      locationService: const LocationService(),
      imageStorage: ImageStorage(),
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Art Drop Finder',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales:
          WidgetsBinding.instance.platformDispatcher.locales.isNotEmpty
              ? WidgetsBinding.instance.platformDispatcher.locales
              : const <Locale>[Locale('en', 'US')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        final name = settings.name;
        if (name == null || name.isEmpty) {
          return null;
        }
        final uri = Uri.parse(name);
        Uri effectiveUri = uri;
        if ((uri.path.isEmpty || uri.path == '/') && uri.fragment.isNotEmpty) {
          final fragment = uri.fragment.startsWith('/')
              ? uri.fragment
              : '/${uri.fragment}';
          effectiveUri = Uri.parse(fragment);
        }
        if (effectiveUri.path == '/claim') {
          final dropId = effectiveUri.queryParameters['dropId'];
          if (dropId == null || dropId.trim().isEmpty) {
            return MaterialPageRoute(
              builder: (_) => const _InvalidClaimPage(),
            );
          }
          return MaterialPageRoute(
            builder: (_) => ClaimDropPage(
              controller: _controller,
              dropId: dropId,
            ),
          );
        }
        return null;
      },
      home: DropsHomePage(
        controller: _controller,
        authController: _authController,
      ),
    );
  }
}

class _InvalidClaimPage extends StatelessWidget {
  const _InvalidClaimPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drop beanspruchen')),
      body: const Center(child: Text('Ungueltiger Link.')),
    );
  }
}
