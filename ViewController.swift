import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        webView.configuration.allowsInlineMediaPlayback = true
        if #available(iOS 15.0, *) {
            webView.configuration.defaultWebpagePreferences?.allowsContentJavaScript = true
        }
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        view.addSubview(webView)
        loadRemote()
    }
    func loadRemote() {
        let url = URL(string: "https://xyz-podcast.pages.dev")!
        var req = URLRequest(url: url)
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        webView.load(req)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView?.frame = view.bounds
    }
}
