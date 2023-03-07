import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:pdfx/pdfx.dart';

/// Widget for viewing PDF documents
class PdfQuestionView extends StatefulWidget {
  const PdfQuestionView({
    required this.document,
    this.initialPage = 1,
    this.rightBottomX = 100,
    this.leftTopY = 100,
    this.leftTopX = 300,
    this.rightBottomY = 500,
    this.viewPort = 3,
    Key? key,
  }) : super(key: key);

  final int? leftTopX;
  final int? leftTopY;
  final int? rightBottomX;
  final int? rightBottomY;
  final int viewPort;
  final PdfDocument? document;

  final int? initialPage;

  @override
  _PdfQuestionViewState createState() => _PdfQuestionViewState();
}

class _PdfQuestionViewState extends State<PdfQuestionView> with SingleTickerProviderStateMixin {
  final Map<int?, PdfPageImage?> _pages = {};
  int? _currentIndex;

  @override
  void initState() {
    _currentIndex = (widget.initialPage ?? 1) - 1;

    super.initState();
  }

  Future<PdfPageImage?> _getPageImage(int? pageIndex) async {
    if (_pages[pageIndex] != null) {
      return _pages[pageIndex];
    }

    final page = await widget.document!.getPage(pageIndex! + 1);

    try {
      _pages[pageIndex] = await page.render(
        width: page.width * widget.viewPort,
        height: page.height * widget.viewPort,
        format: PdfPageImageFormat.jpeg,
        backgroundColor: '#ffffff',
      );
    } finally {
      await page.close();
    }

    return _pages[pageIndex];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PdfPageImage?>(
      future: _getPageImage(_currentIndex),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
/* todo burasi sorularin pdf te baslangic ve bitis noktalari belli ve o noktalardan croplanmak isteniyorsa duzenlenmesi lazim
Asagida eskiden extend image kutuphanesi ile yazilmis hali var
onu photoview kutuphanesinde calisacak hale getirmelisin.
Simdilik gecici olarak sizedbox konuldu
*/

          return SizedBox(
            child: Text('Burasi yazilmadi'),
          );
          //* Extended image ile yazilmis hali
          // return LayoutBuilder(
          //   builder: (context, constraints) {
          //     final double width = constraints.maxWidth.clamp(0.0, 600.0);
          //     final double height = width * (widget.rightBottomY - widget.leftTopY) / (widget.rightBottomX - widget.leftTopX);

          //     Widget current = ExtendedImage.memory(
          //       _pages[_currentIndex].bytes,
          //       height: height,
          //       width: width,
          //       loadStateChanged: (ExtendedImageState state) {
          //         if (state.extendedImageLoadState == LoadState.completed) {
          //           return ExtendedRawImage(
          //             image: state.extendedImageInfo?.image,
          //             height: height,
          //             width: width,
          //             fit: BoxFit.fill,
          //             sourceRect: Rect.fromLTRB(widget.leftTopX.toDouble() * widget.viewPort, widget.leftTopY.toDouble() * widget.viewPort, widget.rightBottomX.toDouble() * widget.viewPort, widget.rightBottomY.toDouble() * widget.viewPort),
          //           );
          //         }
          //         return const SizedBox();
          //       },
          //     );

          //     return KeyedSubtree(
          //       key: Key('$runtimeType.page.${widget.document.hashCode}.$_currentIndex.${widget.leftTopY}'),
          //       child: current,
          //     );
          //   },
          // );
        }

        return MyProgressIndicator(
          isCentered: true,
          color: Fav.secondaryDesign.progressIndicator.indicator,
        );
      },
    );
  }
}
