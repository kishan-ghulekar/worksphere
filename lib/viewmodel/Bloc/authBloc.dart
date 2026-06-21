import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/repository/authRepository.dart';
import 'package:super_project/viewmodel/Events/authEvent.dart';
import 'package:super_project/viewmodel/States/authState.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<RegisterRequested>(_onRegisterRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.registerUser(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
      );
      emit(AuthSuccess(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      emit(AuthFailure("Something went wrong: $e"));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.loginUser(
        email: event.email,
        password: event.password,
      );
      emit(AuthSuccess(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      emit(AuthFailure("Something went wrong: $e"));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(AuthLoggedOut());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final user = await authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthSuccess(user));
    } else {
      emit(AuthLoggedOut());
    }
  }

  /// Same specific error messages your original screens already had —
  /// centralized here so both login and register use identical wording.
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "An account already exists for that email.";
      case 'weak-password':
        return "Password is too weak. Use at least 6 characters.";
      case 'invalid-email':
        return "That email address looks invalid.";
      case 'user-not-found':
        return "No account found with that email.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'invalid-credential':
        return "Email or password is incorrect.";
      case 'too-many-requests':
        return "Too many attempts. Please try again later.";
      case 'user-disabled':
        return "This account has been disabled.";
      default:
        return e.message ?? "Authentication failed. Please try again.";
    }
  }
}