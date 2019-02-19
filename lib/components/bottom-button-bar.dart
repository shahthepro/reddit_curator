import 'package:flutter/material.dart';
import 'package:reddit_curator/data/feed.dart';
import 'package:reddit_curator/store/state.dart';

Widget getBottomButtonBar({ @required FeedItem feed, @required AppStateWidgetState state, @required Function onFavorite, @required Function onShare, @required Function onDownload }) {
  return ButtonBar(
    alignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      IconButton(
        icon: Icon(
          state.isFavorite(feed) ? Icons.favorite : Icons.favorite_border,
          color: Colors.redAccent,
        ),
        onPressed: () {
          onFavorite(state: state, feed: feed);
        }
      ),
      IconButton(
        icon: Icon(Icons.cloud_download, color: Colors.blueGrey),
        onPressed: () {
          onDownload(state: state, feed: feed);
        },
      ),
      IconButton(
        icon: Icon(Icons.share, color: Colors.blueGrey),
        onPressed: () {
          onShare(state: state, feed: feed);
        },
      ),
    ],
  );
}