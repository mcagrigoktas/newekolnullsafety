import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdfx/pdfx.dart';
import 'package:synchronized/synchronized.dart';

typedef PDFViewPageBuilder = PhotoViewGalleryPageOptions Function(
  /// Page image model
  Future<PdfPageImage?> pageImage,

  /// page index
  int index,

  /// pdf document
  PdfDocument? document,
);

typedef PDFViewPageRenderer = Future<PdfPageImage?> Function(PdfPage page);

final Lock _lock = Lock();

/// Widget for viewing PDF documents
class PdfBoookView extends StatefulWidget {
  const PdfBoookView({
    this.controller,
    this.onPageChanged,
    this.onDocumentLoaded,
    this.onDocumentError,
    this.documentLoader,
    this.pageLoader,
    this.pageBuilder,
    this.errorBuilder,
    this.renderer = _render,
    this.scrollDirection = Axis.horizontal,
    this.pageSnapping = true,
    this.physics,
    this.backgroundDecoration = const BoxDecoration(),
    this.loaderSwitchDuration = const Duration(seconds: 1),
    Key? key,
  }) : super(key: key);

  ///
  final Duration loaderSwitchDuration;

  /// Page management
  final PdfBookViewController? controller;

  /// Called whenever the page in the center of the viewport changes
  final void Function(int page)? onPageChanged;

  /// Called when a document is loaded
  final void Function(PdfDocument? document)? onDocumentLoaded;

  /// Called when a document loading error
  final void Function(Object? error)? onDocumentError;

  /// Widget showing when pdf document loading
  final Widget? documentLoader;

  /// Widget showing when pdf page loading
  final Widget? pageLoader;

  /// Page builder
  final PDFViewPageBuilder? pageBuilder;

  /// Show document loading error message inside [PdfView]
  final Widget Function(Exception? error)? errorBuilder;

  /// Custom PdfRenderer options
  final PDFViewPageRenderer renderer;

  /// Page turning direction
  final Axis scrollDirection;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  final bool pageSnapping;

  /// Pdf widget page background decoration
  final BoxDecoration backgroundDecoration;

  /// Determines the physics of a [PdfView] widget.
  final ScrollPhysics? physics;

  /// Default PdfRenderer options
  static Future<PdfPageImage?> _render(PdfPage page) => page.render(
        width: page.width * 3.toInt(),
        height: page.height * 3.toInt(),
        format: PdfPageImageFormat.jpeg,
        backgroundColor: '#ffffff',
      );

  @override
  _PdfBoookViewState createState() => _PdfBoookViewState();
}

class _PdfBoookViewState extends State<PdfBoookView> with SingleTickerProviderStateMixin {
  final Map<int, PdfPageImage?> _pages = {};
  _PdfViewLoadingState? _loadingState;
  Exception? _loadingError;
  int? _currentIndex;

  PhotoViewGalleryPageOptions _pageBuilder(
    Future<PdfPageImage?> pageImage,
    int index,
    PdfDocument? document,
  ) =>
      widget.controller!.pageBuildType == 1
          ? PhotoViewGalleryPageOptions.customChild(
              child: Image(
                image: PdfPageImageProvider(
                  pageImage.then((value) => value!),
                  index,
                  document!.id,
                ),
              ),
              basePosition: Alignment.topCenter,
              scaleStateController: widget.controller!.scaleStateController,
              controller: widget.controller!.photoViewController,
              minScale: PhotoViewComputedScale.contained * 0.75,
              maxScale: PhotoViewComputedScale.contained * 3.0,
              initialScale: PhotoViewComputedScale.covered * (1.414 * context.screenWidth / (context.screenHeight - 80)),
              heroAttributes: PhotoViewHeroAttributes(tag: '${document.id}-$index'),
            )
          : PhotoViewGalleryPageOptions(
              imageProvider: PdfPageImageProvider(
                pageImage.then((value) => value!),
                index,
                document!.id,
              ),
              basePosition: Alignment.center,
              scaleStateController: widget.controller!.scaleStateController,
              controller: widget.controller!.photoViewController,
              minScale: PhotoViewComputedScale.contained * 1,
              maxScale: PhotoViewComputedScale.contained * 3.0,
              initialScale: PhotoViewComputedScale.contained * 1.0,
              heroAttributes: PhotoViewHeroAttributes(tag: '${document.id}-$index'),
            );

  @override
  void initState() {
    _loadingState = _PdfViewLoadingState.loading;
    widget.controller!._attach(this);
    _currentIndex = widget.controller!._pageController!.initialPage;
    super.initState();
  }

  @override
  void dispose() {
    widget.controller!._detach();
    super.dispose();
  }

  Future<PdfPageImage?> _getPageImage(int pageIndex) => _lock.synchronized<PdfPageImage?>(() async {
        if (_pages[pageIndex] != null) {
          return _pages[pageIndex];
        }

        final page = await widget.controller!._document!.getPage(pageIndex + 1);

        try {
          _pages[pageIndex] = await widget.renderer(page);
        } finally {
          await page.close();
        }

        return _pages[pageIndex];
      });

  void _changeLoadingState(_PdfViewLoadingState state) {
    if (state == _PdfViewLoadingState.loading) {
      _pages.clear();
    } else if (state == _PdfViewLoadingState.success) {
      widget.onDocumentLoaded?.call(widget.controller!._document);
    } else if (state == _PdfViewLoadingState.error) {
      widget.onDocumentError?.call(_loadingError);
    }
    setState(() {
      _loadingState = state;
    });
  }

  Widget _buildLoaded() => PhotoViewGallery.builder(
        builder: (BuildContext context, int index) => widget.pageBuilder == null ? _pageBuilder(_getPageImage(index), index, widget.controller!._document) : widget.pageBuilder!(_getPageImage(index), index, widget.controller!._document),
        itemCount: widget.controller!._document!.pagesCount,
        loadingBuilder: (_, __) => widget.pageLoader ?? const SizedBox(),
        backgroundDecoration: widget.backgroundDecoration,
        pageController: widget.controller!._pageController,
        onPageChanged: (int index) {
          _currentIndex = index;
          widget.onPageChanged?.call(index + 1);
        },
        scrollDirection: widget.scrollDirection,
        scrollPhysics: widget.physics,
      );

  @override
  Widget build(BuildContext context) {
    Widget? content;

    switch (_loadingState) {
      case null:
        content = KeyedSubtree(
          key: Key('$runtimeType.root.loading'),
          child: widget.documentLoader ?? const SizedBox(),
        );
        break;
      case _PdfViewLoadingState.loading:
        content = KeyedSubtree(
          key: Key('$runtimeType.root.loading'),
          child: widget.documentLoader ?? const SizedBox(),
        );
        break;
      case _PdfViewLoadingState.error:
        content = KeyedSubtree(
          key: Key('$runtimeType.root.error'),
          child: widget.errorBuilder?.call(_loadingError) ?? Center(child: Text(_loadingError.toString())),
        );
        break;
      case _PdfViewLoadingState.success:
        content = KeyedSubtree(
          key: Key('$runtimeType.root.success'),
          child: _buildLoaded(),
        );
        break;
    }

    return AnimatedSwitcher(
      duration: widget.loaderSwitchDuration,
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: content,
    );
  }
}

enum _PdfViewLoadingState {
  loading,
  error,
  success,
}

class PdfBookViewController {
  PdfBookViewController({
    required this.document,
    this.initialPage = 1,
    this.viewportFraction = 1.0,
  }) : assert(viewportFraction > 0.0);

  /// Document future for showing in [PdfView]
  Future<PdfDocument> document;

  /// The page to show when first creating the [PdfView].
  final int initialPage;

  final photoViewController = PhotoViewController();
  final scaleStateController = PhotoViewScaleStateController();

  int get pageBuildType => Get.context!.screenWidth > 720 ? 1 : 0;

  /// The fraction of the viewport that each page should occupy.
  ///
  /// Defaults to 1.0, which means each page fills the viewport in the scrolling
  /// direction.
  final double viewportFraction;

  _PdfBoookViewState? _pdfViewState;
  PageController? _pageController;
  PdfDocument? _document;

  /// Actual showed page
  int get page => (_pdfViewState?._currentIndex ?? 0) + 1;

  /// Count of all pages in document
  int? get pagesCount => _document?.pagesCount;

  /// Changes which page is displayed in the controlled [PdfView].
  ///
  /// Jumps the page position from its current value to the given value,
  /// without animation, and without checking if the new value is in range.
  void jumpToPage(int page) => _pageController!.jumpToPage(page - 1);

  /// Animates the controlled [PdfView] from the current page to the given page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) =>
      _pageController!.animateToPage(
        page - 1,
        duration: duration,
        curve: curve,
      );

  /// Animates the controlled [PdfView] to the next page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> nextPage({
    required Duration duration,
    required Curve curve,
  }) async {
    photoViewController.reset();
    return _pageController!.animateToPage(_pageController!.page!.round() + 1, duration: duration, curve: curve);
  }

  /// Animates the controlled [PdfView] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> previousPage({
    required Duration duration,
    required Curve curve,
  }) {
    photoViewController.reset();
    return _pageController!.animateToPage(_pageController!.page!.round() - 1, duration: duration, curve: curve);
  }

  /// Load document
  Future<void> loadDocument(Future<PdfDocument> documentFuture) {
    _pdfViewState!._changeLoadingState(_PdfViewLoadingState.loading);
    return _loadDocument(documentFuture);
  }

  Future<void> _loadDocument(
    Future<PdfDocument> documentFuture, {
    int initialPage = 1,
  }) async {
    if (_pdfViewState == null) return;

    if (!await hasPdfSupport()) {
      _pdfViewState!
        .._loadingError = Exception('This device does not support the display of PDF documents')
        .._changeLoadingState(_PdfViewLoadingState.error);
      return;
    }

    try {
      _reInitPageController(initialPage);

      _document = await documentFuture;
      _pdfViewState!._changeLoadingState(_PdfViewLoadingState.success);
    } catch (error) {
      _pdfViewState!
        .._loadingError = error as Exception
        .._changeLoadingState(_PdfViewLoadingState.error);
    }
  }

  void _reInitPageController(int initialPage) {
    _pageController?.dispose();
    _pageController = PageController(
      initialPage: initialPage - 1,
      viewportFraction: viewportFraction,
    );
  }

  void _attach(_PdfBoookViewState pdfViewState) {
    if (_pdfViewState != null) {
      return;
    }

    _reInitPageController(initialPage);

    _pdfViewState = pdfViewState;

    if (_document == null) {
      _loadDocument(document);
    }
  }

  void _detach() {
    _pdfViewState = null;
  }

  void dispose() {
    _pageController?.dispose();
  }
}
