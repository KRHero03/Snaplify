import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PanoramaWidget extends StatelessWidget {
  static const routeName = '/panorama';
  final String url;

  PanoramaWidget({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PanoramaScreen(url: url),
    );
  }
}

class PanoramaScreen extends StatefulWidget {
  final String url;

  PanoramaScreen({Key key, @required this.url}) : super(key: key);

  @override
  State createState() => PanoramaScreenState(url: url);
}

class PanoramaScreenState extends State<PanoramaScreen> {
  final String url;

  PanoramaScreenState({Key key, @required this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Panorama(
      child: Image.network(url),
      animSpeed: 1.0,
      sensorControl: SensorControl.Orientation,
    )
        //     CachedNetworkImage(
        //   imageUrl: url,
        //   imageBuilder: (context, imageProvider) =>Panorama(
        //     child:Image.network(url)
        //   ),
        //   placeholder: (context, url) =>
        //       Container(child: Center(child: CircularProgressIndicator())),
        //   errorWidget: (context, url, error) => Icon(Icons.error),
        // )
        );
  }
}
