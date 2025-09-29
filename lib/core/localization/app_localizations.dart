import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Conecta'**
  String get appTitle;

  /// No description provided for @onboardingHeadline.
  ///
  /// In es, this message translates to:
  /// **'Escucha, mira y conecta'**
  String get onboardingHeadline;

  /// No description provided for @onboardingSubheadline.
  ///
  /// In es, this message translates to:
  /// **'Toda tu música, videos y radios en un solo lugar con retos y eventos en vivo.'**
  String get onboardingSubheadline;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingAlreadyHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes una cuenta? Inicia sesión'**
  String get onboardingAlreadyHaveAccount;

  /// No description provided for @onboardingSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get onboardingSkip;

  /// No description provided for @onboardingBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get onboardingNext;

  /// No description provided for @onboardingContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get onboardingContinue;

  /// No description provided for @onboardingHighlightsTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu universo de sonido.'**
  String get onboardingHighlightsTitle;

  /// No description provided for @onboardingFeatureLiveRadioTitle.
  ///
  /// In es, this message translates to:
  /// **'Radio en vivo'**
  String get onboardingFeatureLiveRadioTitle;

  /// No description provided for @onboardingFeatureLiveRadioDescription.
  ///
  /// In es, this message translates to:
  /// **'Sintoniza radios favoritas y descubre nuevas emisoras 24/7.'**
  String get onboardingFeatureLiveRadioDescription;

  /// No description provided for @onboardingFeatureUnlimitedMusicTitle.
  ///
  /// In es, this message translates to:
  /// **'Música sin límites'**
  String get onboardingFeatureUnlimitedMusicTitle;

  /// No description provided for @onboardingFeatureUnlimitedMusicDescription.
  ///
  /// In es, this message translates to:
  /// **'Crea playlists, descarga para escuchar offline y recibe recomendaciones personalizadas.'**
  String get onboardingFeatureUnlimitedMusicDescription;

  /// No description provided for @onboardingFeatureVideoTitle.
  ///
  /// In es, this message translates to:
  /// **'Contenido VOD'**
  String get onboardingFeatureVideoTitle;

  /// No description provided for @onboardingFeatureVideoDescription.
  ///
  /// In es, this message translates to:
  /// **'Entrevistas exclusivas, conciertos completos y eventos en streaming.'**
  String get onboardingFeatureVideoDescription;

  /// No description provided for @onboardingAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get onboardingAccountTitle;

  /// No description provided for @onboardingAccountSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige cómo quieres empezar a escuchar y conectar.'**
  String get onboardingAccountSubtitle;

  /// No description provided for @onboardingAccountOptionListener.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión como oyente'**
  String get onboardingAccountOptionListener;

  /// No description provided for @onboardingAccountOptionListenerDescription.
  ///
  /// In es, this message translates to:
  /// **'Accede a playlists, retos y recompensas.'**
  String get onboardingAccountOptionListenerDescription;

  /// No description provided for @onboardingAccountOptionStation.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión en una radio'**
  String get onboardingAccountOptionStation;

  /// No description provided for @onboardingAccountOptionStationDescription.
  ///
  /// In es, this message translates to:
  /// **'Administra emisiones, programación y tu comunidad.'**
  String get onboardingAccountOptionStationDescription;

  /// No description provided for @onboardingExploreAsGuest.
  ///
  /// In es, this message translates to:
  /// **'Explorar como invitado'**
  String get onboardingExploreAsGuest;

  /// No description provided for @onboardingRadioTitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu radio'**
  String get onboardingRadioTitle;

  /// No description provided for @onboardingRadioSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige una radio para iniciar sesión y continuar.'**
  String get onboardingRadioSubtitle;

  /// No description provided for @onboardingRadioSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar radio...'**
  String get onboardingRadioSearchHint;

  /// No description provided for @onboardingRadioContinue.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión en {station}'**
  String onboardingRadioContinue(Object station);

  /// No description provided for @onboardingRadioContinueDisabled.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una radio para continuar'**
  String get onboardingRadioContinueDisabled;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginTitle;

  /// No description provided for @loginEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get loginPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get loginSignIn;

  /// No description provided for @loginGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get loginGoogle;

  /// No description provided for @loginApple.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Apple'**
  String get loginApple;

  /// No description provided for @loginNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Nuevo en Conecta?'**
  String get loginNoAccount;

  /// No description provided for @homeGreeting.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String homeGreeting(Object name);

  /// No description provided for @homeFeaturedPlaylists.
  ///
  /// In es, this message translates to:
  /// **'Listas destacadas'**
  String get homeFeaturedPlaylists;

  /// No description provided for @homeLiveRadios.
  ///
  /// In es, this message translates to:
  /// **'Radios en vivo'**
  String get homeLiveRadios;

  /// No description provided for @homeTrendingVideos.
  ///
  /// In es, this message translates to:
  /// **'Videos en tendencia'**
  String get homeTrendingVideos;

  /// No description provided for @homeRecommendedForYou.
  ///
  /// In es, this message translates to:
  /// **'Recomendado para ti'**
  String get homeRecommendedForYou;

  /// No description provided for @homeContests.
  ///
  /// In es, this message translates to:
  /// **'Concursos'**
  String get homeContests;

  /// No description provided for @homeEvents.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get homeEvents;

  /// No description provided for @homeChallenges.
  ///
  /// In es, this message translates to:
  /// **'Retos'**
  String get homeChallenges;

  /// No description provided for @homeRadioChats.
  ///
  /// In es, this message translates to:
  /// **'Chat en la radio'**
  String get homeRadioChats;

  /// No description provided for @homeActionViewDetails.
  ///
  /// In es, this message translates to:
  /// **'Ver detalles'**
  String get homeActionViewDetails;

  /// No description provided for @homeActionJoinNow.
  ///
  /// In es, this message translates to:
  /// **'Unirse ahora'**
  String get homeActionJoinNow;

  /// No description provided for @homeActionStartChallenge.
  ///
  /// In es, this message translates to:
  /// **'Aceptar reto'**
  String get homeActionStartChallenge;

  /// No description provided for @homeVodHighlights.
  ///
  /// In es, this message translates to:
  /// **'Video on demand'**
  String get homeVodHighlights;

  /// No description provided for @homeMusicHighlights.
  ///
  /// In es, this message translates to:
  /// **'Música'**
  String get homeMusicHighlights;

  /// No description provided for @searchPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'¿Qué quieres escuchar hoy?'**
  String get searchPlaceholder;

  /// No description provided for @libraryTitle.
  ///
  /// In es, this message translates to:
  /// **'Biblioteca'**
  String get libraryTitle;

  /// No description provided for @libraryFavorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get libraryFavorites;

  /// No description provided for @libraryDownloads.
  ///
  /// In es, this message translates to:
  /// **'Descargas'**
  String get libraryDownloads;

  /// No description provided for @libraryRecent.
  ///
  /// In es, this message translates to:
  /// **'Recientes'**
  String get libraryRecent;

  /// No description provided for @gamificationTitle.
  ///
  /// In es, this message translates to:
  /// **'Logros'**
  String get gamificationTitle;

  /// No description provided for @gamificationPoints.
  ///
  /// In es, this message translates to:
  /// **'{points} puntos'**
  String gamificationPoints(Object points);

  /// No description provided for @gamificationActiveChallenges.
  ///
  /// In es, this message translates to:
  /// **'Retos activos'**
  String get gamificationActiveChallenges;

  /// No description provided for @gamificationBadges.
  ///
  /// In es, this message translates to:
  /// **'Insignias'**
  String get gamificationBadges;

  /// No description provided for @leaderboardTitle.
  ///
  /// In es, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @eventsTitle.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get eventsTitle;

  /// No description provided for @eventsUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Próximos eventos'**
  String get eventsUpcoming;

  /// No description provided for @eventsJoinChat.
  ///
  /// In es, this message translates to:
  /// **'Entrar al chat'**
  String get eventsJoinChat;

  /// No description provided for @notificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes notificaciones'**
  String get notificationsEmpty;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @profileSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get profileSettings;

  /// No description provided for @profilePreferences.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get profilePreferences;

  /// No description provided for @profileProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get profileProgress;

  /// No description provided for @actionRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get actionRetry;

  /// No description provided for @stateLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get stateLoading;

  /// No description provided for @stateError.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal'**
  String get stateError;

  /// No description provided for @nowPlayingTitle.
  ///
  /// In es, this message translates to:
  /// **'Reproduciendo ahora'**
  String get nowPlayingTitle;

  /// No description provided for @offlineBanner.
  ///
  /// In es, this message translates to:
  /// **'Estás sin conexión. Tus cambios se sincronizarán luego.'**
  String get offlineBanner;

  /// No description provided for @onlineBanner.
  ///
  /// In es, this message translates to:
  /// **'Vuelves a estar en línea. Sincronizando...'**
  String get onlineBanner;

  /// No description provided for @homeTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeTitle;

  /// No description provided for @searchTitle.
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get searchTitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
