import 'package:flutter/material.dart';
import 'package:reddit_curator/components/bottom-button-bar.dart';
import 'package:reddit_curator/data/feed.dart';
import 'package:reddit_curator/store/state.dart';

Widget buildCard(FeedItem feed, { @required BuildContext context, @required Function onImageTap, @required Function onDownload, @required Function onShare, @required Function onFavorite }) {
  AppStateWidgetState state = AppStateWidget.of(context);

  return Card(
    key: Key(feed.id),
    child: Column(
      children: <Widget>[
        ListTile(
          title: Text(feed.title),
          subtitle: Text(feed.timestamp),
        ),
        new GestureDetector(
          onTap: onImageTap,
          child: Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new NetworkImage(feed.link),
                fit: BoxFit.cover,
              ),
            ),
            height: 250.0,
          ),
        ),
        ButtonTheme.bar(
          child: getBottomButtonBar(
            state: state,
            feed: feed,
            onDownload: onDownload,
            onShare: onShare,
            onFavorite: onFavorite,
          ),
          // child: ButtonBar(
          //   children: <Widget>[
          //     IconButton(
          //       icon: Icon(
          //         state.isFavorite(feed) ? Icons.favorite : Icons.favorite_border,
          //         color: Colors.redAccent,
          //       ),
          //       onPressed: onFavorite
          //     ),
          //     IconButton(
          //       icon: Icon(Icons.cloud_download, color: Colors.blueGrey),
          //       onPressed: onDownload,
          //     ),
          //     IconButton(
          //       icon: Icon(Icons.share, color: Colors.blueGrey),
          //       onPressed: onShare,
          //     ),
          //   ],
          // ),
        )
      ],
    ),
  );
}
