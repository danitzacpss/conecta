import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Conecta';

  @override
  String get onboardingHeadline => 'Listen, watch and connect';

  @override
  String get onboardingSubheadline => 'All your music, videos and live radios in one place with challenges and events.';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingHighlightsTitle => 'Your sound universe.';

  @override
  String get onboardingFeatureLiveRadioTitle => 'Live radio';

  @override
  String get onboardingFeatureLiveRadioDescription => 'Tune in to your favorite stations and discover new shows around the clock.';

  @override
  String get onboardingFeatureUnlimitedMusicTitle => 'Unlimited music';

  @override
  String get onboardingFeatureUnlimitedMusicDescription => 'Build playlists, download for offline listening and get tailored recommendations.';

  @override
  String get onboardingFeatureVideoTitle => 'VOD content';

  @override
  String get onboardingFeatureVideoDescription => 'Exclusive interviews, full concerts and streaming events.';

  @override
  String get onboardingAccountTitle => 'Create your account';

  @override
  String get onboardingAccountSubtitle => 'Choose how you want to start listening and connecting.';

  @override
  String get onboardingAccountOptionListener => 'Sign in as listener';

  @override
  String get onboardingAccountOptionListenerDescription => 'Access playlists, challenges and rewards.';

  @override
  String get onboardingAccountOptionStation => 'Sign in as a station';

  @override
  String get onboardingAccountOptionStationDescription => 'Manage broadcasts, programming and your community.';

  @override
  String get onboardingExploreAsGuest => 'Explore as guest';

  @override
  String get onboardingRadioTitle => 'Select your station';

  @override
  String get onboardingRadioSubtitle => 'Pick a station to sign in and continue.';

  @override
  String get onboardingRadioSearchHint => 'Search station...';

  @override
  String onboardingRadioContinue(Object station) {
    return 'Sign in to $station';
  }

  @override
  String get onboardingRadioContinueDisabled => 'Select a station to continue';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get loginApple => 'Continue with Apple';

  @override
  String get loginNoAccount => 'New to Conecta?';

  @override
  String homeGreeting(Object name) {
    return 'Hi, $name';
  }

  @override
  String get homeFeaturedPlaylists => 'Featured playlists';

  @override
  String get homeLiveRadios => 'Live radios';

  @override
  String get homeTrendingVideos => 'Trending videos';

  @override
  String get homeRecommendedForYou => 'Recommended for you';

  @override
  String get homeContests => 'Contests';

  @override
  String get homeEvents => 'Events';

  @override
  String get homeChallenges => 'Challenges';

  @override
  String get homeRadioChats => 'Radio chat';

  @override
  String get homeActionViewDetails => 'View details';

  @override
  String get homeActionJoinNow => 'Join now';

  @override
  String get homeActionStartChallenge => 'Start challenge';

  @override
  String get homeVodHighlights => 'VOD';

  @override
  String get homeMusicHighlights => 'Music';

  @override
  String get searchPlaceholder => 'What do you want to play today?';

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryFavorites => 'Favorites';

  @override
  String get libraryDownloads => 'Downloads';

  @override
  String get libraryRecent => 'Recent';

  @override
  String get gamificationTitle => 'Achievements';

  @override
  String gamificationPoints(Object points) {
    return '$points points';
  }

  @override
  String get gamificationActiveChallenges => 'Active challenges';

  @override
  String get gamificationBadges => 'Badges';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get eventsTitle => 'Events';

  @override
  String get eventsUpcoming => 'Upcoming events';

  @override
  String get eventsJoinChat => 'Join chat';

  @override
  String get notificationsTitle => 'Alerts';

  @override
  String get notificationsEmpty => 'You have no notifications yet';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profilePreferences => 'Preferences';

  @override
  String get profileProgress => 'Progress';

  @override
  String get actionRetry => 'Retry';

  @override
  String get stateLoading => 'Loading...';

  @override
  String get stateError => 'Something went wrong';

  @override
  String get nowPlayingTitle => 'Now playing';

  @override
  String get offlineBanner => 'You are offline. Changes will sync later.';

  @override
  String get onlineBanner => 'Back online. Syncing...';

  @override
  String get homeTitle => 'Home';

  @override
  String get searchTitle => 'Explore';
}
