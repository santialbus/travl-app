import '../repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repository;
  SignOut(this.repository);

  Future call() => repository.signOut();
}
