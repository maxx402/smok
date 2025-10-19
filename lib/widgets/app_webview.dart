import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
            // 允许所有导航在当前 WebView 中进行
            return NavigationActionPolicy.ALLOW;
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

            // 检查是否是视频URL
            if (url != null) {
              final urlString = url.toString();

              // 如果是视频文件，尝试触发原生全屏
              if (urlString.contains('.m3u8') ||
                  urlString.contains('.mp4') ||
                  urlString.contains('.ts') ||
                  urlString.contains('video')) {
                // ignore: avoid_print
                print('[WebView] 检测到视频URL，尝试触发原生全屏');

                // 注入 JavaScript 尝试触发 video 元素的全屏
                try {
                  await controller.evaluateJavascript(source: '''
                    (function() {
                      var videos = document.getElementsByTagName('video');
                      if (videos.length > 0) {
                        var video = videos[0];
                        if (video.webkitEnterFullscreen) {
                          video.webkitEnterFullscreen();
                        } else if (video.requestFullscreen) {
                          video.requestFullscreen();
                        }
                        return 'fullscreen triggered';
                      }
                      return 'no video found';
                    })();
                  ''');
                  // ignore: avoid_print
                  print('[WebView] 已尝试触发视频全屏');
                } catch (e) {
                  // ignore: avoid_print
                  print('[WebView] 触发全屏失败: $e');
                }

                // 返回 true 阻止打开新窗口
                return true;
              }
            }

            // 对于非视频URL，也阻止打开新窗口
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
