library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'add_movie_to_list.dart';

part 'get_movies_in_list.dart';

part 'create_new_list.dart';

part 'get_my_lists.dart';







class ExampleConnector {
  
  
  AddMovieToListVariablesBuilder addMovieToList ({required String listId, required String movieId, required int position, }) {
    return AddMovieToListVariablesBuilder(dataConnect, listId: listId,movieId: movieId,position: position,);
  }
  
  
  GetMoviesInListVariablesBuilder getMoviesInList ({required String listId, }) {
    return GetMoviesInListVariablesBuilder(dataConnect, listId: listId,);
  }
  
  
  CreateNewListVariablesBuilder createNewList ({required String name, required bool public, }) {
    return CreateNewListVariablesBuilder(dataConnect, name: name,public: public,);
  }
  
  
  GetMyListsVariablesBuilder getMyLists () {
    return GetMyListsVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'eglise',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
