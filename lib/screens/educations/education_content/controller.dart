import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcpages/youtube_player/youtubevideopreview.dart';

import '../../../appbloc/appvar.dart';
import '../../../qbank/testscreens/pdfbook/controller.dart';
import '../../../qbank/testscreens/pdfbook/layout.dart';
import '../education_editors/model.dart';
import '../model.dart';

class EducationContentController extends GetxController {
  IndexedTreeViewController? treeViewController;
  EducationNode? initialRoot;
  Education? education;

  EducationContentController(this.education);
  @override
  void onInit() {
    treeViewController = IndexedTreeViewController<EducationNode>();
    initialRoot = EducationNode.fromJson({'n': 'Root', 'key': 'root', 'c': 0, 'i': education!.data});

    if (AppVar.appBloc.hesapBilgileri.kurumID != null) {
      //Onizlemeden gelen hata vermemesi icin
      Fav.preferences.addLimitedStringList(AppVar.appBloc.hesapBilgileri.kurumID! + AppVar.appBloc.hesapBilgileri.uid! + 'favoritesEducationItems', education!.key!, maxNumber: 3);
    }

    super.onInit();
  }

  void openItem(EducationNode node) {
    if (node.type == EducationNodeType.video) {
      if (node.data1.getYoutubeIdFromUrl != null) {
        YoutubeHelper.play(node.data1!);
      } else {
        Fav.to(MyVideoPlay(
          cacheVideo: false,
          isActiveDownloadButton: false,
          isFullScreen: true,
          url: node.data1!,
        ));
      }
    } else if (node.type == EducationNodeType.pdfReadPage) {
      final _startPageForPdf = int.tryParse(node.data1!.split('-').first.trim());
      final _endPageForPdf = int.tryParse(node.data1!.split('-').last.trim());
      if (_startPageForPdf == null || _endPageForPdf == null || education!.pdf1.safeLength < 6) {
        return OverAlert.show(message: 'errdata'.translate, type: AlertType.danger);
      }

      Fav.to(PdfBook(goToPageButtonVisible: true), binding: BindingsBuilder(() {
        if (Get.isRegistered<PdfBookController>()) Get.delete<PdfBookController>();
        Get.put<PdfBookController>(PdfBookController(pdfUrl: education!.pdf1, startPageForPdf: _startPageForPdf, endPageForPdf: _endPageForPdf));
      }));
    } else {
      throw ("Bilinmeyen EducationNodeType tipi");
    }
  }
}
