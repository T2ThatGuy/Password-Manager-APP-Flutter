class User {
  String _username = '', _token = '';

  void setUserInfo(String username, token) {
    _username = username;
    _token = token;
  }

  void logOut() {
    _username = '';
    _token = '';
  }

  String getToken() {
    return _token;
  }

  String getUsername() {
    return _username;
  }
}
