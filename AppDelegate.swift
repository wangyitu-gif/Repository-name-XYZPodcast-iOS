import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 播客需要后台持续播放音频
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default,
                                    options: [.allowAirPlay, .allowBackground])
            try session.setActive(true)
        } catch {
            print("[XYZ] AVAudioSession init failed: \(error)")
        }
        return true
    }

    // MARK: - UIScene lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
    }
}
