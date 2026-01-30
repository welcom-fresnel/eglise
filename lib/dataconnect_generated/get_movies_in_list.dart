part of 'generated.dart';

class GetMoviesInListVariablesBuilder {
  String listId;

  final FirebaseDataConnect _dataConnect;
  GetMoviesInListVariablesBuilder(this._dataConnect, {required  this.listId,});
  Deserializer<GetMoviesInListData> dataDeserializer = (dynamic json)  => GetMoviesInListData.fromJson(jsonDecode(json));
  Serializer<GetMoviesInListVariables> varsSerializer = (GetMoviesInListVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetMoviesInListData, GetMoviesInListVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetMoviesInListData, GetMoviesInListVariables> ref() {
    GetMoviesInListVariables vars= GetMoviesInListVariables(listId: listId,);
    return _dataConnect.query("GetMoviesInList", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetMoviesInListList {
  final List<GetMoviesInListListMoviesViaListMovie> movies_via_ListMovie;
  GetMoviesInListList.fromJson(dynamic json):
  
  movies_via_ListMovie = (json['movies_via_ListMovie'] as List<dynamic>)
        .map((e) => GetMoviesInListListMoviesViaListMovie.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMoviesInListList otherTyped = other as GetMoviesInListList;
    return movies_via_ListMovie == otherTyped.movies_via_ListMovie;
    
  }
  @override
  int get hashCode => movies_via_ListMovie.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['movies_via_ListMovie'] = movies_via_ListMovie.map((e) => e.toJson()).toList();
    return json;
  }

  GetMoviesInListList({
    required this.movies_via_ListMovie,
  });
}

@immutable
class GetMoviesInListListMoviesViaListMovie {
  final String id;
  final String title;
  final int year;
  final List<String>? genres;
  final int? runtime;
  final String? summary;
  GetMoviesInListListMoviesViaListMovie.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  year = nativeFromJson<int>(json['year']),
  genres = json['genres'] == null ? null : (json['genres'] as List<dynamic>)
        .map((e) => nativeFromJson<String>(e))
        .toList(),
  runtime = json['runtime'] == null ? null : nativeFromJson<int>(json['runtime']),
  summary = json['summary'] == null ? null : nativeFromJson<String>(json['summary']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMoviesInListListMoviesViaListMovie otherTyped = other as GetMoviesInListListMoviesViaListMovie;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    year == otherTyped.year && 
    genres == otherTyped.genres && 
    runtime == otherTyped.runtime && 
    summary == otherTyped.summary;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, year.hashCode, genres.hashCode, runtime.hashCode, summary.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['year'] = nativeToJson<int>(year);
    if (genres != null) {
      json['genres'] = genres?.map((e) => nativeToJson<String>(e)).toList();
    }
    if (runtime != null) {
      json['runtime'] = nativeToJson<int?>(runtime);
    }
    if (summary != null) {
      json['summary'] = nativeToJson<String?>(summary);
    }
    return json;
  }

  GetMoviesInListListMoviesViaListMovie({
    required this.id,
    required this.title,
    required this.year,
    this.genres,
    this.runtime,
    this.summary,
  });
}

@immutable
class GetMoviesInListData {
  final GetMoviesInListList? list;
  GetMoviesInListData.fromJson(dynamic json):
  
  list = json['list'] == null ? null : GetMoviesInListList.fromJson(json['list']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMoviesInListData otherTyped = other as GetMoviesInListData;
    return list == otherTyped.list;
    
  }
  @override
  int get hashCode => list.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (list != null) {
      json['list'] = list!.toJson();
    }
    return json;
  }

  GetMoviesInListData({
    this.list,
  });
}

@immutable
class GetMoviesInListVariables {
  final String listId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetMoviesInListVariables.fromJson(Map<String, dynamic> json):
  
  listId = nativeFromJson<String>(json['listId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetMoviesInListVariables otherTyped = other as GetMoviesInListVariables;
    return listId == otherTyped.listId;
    
  }
  @override
  int get hashCode => listId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['listId'] = nativeToJson<String>(listId);
    return json;
  }

  GetMoviesInListVariables({
    required this.listId,
  });
}

