import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:snaplify/models/challenge.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:snaplify/screens/challengeGame.dart';
import 'package:intl/intl.dart';

class ChallengeGrid extends StatefulWidget {
  final Challenge challenge;
  ChallengeGrid(this.challenge);

  @override
  _ChallengeGridState createState() => _ChallengeGridState();
}

class _ChallengeGridState extends State<ChallengeGrid> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ChallengeGameScreen.routeName,
                  arguments: widget.challenge)
              .then((value) {
            if (value != null && value == true) widget.challenge.done = true;
          });
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
                          return FadeInImage(
                              image: NetworkImage(
                                  widget.challenge.images[itemIndex]),
                              placeholder:
                                  AssetImage('assets/images/loadingimage.gif'));
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
                    title: Text(widget.challenge.byName),
                    subtitle: Text(
                      DateFormat('dd MMM HH:mm')
                          .format(widget.challenge.dateTime),
                      style: TextStyle(
                          color: Color(0xffaeaeae),
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                  ))
            ],
          ),
        ));
  }
}
