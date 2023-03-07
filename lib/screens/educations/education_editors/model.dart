import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:mcg_extension/mcg_extension.dart';

class EducationNode extends ListenableIndexedNode<EducationNode> {
  String? title;
  String? subTitle;
  EducationNodeType? type;
  String? data1;
  String? data2;

  EducationNode.create() : super(key: 6.makeKey) {
    title = '';
    subTitle = '';
    type = EducationNodeType.none;
    data1 = '';
    data2 = '';
  }
  EducationNode({String? nodeKey, this.title, this.subTitle, this.data1, this.data2, this.type}) : super(key: nodeKey);

  Map toJson() {
    return {'t': title, 'st': subTitle, 'd1': data1, 'd2': data2, 'type': (type ?? EducationNodeType.none).name, 'key': super.key, 'i': children.map((item) => (item as EducationNode).toJson()).toList()};
  }

  EducationNode.fromJson(Map snapshot) : super(key: snapshot['key']) {
    title = snapshot['t'];
    subTitle = snapshot['st'];
    data1 = snapshot['d1'];
    data2 = snapshot['d2'];
    type = J.jEnum(snapshot['type'], EducationNodeType.values);
    addAll(((snapshot['i'] ?? []) as List).map((item) => EducationNode.fromJson(item)).toList());
  }

  List<EducationNode> getAllChildren() {
    final _list = <EducationNode>[];

    for (final child in children) {
      _list.add((child as EducationNode));

      if (child.children.isNotEmpty) {
        _list.addAll(child.getAllChildren());
      }
    }
    return _list;
  }
}

enum EducationNodeType { none, pdfReadPage, video }

class SchoolPackage {
  final String? name;
  final String? key;
  final List<String?>? kurumIdlist;

  SchoolPackage({this.name, this.kurumIdlist, this.key});
}
