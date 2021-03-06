import 'package:flutter/material.dart';
import 'package:lynou/components/general/floating_action_button.dart';
import 'package:lynou/components/post-feed.dart';
import 'package:lynou/localization/app_translations.dart';
import 'package:lynou/models/database/post.dart';
import 'package:lynou/providers/theme_provider.dart';
import 'package:lynou/screens/new_post_page.dart';
import 'package:lynou/services/post_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  ThemeProvider _themeProvider;
  PostService _postService;

  bool _isStartedOnce = false;
  bool _isLoadingMore = false;
  List<Post> _postList = List<Post>();
  var _page = 0;

  /// Redirect to the page to create a new post.
  /// If a post is really created then we add it directly to the feed.
  _redirectToNewPostPage() async {
    var post = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewPostPage()),
    );

    if (post != null) {
      // Add the post in the feed
      _postList.insert(0, post);
    }
  }

  /// Load posts when the screen run for the first time
  _loadPosts() async {
    if (!_isStartedOnce) {
      setState(() {
        _isStartedOnce = true;
      });

      // Get posts from the server
      var stream = _postService.fetchWallPosts(_page);
      stream.listen((postList) {
        _postList.clear();
        setState(() {
          _postList = postList;
        });
      });
    }
  }

  /// Refresh the posts when we pull the top of the screen
  Future<void> _refreshPosts() async {
    var stream = _postService.fetchWallPosts(0);

    stream.listen((postList) {
      for (var post in postList.reversed) {
        var doubledPostList = _postList.where((e) => e.id == post.id);
        if (doubledPostList.isEmpty) {
          _postList.insert(0, post);
        }
      }

      setState(() {});
    });
  }

  /// Load more posts when we arrive at the bottom of the page.
  _loadMore() async {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
        _page++;
      });

      var stream = _postService.fetchWallPosts(_page);
      stream.listen((postList) {
        for (var post in postList) {
          var doubledPostList = _postList.where((e) => e.id == post.id);
          if (doubledPostList.isEmpty) {
            _postList.add(post);
          }
        }

        // Don't permit to load more if it is the end.
        if (postList.isNotEmpty) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  /// Displays the body containing the post list
  Widget _displaysBody() {
    return NotificationListener(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadMore();
        }

        return true;
      },
      child: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: Container(
          color: _themeProvider.backgroundColor,
          child: ListView.separated(
            addAutomaticKeepAlives: true,
            itemCount: _postList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
                child: PostFeed(post: _postList[index]),
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                color: _themeProvider.textColor,
                indent: 16,
                endIndent: 16,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _postService = Provider.of<PostService>(context);

    _loadPosts();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("home_title"),
        ),
        backgroundColor: _themeProvider.backgroundColor,
        elevation: 0,
        brightness: _themeProvider.setBrightness(),
        centerTitle: true,
      ),
      body: _displaysBody(),
      floatingActionButton: LYFloatingActionButton(
        theme: _themeProvider.theme,
        iconData: Icons.add,
        onClick: _redirectToNewPostPage,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
