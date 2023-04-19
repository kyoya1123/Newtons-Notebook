import SwiftUI
import UIKit
import AVFoundation

@main
struct MyApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            TopView()
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        try! AVAudioSession.sharedInstance().setCategory(.ambient)
        try! AVAudioSession.sharedInstance().setActive(true)
        return true
    }
}
