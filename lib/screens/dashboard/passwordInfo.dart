class PasswordInfo {
  final int id;
  final String passwordName, username, email, application, url;

  final String password = '';

  PasswordInfo(this.id, this.passwordName, this.username, this.email,
      this.application, this.url);

  String generatePassword(
      bool letters, bool numbers, bool symbols, int length) {
    return '';
  }
}
