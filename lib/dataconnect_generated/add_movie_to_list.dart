part of 'generated.dart';

class AddMovieToListVariablesBuilder {
  String listId;
  String movieId;
  Optional<String> _note = Optional.optional(nativeFromJson, nativeToJson);
  int position;

  final FirebaseDataConnect _dataConnect;  AddMovieToListVariablesBuilder note(String? t) {
   _note.value = t;
   return this;
  }

  AddMovieToListVariablesBuilder(this._dataConnect, {required  this.listId,required  this.movieId,required  this.position,});
  Deserializer<AddMovieToListData> dataDeserializer = (dynamic json)  => AddMovieToListData.fromJson(jsonDecode(json));
  Serializer<AddMovieToListVariables> varsSerializer = (AddMovieToListVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddMovieToListData, AddMovieToListVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddMovieToListData, AddMovieToListVariables> ref() {
    AddMovieToListVariables vars= AddMovieToListVariables(listId: listId,movieId: movieId,note: _note,position: position,);
    return _dataConnect.mutation("AddMovieToList", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddMovieToListListMovieInsert {
  final String listId;
  final String movieId;
  AddMovieToListListMovieInsert.fromJson(dynamic json):
  
  listId = nativeFromJson<String>(json['listId']),
  movieId = nativeFromJson<String>(json['movieId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddMovieToListListMovieInsert otherTyped = other as AddMovieToListListMovieInsert;
    return listId == otherTyped.listId && 
    movieId == otherTyped.movieId;
    
  }
  @override
  int get hashCode => Object.hashAll([listId.hashCode, movieId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['listId'] = nativeToJson<String>(listId);
    json['movieId'] = nativeToJson<String>(movieId);
    return json;
  }

  AddMovieToListListMovieInsert({
    required this.listId,
    required this.movieId,
  });
}

@immutable
class AddMovieToListData {
  final AddMovieToListListMovieInsert listMovie_insert;
  AddMovieToListData.fromJson(dynamic json):
  
  listMovie_insert = AddMovieToListListMovieInsert.fromJson(json['listMovie_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddMovieToListData otherTyped = other as AddMovieToListData;
    return listMovie_insert == otherTyped.listMovie_insert;
    
  }
  @override
  int get hashCode => listMovie_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['listMovie_insert'] = listMovie_insert.toJson();
    return json;
  }

  AddMovieToListData({
    required this.listMovie_insert,
  });
}

@immutable
class AddMovieToListVariables {
  final String listId;
  final String movieId;
  late final Optional<String>note;
  final int position;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddMovieToListVariables.fromJson(Map<String, dynamic> json):
  
  listId = nativeFromJson<String>(json['listId']),
  movieId = nativeFromJson<String>(json['movieId']),
  position = nativeFromJson<int>(json['position']) {
  
  
  
  
    note = Optional.optional(nativeFromJson, nativeToJson);
    note.value = json['note'] == null ? null : nativeFromJson<String>(json['note']);
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddMovieToListVariables otherTyped = other as AddMovieToListVariables;
    return listId == otherTyped.listId && 
    movieId == otherTyped.movieId && 
    note == otherTyped.note && 
    position == otherTyped.position;
    
  }
  @override
  int get hashCode => Object.hashAll([listId.hashCode, movieId.hashCode, note.hashCode, position.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['listId'] = nativeToJson<String>(listId);
    json['movieId'] = nativeToJson<String>(movieId);
    if(note.state == OptionalState.set) {
      json['note'] = note.toJson();
    }
    json['position'] = nativeToJson<int>(position);
    return json;
  }

  AddMovieToListVariables({
    required this.listId,
    required this.movieId,
    required this.note,
    required this.position,
  });
}

