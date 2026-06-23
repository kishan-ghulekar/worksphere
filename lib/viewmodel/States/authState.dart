import 'package:equatable/equatable.dart';
import 'package:super_project/model/projectModel.dart';
import 'package:super_project/model/userModel.dart';
import 'package:super_project/viewmodel/States/projectState.dart';


abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Nothing has happened yet — initial state when the app starts.
class AuthInitial extends AuthState {}

/// A request (login or register) is in progress — show a spinner.
class AuthLoading extends AuthState {}

/// Login or register succeeded — carries the logged-in user's profile.
class AuthSuccess extends AuthState {
  final UserModel user;
  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Something went wrong — carries a user-facing message.
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// No user is signed in — shown after logout or on a fresh app start
/// with no existing session.
class AuthLoggedOut extends AuthState {}
// Add this to your existing states file
class AllProjectsLoadSuccess extends ProjectState {
  final List<ProjectModel> projects;
  const AllProjectsLoadSuccess(this.projects);

  @override
  List<Object?> get props => [projects];
}