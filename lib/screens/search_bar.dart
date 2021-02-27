import 'package:flutter/material.dart';

class DataSearch extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Search Users';
  @override
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
      future: searchServer(),
      builder: (BuildContext _, AsyncSnapshot snapshot) {
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: searchServer(),
      builder: (BuildContext _, AsyncSnapshot snapshot) {
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<dynamic> searchServer() async {}
}
