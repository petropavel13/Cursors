import UIKit
import Cursors

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let appWindow = UIWindow(frame: UIScreen.main.bounds)
        window = appWindow
        appWindow.rootViewController = TabBarViewController()
        appWindow.makeKeyAndVisible()

        return true
    }
}

