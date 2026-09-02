import UIKit
import AVFoundation
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var errorLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Error label (hidden by default)
        errorLabel = UILabel(frame: CGRect(x: 16, y: 100, width: view.bounds.width - 32, height: 120))
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.textColor = .red
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.text = ""
        errorLabel.isHidden = true
        errorLabel.autoresizingMask = [.flexibleWidth]
        view.addSubview(errorLabel)

        // Activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2 - 40)
        activityIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        // WebView
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        if #available(iOS 15.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        view.addSubview(webView)

        loadRemote()
    }

    func loadRemote() {
        guard let url = URL(string: "https://xyz-podcast.pages.dev") else {
            showError("Invalid URL")
            return
        }
        errorLabel.isHidden = true
        activityIndicator.startAnimating()
        var req = URLRequest(url: url)
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        req.timeoutInterval = 30
        webView.load(req)
    }

    func showError(_ msg: String) {
        activityIndicator.stopAnimating()
        errorLabel.text = msg + "\n\nTap anywhere to retry"
        errorLabel.isHidden = false
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Tap to retry when error shown
        if !errorLabel.isHidden {
            loadRemote()
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        errorLabel.isHidden = true
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showError("Load failed: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showError("Connection failed: \(error.localizedDescription)")
    }

    @available(iOS 15.0, *)
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Page started rendering
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView?.frame = view.bounds
        activityIndicator?.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2 - 40)
        errorLabel?.frame = CGRect(x: 16, y: 100, width: view.bounds.width - 32, height: 120)
    }
}
