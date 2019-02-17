import 'package:flutter/material.dart';
import 'package:reddit_curator/data/feed.dart';
import 'package:flutter/cupertino.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:reddit_curator/store/state.dart';

class ImageViewerScreen extends StatefulWidget {
  ImageViewerScreen({ Key key, this.listItems, this.startIndex = 0 }) : super(key: key);

  final List<FeedItem> listItems;
  final int startIndex;

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

void _onImageSwiped(int index) {
  print('swiped');
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  final List<PhotoViewGalleryPageOptions> _images = List<PhotoViewGalleryPageOptions>();
  @override
  Widget build(BuildContext context) {
    final AppStateWidgetState state = AppStateWidget.of(context);
    // _images.removeRange(0, _images.length);
    _getFeeds(state);

    return Scaffold(
      appBar: new AppBar(
        title: Text("Image Viewer"),
      ),
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoViewGallery(
          pageOptions: _images,
          // loadingChild: widget.loadingChild,
          // backgroundDecoration: widget.backgroundDecoration,
          pageController: PageController(initialPage: widget.startIndex),
          onPageChanged: _onImageSwiped,
        ),
      )
    );
  }

  void _mapFeedsToGallery(List<FeedItem> feeds) {
    setState(() {
      _images.addAll(
        feeds.map((feed) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(feed.link),
            heroTag: feed.title
          );
        })
      );
    });
  }

  void _getFeeds(AppStateWidgetState state) {
    switch (state.activeTab) {
      case TabViewPages.Recent:
        _mapFeedsToGallery(state.recentFeeds);
        break;
      case TabViewPages.Popular:
        _mapFeedsToGallery(state.popularFeeds);
        break;
      case TabViewPages.Favorites:
        _mapFeedsToGallery(state.favoriteFeeds);
        break;
      default:
        _mapFeedsToGallery(state.recentFeeds);
        break;
    }
  }
}
