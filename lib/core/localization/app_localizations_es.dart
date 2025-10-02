import 'app_localizations.dart';

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Conecta';

  @override
  String get onboardingHeadline => 'Escucha, mira y conecta';

  @override
  String get onboardingSubheadline => 'Toda tu música, videos y radios en un solo lugar con retos y eventos en vivo.';

  @override
  String get onboardingGetStarted => 'Comenzar';

  @override
  String get onboardingAlreadyHaveAccount => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingHighlightsTitle => 'Tu universo de sonido.';

  @override
  String get onboardingFeatureLiveRadioTitle => 'Radio en vivo';

  @override
  String get onboardingFeatureLiveRadioDescription => 'Sintoniza radios favoritas y descubre nuevas emisoras 24/7.';

  @override
  String get onboardingFeatureUnlimitedMusicTitle => 'Música sin límites';

  @override
  String get onboardingFeatureUnlimitedMusicDescription => 'Crea playlists, descarga para escuchar offline y recibe recomendaciones personalizadas.';

  @override
  String get onboardingFeatureVideoTitle => 'Contenido VOD';

  @override
  String get onboardingFeatureVideoDescription => 'Entrevistas exclusivas, conciertos completos y eventos en streaming.';

  @override
  String get onboardingAccountTitle => 'Crea tu cuenta';

  @override
  String get onboardingAccountSubtitle => 'Elige cómo quieres empezar a escuchar y conectar.';

  @override
  String get onboardingAccountOptionListener => 'Iniciar sesión como oyente';

  @override
  String get onboardingAccountOptionListenerDescription => 'Accede a playlists, retos y recompensas.';

  @override
  String get onboardingAccountOptionStation => 'Iniciar sesión en una radio';

  @override
  String get onboardingAccountOptionStationDescription => 'Administra emisiones, programación y tu comunidad.';

  @override
  String get onboardingExploreAsGuest => 'Explorar como invitado';

  @override
  String get onboardingRadioTitle => 'Selecciona tu radio';

  @override
  String get onboardingRadioSubtitle => 'Elige una radio para iniciar sesión y continuar.';

  @override
  String get onboardingRadioSearchHint => 'Buscar radio...';

  @override
  String onboardingRadioContinue(Object station) {
    return 'Iniciar sesión en $station';
  }

  @override
  String get onboardingRadioContinueDisabled => 'Selecciona una radio para continuar';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginEmail => 'Correo electrónico';

  @override
  String get loginPassword => 'Contraseña';

  @override
  String get loginSignIn => 'Entrar';

  @override
  String get loginGoogle => 'Continuar con Google';

  @override
  String get loginApple => 'Continuar con Apple';

  @override
  String get loginNoAccount => '¿Nuevo en Conecta?';

  @override
  String homeGreeting(Object name) {
    return 'Hola, $name';
  }

  @override
  String get homeFeaturedPlaylists => 'Listas destacadas';

  @override
  String get homeLiveRadios => 'Radios en vivo';

  @override
  String get homeTrendingVideos => 'Videos en tendencia';

  @override
  String get homeRecommendedForYou => 'Recomendado para ti';

  @override
  String get homeContests => 'Concursos';

  @override
  String get homeEvents => 'Eventos';

  @override
  String get homeChallenges => 'Retos';

  @override
  String get homeRadioChats => 'Chat en la radio';

  @override
  String get homeActionViewDetails => 'Ver detalles';

  @override
  String get homeActionJoinNow => 'Unirse ahora';

  @override
  String get homeActionStartChallenge => 'Aceptar reto';

  @override
  String get homeVodHighlights => 'VOD';

  @override
  String get homeMusicHighlights => 'Música';

  @override
  String get searchPlaceholder => '¿Qué quieres escuchar hoy?';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get libraryFavorites => 'Favoritos';

  @override
  String get libraryDownloads => 'Descargas';

  @override
  String get libraryRecent => 'Recientes';

  @override
  String get gamificationTitle => 'Logros';

  @override
  String gamificationPoints(Object points) {
    return '$points puntos';
  }

  @override
  String get gamificationActiveChallenges => 'Retos activos';

  @override
  String get gamificationBadges => 'Insignias';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get eventsTitle => 'Eventos';

  @override
  String get eventsUpcoming => 'Próximos eventos';

  @override
  String get eventsJoinChat => 'Entrar al chat';

  @override
  String get notificationsTitle => 'Alertas';

  @override
  String get notificationsEmpty => 'Aún no tienes notificaciones';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileSettings => 'Ajustes';

  @override
  String get profilePreferences => 'Preferencias';

  @override
  String get profileProgress => 'Progreso';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get stateLoading => 'Cargando...';

  @override
  String get stateError => 'Algo salió mal';

  @override
  String get nowPlayingTitle => 'Reproduciendo ahora';

  @override
  String get offlineBanner => 'Estás sin conexión. Tus cambios se sincronizarán luego.';

  @override
  String get onlineBanner => 'Vuelves a estar en línea. Sincronizando...';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get searchTitle => 'Explorar';
}
