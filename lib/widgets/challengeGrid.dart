import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:snaplify/models/challenge.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:snaplify/screens/challengeGame.dart';

class ChallengeGrid extends StatefulWidget {
  final Challenge challenge;
  ChallengeGrid(this.challenge);

  @override
  _ChallengeGridState createState() => _ChallengeGridState();
}

class _ChallengeGridState extends State<ChallengeGrid> {
  int _currentPage = 0;

  //Custom image loader
  void moiBitDownload() async {
    final url = 'https://kfs4.moibit.io/moibit/v0/readfile';
    assert(widget.challenge.images.length <= 4);

    for (int i = 0; i < 4; ++i) {
      final data = {"fileName": widget.challenge.cId + i.toString()};
      final encodedData = json.encode(data);
      http.Response response = await http.post(url,
          headers: {
          },
          body: encodedData);
      final base64String = base64.encode(response.bodyBytes);
      widget.challenge.images[i] = base64Decode(base64String);
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    moiBitDownload();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(ChallengeGameScreen.routeName,
              arguments: widget.challenge);
        },
        child: Card(
          margin: EdgeInsets.all(15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 30,
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipRRect(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: CarouselSlider.builder(
                        options: CarouselOptions(
                          height: media.height * 0.23,
                          autoPlay: false,
                          enableInfiniteScroll: false,
                          enlargeCenterPage: true,
                          onPageChanged: (cur, _) {
                            _currentPage = cur;
                            if (mounted) setState(() {});
                          },
                          initialPage: _currentPage,
                        ),
                        itemCount: 4,
                        itemBuilder: (BuildContext context, int itemIndex,
                            int currentIndex) {
                          return (widget.challenge.images[itemIndex] != null)
                              ? Image.memory(widget.challenge.images[itemIndex])
                              : Image(
                                  image: AssetImage(
                                      'assets/images/loadingimage.gif'));
                        },
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                  ),
                ],
              ),
              Padding(
                  padding: EdgeInsets.all(4),
                  child: ListTile(
                      leading: Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.purple),
                            ),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: widget.challenge.byImageUrl,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(24.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                      title: Text(widget.challenge.byName)))
            ],
          ),
        ));
  }
}
