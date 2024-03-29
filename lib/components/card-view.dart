import 'package:flutter/material.dart';
import 'package:reddit_curator/components/bottom-button-bar.dart';
import 'package:reddit_curator/data/feed.dart';
import 'package:reddit_curator/store/state.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget buildCard(FeedItem feed, { @required BuildContext context, @required Function onImageTap, @required Function onDownload, @required Function onShare, @required Function onFavorite }) {
  AppStateWidgetState state = AppStateWidget.of(context);

  DateTime timestamp = DateTime.parse(feed.timestamp);

  return Card(
    key: Key(feed.id),
    child: Column(
      children: <Widget>[
        ListTile(
          title: Text(feed.title),
          subtitle: Text(timeago.format(timestamp)),
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
        )
      ],
    ),
  );
}
