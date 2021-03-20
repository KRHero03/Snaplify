import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:snaplify/models/users.dart';
import 'package:snaplify/providers/algolia.dart';
import 'package:snaplify/widgets/alertDialog.dart';
import 'package:snaplify/widgets/userGrid.dart';

class DataSearch extends SearchDelegate {
  AlgoliaQuery instance = Search.algolia.instance.index("snaplifyUsers");
  @override
  String get searchFieldLabel => 'Search Users';

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context).copyWith(
      textTheme: TextTheme(
        headline6: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
    );
    assert(theme != null);
    return theme;
  }

  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () async {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: searchServer(context),
      builder: (BuildContext _, AsyncSnapshot snapshot) {
        if (query.isEmpty) return Center(child: Text("Search Users"));
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError)
            return CustomAlertDialog(
              title: "Something went wrong",
              message: "Please check your internet",
            );
          if (snapshot.data.isEmpty)
            return Center(
              child: Text("No User Found."),
            );
          return ListView.builder(
            itemBuilder: (ctx, i) => UserGrid(
              snapshot.data[i],
              disableButton: true,
            ),
            itemCount: snapshot.data.length,
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: searchServer(context),
      builder: (BuildContext _, AsyncSnapshot snapshot) {
        if (query.isEmpty) return Center(child: Text("Search Users"));
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError)
            return CustomAlertDialog(
              title: "Something went wrong",
              message: "Please check your internet",
            );
          if (snapshot.data.isEmpty)
            return Center(
              child: Text("No User Found."),
            );
          return ListView.builder(
            itemBuilder: (ctx, i) => UserGrid(
              snapshot.data[i],
              disableButton: true,
            ),
            itemCount: snapshot.data.length,
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<dynamic> searchServer(context) async {
    try {
      List<Users> data = [];
      if (query.isEmpty) return data;
      AlgoliaQuerySnapshot querySnap =
          await instance.search(query).getObjects();
      List<AlgoliaObjectSnapshot> results = querySnap.hits;
      results.forEach((item) {
        data.add(Users(
          uId: item.objectID,
          name: item.data["name"].toString(),
          imageUrl: item.data["imageUrl"].toString(),
          email: item.data["email"].toString(),
          // points: int.parse(item.data["points"].toString()),
        ));
      });
      return data;
    } catch (e) {
      throw (e);
    }
  }
}
