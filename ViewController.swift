import UIKit
import WebKit

/// WKWebView 壳：直接加载远程网页版 xyz-podcast.pages.dev
/// 复用网页版已修好的 /relay 音频代理，无需在原生层重写播放逻辑。
class ViewController: UIViewController, WKNavigationDelegate {

    static let remoteURL = "https://xyz-podcast.pages.dev"

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadRemote()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        // 允许内联播放（不弹出全屏 AirPlay 选择器）
        config.allowsInlineMediaPlayback = true
        // 允许编程触发播放（自动续播 / 点播不需用户手势）
        config.mediaTypesRequiringUserActionForPlayback = []

        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)
    }

    private func loadRemote() {
        guard let url = URL(string: ViewController.remoteURL) else { return }
        var req = URLRequest(url: url)
        // 始终忽略缓存，保证拿到最新前端
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        webView.load(req)
    }

    // MARK: - 错误处理 + 重试
    func webView(_ webView: WKWebView,
                 didFail navigation: WKNavigation!,
                 withError error: Error) {
        showRetry(error.localizedDescription)
    }

    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        showRetry(error.localizedDescription)
    }

    private func showRetry(_ msg: String) {
        let alert = UIAlertController(title: "加载失败",
                                      message: msg,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "重试", style: .default) { [weak self] _ in
            self?.loadRemote()
        })
        present(alert, animated: true)
    }
}
