part of 'generated.dart';

class CreateNewListVariablesBuilder {
  String name;
  Optional<String> _description = Optional.optional(nativeFromJson, nativeToJson);
  bool public;

  final FirebaseDataConnect _dataConnect;  CreateNewListVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }

  CreateNewListVariablesBuilder(this._dataConnect, {required  this.name,required  this.public,});
  Deserializer<CreateNewListData> dataDeserializer = (dynamic json)  => CreateNewListData.fromJson(jsonDecode(json));
  Serializer<CreateNewListVariables> varsSerializer = (CreateNewListVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateNewListData, CreateNewListVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateNewListData, CreateNewListVariables> ref() {
    CreateNewListVariables vars= CreateNewListVariables(name: name,description: _description,public: public,);
    return _dataConnect.mutation("CreateNewList", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateNewListListInsert {
  final String id;
  CreateNewListListInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateNewListListInsert otherTyped = other as CreateNewListListInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateNewListListInsert({
    required this.id,
  });
}

@immutable
class CreateNewListData {
  final CreateNewListListInsert list_insert;
  CreateNewListData.fromJson(dynamic json):
  
  list_insert = CreateNewListListInsert.fromJson(json['list_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateNewListData otherTyped = other as CreateNewListData;
    return list_insert == otherTyped.list_insert;
    
  }
  @override
  int get hashCode => list_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['list_insert'] = list_insert.toJson();
    return json;
  }

  CreateNewListData({
    required this.list_insert,
  });
}

@immutable
class CreateNewListVariables {
  final String name;
  late final Optional<String>description;
  final bool public;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateNewListVariables.fromJson(Map<String, dynamic> json):
  
  name = nativeFromJson<String>(json['name']),
  public = nativeFromJson<bool>(json['public']) {
  
  
  
    description = Optional.optional(nativeFromJson, nativeToJson);
    description.value = json['description'] == null ? null : nativeFromJson<String>(json['description']);
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateNewListVariables otherTyped = other as CreateNewListVariables;
    return name == otherTyped.name && 
    description == otherTyped.description && 
    public == otherTyped.public;
    
  }
  @override
  int get hashCode => Object.hashAll([name.hashCode, description.hashCode, public.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    if(description.state == OptionalState.set) {
      json['description'] = description.toJson();
    }
    json['public'] = nativeToJson<bool>(public);
    return json;
  }

  CreateNewListVariables({
    required this.name,
    required this.description,
    required this.public,
  });
}

