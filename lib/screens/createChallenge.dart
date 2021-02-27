import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koukicons/addImage.dart';
import 'package:koukicons/camera.dart';
import 'package:koukicons/cancel.dart';
import 'package:koukicons/gallery.dart';
import 'package:snaplify/screens/shareChallenge.dart';
import 'package:snaplify/widgets/inputDialog.dart';

class CreateChallenge extends StatefulWidget {
  static const routeName = '/create';

  @override
  _CreateChallengeState createState() => _CreateChallengeState();
}

class _CreateChallengeState extends State<CreateChallenge> {
  List<File> _image = [null, null, null, null];
  List<Color> _imageWidgetColor = [
    Color(0xFFd8a0ae),
    Color(0xFFc26e77),
    Color(0xFF4863A0),
    Color(0xFF008080)
  ];

  final picker = ImagePicker();

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        throw (response.file);
      } else {
        throw (response.file);
      }
    } else {
      throw (response.exception);
    }
  }

  Future getImage(int id) async {
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) {
          return Wrap(
            alignment: WrapAlignment.center,
            children: [
              IconButton(
                  iconSize: 100,
                  icon: KoukiconsCamera(),
                  onPressed: () {
                    Navigator.of(_).pop(ImageSource.camera);
                  }),
              IconButton(
                  iconSize: 100,
                  icon: KoukiconsGallery(),
                  onPressed: () {
                    Navigator.of(_).pop(ImageSource.gallery);
                  }),
              if (_image[id] != null)
                IconButton(
                    iconSize: 100,
                    icon: KoukiconsCancel(),
                    onPressed: () {
                      Navigator.of(_).pop("Remove");
                    }),
            ],
          );
        }).then((value) async {
      if (value == null) return;
      if (value == "Remove") {
        setState(() {
          _image[id] = null;
        });
        return;
      }
      try {
        final pickedFile = await picker.getImage(source: value);
        setState(() {
          if (pickedFile != null) {
            _image[id] = File(pickedFile.path);
          } else {
            print('No image selected.');
          }
        });
        await retrieveLostData();
      } catch (e) {
        throw (e);
      }
    });
  }

  Widget _imageWidget({int id, dynamic media}) {
    return GestureDetector(
      onTap: () {
        getImage(id);
      },
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(0),
        color: _imageWidgetColor[id],
        height: media.height * 0.26,
        width: media.width * 0.45,
        child: (_image[id] == null)
            ? Center(child: KoukiconsAddImage())
            : Image(image: FileImage(_image[id])),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("Create Challenge")),
      body: Column(
        children: [
          SizedBox(height: media.height * 0.05),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _imageWidget(id: 0, media: media),
                    _imageWidget(id: 1, media: media)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _imageWidget(id: 2, media: media),
                    _imageWidget(id: 3, media: media)
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: media.height * 0.1),
          RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: (_image[0] == null ||
                      _image[1] == null ||
                      _image[2] == null ||
                      _image[3] == null)
                  ? null
                  : () async {
                      await showDialog(
                          context: context,
                          builder: (_) => InputDialog()).then((word) {
                        if (word != null)
                          Navigator.of(context).pushNamed(
                              ShareChallenge.routeName,
                              arguments: {"word": word, "images": _image});
                      });
                    },
              child: Text(
                "NEXT",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }
}
