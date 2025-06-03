// lib/screens/video/webview_video_player.dart - الحل الأبسط والأضمن
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smart_lms/models/course.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final Course course;

  const WebViewVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.course,
  });

  @override
  State<WebViewVideoPlayer> createState() => _WebViewVideoPlayerState();
}

class _WebViewVideoPlayerState extends State<WebViewVideoPlayer> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _loadingText = 'Loading video...';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      // تحويل الرابط لصيغة embed
      String embedUrl = _convertToEmbedUrl(widget.videoUrl);
      print('🎥 Loading video URL: $embedUrl');

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent(
            'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15')
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _loadingText = 'Loading video...';
              });
              print('📄 Page loading started: $url');
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
              print('✅ Page loading finished: $url');
            },
            onWebResourceError: (WebResourceError error) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
              print('❌ WebView error: ${error.description}');
            },
            onNavigationRequest: (NavigationRequest request) {
              print('🔗 Navigation to: ${request.url}');
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(embedUrl));
    } catch (e) {
      print('❌ Error initializing WebView: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  String _convertToEmbedUrl(String originalUrl) {
    try {
      print('🔄 Converting URL: $originalUrl');

      // YouTube watch URL
      if (originalUrl.contains('youtube.com/watch?v=')) {
        String videoId = originalUrl.split('v=')[1].split('&')[0];
        String embedUrl =
            'https://www.youtube.com/embed/$videoId?autoplay=0&rel=0&modestbranding=1';
        print('📹 Video embed URL: $embedUrl');
        return embedUrl;
      }

      // YouTube short URL
      else if (originalUrl.contains('youtu.be/')) {
        String videoId = originalUrl.split('youtu.be/')[1].split('?')[0];
        String embedUrl =
            'https://www.youtube.com/embed/$videoId?autoplay=0&rel=0&modestbranding=1';
        print('📹 Video embed URL: $embedUrl');
        return embedUrl;
      }

      // YouTube Playlist
      else if (originalUrl.contains('playlist?list=')) {
        String playlistId = originalUrl.split('list=')[1].split('&')[0];
        String embedUrl =
            'https://www.youtube.com/embed/videoseries?list=$playlistId&autoplay=0&rel=0';
        print('📋 Playlist embed URL: $embedUrl');
        return embedUrl;
      }

      // إذا كان embed URL جاهز
      else if (originalUrl.contains('youtube.com/embed/')) {
        return originalUrl;
      }

      // Default fallback - Flutter introduction video
      String fallbackUrl =
          'https://www.youtube.com/embed/HQ_ytw58tC4?autoplay=0&rel=0&modestbranding=1';
      print('🔄 Using fallback video: $fallbackUrl');
      return fallbackUrl;
    } catch (e) {
      print('❌ Error converting URL: $e');
      return 'https://www.youtube.com/embed/HQ_ytw58tC4?autoplay=0&rel=0&modestbranding=1';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.course.displayTitle,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _reloadVideo,
            tooltip: 'Reload Video',
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Player Area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                children: [
                  if (!_hasError) WebViewWidget(controller: _controller),

                  // Loading Indicator
                  if (_isLoading)
                    Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.teal,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              _loadingText.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please wait...',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Error State
                  if (_hasError)
                    Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Cannot load video'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Check your internet connection',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _reloadVideo,
                              icon: Icon(Icons.refresh),
                              label: Text('Retry'.tr()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Course Info Area
          Expanded(
            flex: 2,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Title
                    Text(
                      widget.course.displayTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Course Description
                    Text(
                      widget.course.displayDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Course Stats
                    _buildCourseStats(theme),
                    SizedBox(height: 20),

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseStats(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.star, '${widget.course.rating}', 'Rating'),
          _buildStatItem(
              Icons.access_time, widget.course.displayDuration, 'Duration'),
          _buildStatItem(
              Icons.people, '${widget.course.displayStudents}+', 'Students'),
          _buildStatItem(Icons.school, widget.course.displayLevel, 'Level'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.teal),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _markAsCompleted,
            icon: Icon(Icons.check_circle_outline),
            label: Text('Complete'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _shareVideo,
            icon: Icon(Icons.share),
            label: Text('Share'.tr()),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _reloadVideo() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _loadingText = 'Reloading video...';
    });
    _controller.reload();
  }

  void _markAsCompleted() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Video marked as completed!'.tr()),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.share, color: Colors.white),
            SizedBox(width: 8),
            Text('Video link ready to share!'.tr()),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
