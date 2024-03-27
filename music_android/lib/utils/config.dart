class Config {
  //TODO NORMAL CONFIG!!!

  static const String URL = 'https://4e56-213-137-244-1.ngrok-free.app';

  static final TrackEndpoints trackEndpoints = TrackEndpoints(URL);
  static final PlaylistEndpoints playlistEndpoints = PlaylistEndpoints(URL);
}

class TrackEndpoints {
  TrackEndpoints(String URL) {
    get = "$URL/tracks/get";
    upload = "$URL/tracks/upload";
    update = (String id) => "$URL/tracks/update/$id";
  }

  late final String get;
  late final String upload;
  late final String Function(String) update;
}

class PlaylistEndpoints {
  PlaylistEndpoints(String URL) {
    get = "$URL/playlists/get";
    getById = (String id) => "$URL/playlists/get/$id";
    create = "$URL/playlists/create";
    add = (String id) => "$URL/playlists/add/$id";
  }

  late final String get;
  late final String Function(String) getById;
  late final String create;
  late final String Function(String) add;
}
