import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class AppWebView extends StatefulWidget {
  const AppWebView({
    super.key,
    required this.initialUrl,
    this.loadingMessage,
    this.onPageStarted,
    this.onPageFinished,
    this.backgroundColor,
  });

  final String initialUrl;
  final String? loadingMessage;
  final ValueChanged<String>? onPageStarted;
  final ValueChanged<String>? onPageFinished;
  final Color? backgroundColor;

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  double _loadingProgress = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(widget.initialUrl),
          ),
          initialSettings: InAppWebViewSettings(
            // JavaScript 设置
            javaScriptEnabled: true,
            javaScriptCanOpenWindowsAutomatically: true,
            domStorageEnabled: true,

            // 媒体播放 - 支持内联播放，全屏时自动使用系统播放器
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true, // 允许内联播放
            allowsPictureInPictureMediaPlayback: true,

            // 缓存和存储
            cacheEnabled: true,
            clearCache: false,

            // 用户交互
            supportZoom: true,
            builtInZoomControls: true,
            displayZoomControls: false,

            // 性能优化
            useHybridComposition: true, // Android 性能优化
            disableHorizontalScroll: false,
            disableVerticalScroll: false,

            // 安全性和兼容性
            allowsBackForwardNavigationGestures: true,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW, // 允许混合内容
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,

            // 网络
            useShouldOverrideUrlLoading: true, // 启用 URL 拦截处理
            useOnLoadResource: true, // 启用资源加载监听
            useOnDownloadStart: true, // 启用下载处理

            // 背景色
            transparentBackground: widget.backgroundColor != null,
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          onLoadStart: (controller, url) {
            if (!mounted) return;
            setState(() => _isLoading = true);
            widget.onPageStarted?.call(url?.toString() ?? '');
          },
          onLoadStop: (controller, url) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            widget.onPageFinished?.call(url?.toString() ?? '');
          },
          onProgressChanged: (controller, progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress / 100;
              _isLoading = progress < 100;
            });
          },
          onReceivedError: (controller, request, error) {
            if (!mounted) return;
            // ignore: avoid_print
            print('[WebView Error] ${error.type}: ${error.description}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('加载失败: ${error.description}\n错误类型: ${error.type}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: '重试',
                  textColor: Colors.white,
                  onPressed: () {
                    _webViewController?.reload();
                  },
                ),
              ),
            );
          },
          onReceivedHttpError: (controller, request, errorResponse) {
            if (!mounted) return;
            final statusCode = errorResponse.statusCode;
            if (statusCode != null && statusCode >= 400) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('HTTP 错误: $statusCode'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          onConsoleMessage: (controller, consoleMessage) {
            // 打印控制台消息，方便调试
            // ignore: avoid_print
            print('[WebView Console] ${consoleMessage.messageLevel}: ${consoleMessage.message}');
          },
          onLoadResource: (controller, resource) {
            // 打印加载的资源，方便调试
            // ignore: avoid_print
            print('[WebView Resource] Loading: ${resource.url}');
          },
          onDownloadStartRequest: (controller, downloadStartRequest) async {
            // 处理下载请求
            // ignore: avoid_print
            print('[WebView] Download request: ${downloadStartRequest.url}');
            // 暂不处理下载，只是打印日志
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final uri = navigationAction.request.url;
            if (uri == null) {
              return NavigationActionPolicy.ALLOW;
            }

            final urlString = uri.toString();
            final initialUri = Uri.parse(widget.initialUrl);

            // 如果是初始URL，允许加载
            if (urlString == widget.initialUrl) {
              return NavigationActionPolicy.ALLOW;
            }

            // 如果是同一域名的链接，允许在 WebView 中加载
            if (uri.host == initialUri.host) {
              return NavigationActionPolicy.ALLOW;
            }

            // 对于外部链接（不同域名），使用默认浏览器打开
            // ignore: avoid_print
            print('[WebView] 检测到外部链接，使用默认浏览器打开: $urlString');
            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication, // 使用外部浏览器
                );
                // ignore: avoid_print
                print('[WebView] 已在默认浏览器中打开: $urlString');
              } else {
                // ignore: avoid_print
                print('[WebView] 无法打开URL: $urlString');
              }
            } catch (e) {
              // ignore: avoid_print
              print('[WebView] 打开默认浏览器失败: $e');
            }

            // 取消在 WebView 中的导航
            return NavigationActionPolicy.CANCEL;
          },
          onEnterFullscreen: (controller) {
            // 进入全屏模式
            // ignore: avoid_print
            print('[WebView] 进入全屏模式');
          },
          onExitFullscreen: (controller) {
            // 退出全屏模式
            // ignore: avoid_print
            print('[WebView] 退出全屏模式');
          },
          onCreateWindow: (controller, createWindowAction) async {
            // 处理网页尝试打开新窗口的请求
            final url = createWindowAction.request.url;
            // ignore: avoid_print
            print('[WebView] onCreateWindow 被触发');
            // ignore: avoid_print
            print('[WebView] URL: $url');

            if (url == null) {
              return true;
            }

            final urlString = url.toString();
            final initialUri = Uri.parse(widget.initialUrl);

            // 1. 优先检查是否是视频URL
            if (urlString.contains('.m3u8') ||
                urlString.contains('.mp4') ||
                urlString.contains('.ts') ||
                urlString.contains('video')) {
              // ignore: avoid_print
              print('[WebView] 检测到视频URL，尝试触发iOS系统播放器');

              // 注入 JavaScript 尝试触发 video 元素的全屏
              try {
                final result = await controller.evaluateJavascript(source: '''
                  (function() {
                    // 查找所有 video 元素
                    var videos = document.getElementsByTagName('video');
                    console.log('找到 ' + videos.length + ' 个 video 元素');

                    if (videos.length > 0) {
                      // 优先查找正在播放或已暂停但有内容的视频
                      var targetVideo = null;

                      for (var i = 0; i < videos.length; i++) {
                        var video = videos[i];
                        // 检查视频是否有内容（duration > 0）或正在播放
                        if (!video.paused || video.currentTime > 0 || video.duration > 0) {
                          targetVideo = video;
                          console.log('找到目标视频: ' + i + ', 状态: paused=' + video.paused + ', currentTime=' + video.currentTime);
                          break;
                        }
                      }

                      // 如果没有找到正在播放的，就用第一个
                      if (!targetVideo && videos.length > 0) {
                        targetVideo = videos[0];
                        console.log('使用第一个视频元素');
                      }

                      if (targetVideo) {
                        console.log('尝试全屏播放');
                        // 先确保视频已加载
                        if (targetVideo.readyState >= 2) {
                          console.log('视频已准备好，readyState=' + targetVideo.readyState);
                        }

                        // iOS 使用 webkitEnterFullscreen
                        if (targetVideo.webkitEnterFullscreen) {
                          console.log('调用 webkitEnterFullscreen');
                          targetVideo.webkitEnterFullscreen();
                          return 'iOS fullscreen triggered';
                        } else if (targetVideo.requestFullscreen) {
                          console.log('调用 requestFullscreen');
                          targetVideo.requestFullscreen();
                          return 'HTML5 fullscreen triggered';
                        } else {
                          console.log('不支持全屏');
                          return 'fullscreen not supported';
                        }
                      }
                    }
                    return 'no video found';
                  })();
                ''');
                // ignore: avoid_print
                print('[WebView] JavaScript 执行结果: $result');
              } catch (e) {
                // ignore: avoid_print
                print('[WebView] 触发全屏失败: $e');
              }

              // 返回 true 阻止打开新窗口
              return true;
            }

            // 2. 检查是否是同域名链接
            if (url.host == initialUri.host) {
              // ignore: avoid_print
              print('[WebView] 检测到同域名链接，在 WebView 内加载: $urlString');
              try {
                // 在当前 WebView 中加载该 URL
                await controller.loadUrl(
                  urlRequest: URLRequest(url: url),
                );
                // ignore: avoid_print
                print('[WebView] 已在 WebView 内加载同域名链接');
              } catch (e) {
                // ignore: avoid_print
                print('[WebView] 在 WebView 内加载失败: $e');
              }
              return true;
            }

            // 3. 外部域名链接，使用默认浏览器打开
            // ignore: avoid_print
            print('[WebView] 检测到外部域名链接，使用默认浏览器打开: $urlString');
            try {
              if (await canLaunchUrl(url)) {
                await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication, // 使用外部浏览器
                );
                // ignore: avoid_print
                print('[WebView] 已在默认浏览器中打开: $urlString');
              } else {
                // ignore: avoid_print
                print('[WebView] 无法打开URL: $urlString');
              }
            } catch (e) {
              // ignore: avoid_print
              print('[WebView] 打开默认浏览器失败: $e');
            }

            // 阻止创建新窗口
            return true;
          },
        ),
        if (_isLoading)
          Container(
            color: widget.backgroundColor ?? theme.scaffoldBackgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: _loadingProgress > 0 ? _loadingProgress : null,
                          color: theme.colorScheme.primary,
                          strokeWidth: 4,
                        ),
                      ),
                      if (_loadingProgress > 0)
                        Text(
                          '${(_loadingProgress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                  if (widget.loadingMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.loadingMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
