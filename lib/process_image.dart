import "package:mlkit/mlkit.dart";
import 'package:flutter/material.dart';
import 'dart:io';
import 'label_item.dart';
import 'post_screen.dart';
import 'post_item.dart';

class Process_Image extends StatefulWidget {
  static String id = 'process_image_screen';
  final String imagePath;
  final File file;
  final List<VisionLabel> list;
  final Post_item item;

  const Process_Image({Key key, this.imagePath, this.file, this.list, this.item})
      : super(key: key);

  @override
  _Process_ImageState createState() => _Process_ImageState();
}

class _Process_ImageState extends State<Process_Image> {
  List<Label_item> keyWords;
  List<String> labels = List<String>();
  Comparator<Label_item> confidenceComparator =
      (a, b) => b.confidence.compareTo(a.confidence);

  @override
  initState() {
    keyWords = new List<Label_item>();
    super.initState();
    print(widget.list.length);
    for (var i = 0; i < 5; i++) {
      Label_item item = new Label_item(
          label: widget.list[i].label,
          confidence: widget.list[i].confidence,
          check: true);
      keyWords.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
      appBar: new AppBar(
        title: new Text('Image Labeling Firebase'),
      ),
      body: _buildBody(widget.file),
    ));
  }

  //Build body
  Widget _buildBody(File _file) {
    return new Container(
      child: new Column(
        children: <Widget>[displaySelectedFile(_file), _buildList(keyWords), _buildButton()],
      ),
    );
  }

  Widget _buildList(List<Label_item> labels) {
    if (labels == null || labels.length == 0) {
      return new Text('Empty', textAlign: TextAlign.center);
    }
    return new Expanded(
        child: new Container(
      padding: new EdgeInsets.all(32.0),
      child: ListView(
        padding: EdgeInsets.all(8.0),
        children: labels
            .map((text) => CheckboxListTile(
                  title: Text(text.label),
                  value: text.check,
                  onChanged: (val) {
                    setState(() {
                      text.check = val;
                    });
                  },
                ))
            .toList(),
      ),
    ));
  }

  Widget displaySelectedFile(File file) {
    return new SizedBox(
      // height: 200.0,
      width: 150.0,
      child: file == null
          ? new Text('Sorry nothing selected!!')
          : new Image.file(file),
    );
  }

  //Display labels
  Widget _buildRow(String label, String confidence) {
    return new ListTile(
      title: new Text(
        "\nLabel: $label",
      ),
      dense: true,
    );
  }

  Widget _buildButton() {
    return RaisedButton(
      onPressed: () async {
        addToLabels();
        final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PostPage(labels: labels, image_path: widget.imagePath, item: widget.item),
            ));
        Navigator.pop(context, res);
        Navigator.pushNamed(context, PostPage.id);
      },
      color: Colors.pink,
      textColor: Colors.white,
      child: Text('Ready to Go'),

//        final res = await Navigator.push(
//    context,
//    MaterialPageRoute(
//        builder: (context) =>
//        Process_Image(imagePath: widget.imagePath, file: file, list:currentLabels),
//    ),
//    );
////                              Navigator.pop(context, imagePath);
//    Navigator.pop(context, res);
//    Navigator.pushNamed(context, Process_Image.id);
    );
  }

  void addToLabels() {
    for (var i = 0; i < keyWords.length; i++) {
      if (keyWords[i].check) {
        labels.add(keyWords[i].label);
      }
    }
  }

}
