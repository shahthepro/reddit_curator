import 'package:flutter/material.dart';
import 'package:reddit_curator/data/feed.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _feeds = <FeedItem>[];
  final _saved = new Set<FeedItem>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: const Icon(Icons.menu), 
          onPressed: _showDrawer,
        ),
        title: Text(widget.title),
      ),
      body: ListView.builder(itemBuilder: _buildListView),
    );
  }

  Widget _buildListView(BuildContext context, int index) {
    if (index >= _feeds.length) {
      _fetchFeeds();
      return null;
    }

    return _buildRow(_feeds[index]);
  }

  Widget _buildRow(FeedItem feed) {
    final alreadySaved = _saved.contains(feed);

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(feed.title),
            subtitle: Text(feed.timestamp),
          ),
          Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new NetworkImage(feed.link),
                fit: BoxFit.cover,
              ),
            ),
            height: 250.0,
          ),
          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    alreadySaved ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    setState(() {                      
                      _saved.add(feed);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.cloud_download),
                  onPressed: () {
                    print("Download ${feed.id}");
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    print("Share ${feed.id}");
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  void _showDrawer() {
    print("Show Drawer");
  }

  Future<void> _fetchFeeds() {
    return Future.delayed(new Duration(seconds: 2), () {
      int startId = _feeds.length;
      setState(() {
        _feeds.addAll([
          new FeedItem("id_$startId", "Feed Item ${startId}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
          new FeedItem("id_${startId + 1}", "Feed Item ${startId + 1}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
          new FeedItem("id_${startId + 2}", "Feed Item ${startId + 2}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
          new FeedItem("id_${startId + 3}", "Feed Item ${startId + 3}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
          new FeedItem("id_${startId + 4}", "Feed Item ${startId + 4}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
          new FeedItem("id_${startId + 5}", "Feed Item ${startId + 5}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
          new FeedItem("id_${startId + 6}", "Feed Item ${startId + 6}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
          new FeedItem("id_${startId + 7}", "Feed Item ${startId + 7}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
          new FeedItem("id_${startId + 8}", "Feed Item ${startId + 8}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
          new FeedItem("id_${startId + 9}", "Feed Item ${startId + 9}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
        ]);
      });
    });
  }
}
