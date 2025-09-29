import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState.unknown());

  Future<void> signInWithEmail(
      {required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    // TODO(anyone): Hook into FirebaseAuth
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = const AuthState.authenticated();
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    // TODO(anyone): Implement Google sign-in
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = const AuthState.authenticated();
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading);
    // TODO(anyone): Implement Apple sign-in
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = const AuthState.authenticated();
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    state = const AuthState.unauthenticated();
  }
}

enum AuthStatus { unknown, loading, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState._({required this.status});

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.authenticated() : this._(status: AuthStatus.authenticated);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  final AuthStatus status;

  AuthState copyWith({AuthStatus? status}) {
    return AuthState._(status: status ?? this.status);
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;

  bool get isLoading => status == AuthStatus.loading;

  @override
  List<Object?> get props => [status];
}
