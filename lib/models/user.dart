class User {
  int _id = 0;
  String _username = '', _token = '';

  void setUserInfo(int id, String username, token) {
    _username = username;
    _token = token;
    _id = id;
  }

  void logOut() {
    _username = '';
    _token = '';
    _id = 0;
  }

  String getToken() {
    return _token;
  }

  String getUsername() {
    return _username;
  }

  int getUserId() {
    return _id;
  }
}
