import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:conecta_app/features/home/domain/entities/media_item.dart';

final homeControllerProvider =
    StateNotifierProvider<HomeController, AsyncValue<HomeContent>>(
  (ref) => HomeController()..load(),
);

class HomeController extends StateNotifier<AsyncValue<HomeContent>> {
  HomeController() : super(const AsyncValue.loading());

  Future<void> load() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      state = AsyncValue.data(
        HomeContent(
          heroChallenge: const HomeHighlight(
            id: 'hero-1',
            title: 'Reto 21 días de creación',
            subtitle: 'Completa 21 mini retos musicales y desbloquea premios',
            actionLabel: 'Ver reto',
            progress: 0.45,
            daysLeft: 12,
            icon: Icons.track_changes_rounded,
            color: Color(0xFF7E57C2),
          ),
          challenges: const [
            HomeAction(
              id: 'challenge-1',
              title: 'Sample Quest',
              subtitle: 'Descarga el pack y sube tu beat',
              actionLabel: 'Aceptar reto',
              icon: Icons.graphic_eq_rounded,
              color: Color(0xFF26C6DA),
              progress: 0.7,
              meta: '3/5 misiones completadas',
            ),
            HomeAction(
              id: 'challenge-2',
              title: 'Sesión en vivo',
              subtitle: 'Programa 2 transmisiones esta semana',
              actionLabel: 'Aceptar reto',
              icon: Icons.schedule_rounded,
              color: Color(0xFFAB47BC),
              progress: 0.3,
              meta: 'Quedan 4 días',
            ),
            HomeAction(
              id: 'challenge-3',
              title: 'Descubre VOD',
              subtitle: 'Reproduce 4 entrevistas exclusivas',
              actionLabel: 'Aceptar reto',
              icon: Icons.video_library_rounded,
              color: Color(0xFFFF8A65),
              progress: 0.5,
              meta: '2/4 vistas',
            ),
          ],
          contests: const [
            HomeAction(
              id: 'contest-1',
              title: 'Beat Masters',
              subtitle: 'Envía tu remix antes del 28 de abril',
              actionLabel: 'Ver detalles',
              icon: Icons.emoji_events_rounded,
              color: Color(0xFF7E57C2),
              meta: 'Premio: Sesión en estudio',
            ),
            HomeAction(
              id: 'contest-2',
              title: 'Cover Challenge',
              subtitle: 'Graba tu versión acústica',
              actionLabel: 'Ver detalles',
              icon: Icons.mic_external_on_rounded,
              color: Color(0xFF26A69A),
              meta: 'Fecha límite: 12 mayo',
            ),
          ],
          events: const [
            HomeEvent(
              id: 'event-1',
              title: 'Sunset Rooftop',
              subtitle: 'Streaming + presencia • 7:00 p. m.',
              actionLabel: 'Reservar',
              icon: Icons.event_available_rounded,
              color: Color(0xFFFF8A65),
              date: 'Vie 12 Abr',
              location: 'CDMX & Online',
            ),
            HomeEvent(
              id: 'event-2',
              title: 'Conecta Fest',
              subtitle: '3 escenarios • 25 artistas',
              actionLabel: 'Reservar',
              icon: Icons.festival_rounded,
              color: Color(0xFF5C6BC0),
              date: 'Sáb 27 Abr',
              location: 'Parque Digital',
            ),
            HomeEvent(
              id: 'event-3',
              title: 'Live Jam Studios',
              subtitle: 'Jam colaborativo en vivo',
              actionLabel: 'Recordar',
              icon: Icons.music_video_rounded,
              color: Color(0xFF26C6DA),
              date: 'Dom 28 Abr',
              location: 'Streaming',
            ),
          ],
          radioChats: const [
            HomeAction(
              id: 'chat-1',
              title: 'Radio Corazón',
              subtitle: 'Chat en vivo con la audiencia',
              actionLabel: 'Unirse ahora',
              icon: Icons.chat_bubble_rounded,
              color: Color(0xFFFF7043),
            ),
            HomeAction(
              id: 'chat-2',
              title: 'Urban Beat Live',
              subtitle: 'Pide tu freestyle en vivo',
              actionLabel: 'Unirse ahora',
              icon: Icons.headset_mic_rounded,
              color: Color(0xFFFFCA28),
            ),
          ],
          liveRadios: List.generate(
            4,
            (index) => MediaItem(
              id: 'radio-$index',
              title: 'Radio Beats $index',
              artists: const ['Live'],
              artworkUrl: 'https://picsum.photos/seed/radio$index/400/400',
              type: MediaType.radio,
              isLive: true,
            ),
          ),
          vodReleases: List.generate(
            5,
            (index) => MediaItem(
              id: 'vod-$index',
              title: 'Backstage Stories #$index',
              artists: const ['Conecta VOD'],
              artworkUrl: 'https://picsum.photos/seed/vod$index/400/400',
              type: MediaType.video,
              duration: const Duration(minutes: 35),
            ),
          ),
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class HomeContent {
  HomeContent({
    this.heroChallenge,
    required this.challenges,
    required this.contests,
    required this.events,
    required this.radioChats,
    required this.liveRadios,
    required this.vodReleases,
  });

  final HomeHighlight? heroChallenge;
  final List<HomeAction> challenges;
  final List<HomeAction> contests;
  final List<HomeEvent> events;
  final List<HomeAction> radioChats;
  final List<MediaItem> liveRadios;
  final List<MediaItem> vodReleases;
}

class HomeAction {
  const HomeAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.color,
    this.progress,
    this.meta,
  });

  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final Color color;
  final double? progress;
  final String? meta;
}

class HomeEvent {
  const HomeEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.color,
    required this.date,
    required this.location,
  });

  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final Color color;
  final String date;
  final String location;
}

class HomeHighlight {
  const HomeHighlight({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.color,
    required this.progress,
    required this.daysLeft,
  });

  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final Color color;
  final double progress;
  final int daysLeft;
}
