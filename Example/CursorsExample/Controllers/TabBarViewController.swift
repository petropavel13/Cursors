import UIKit
import Cursors

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        let cursor = FeedCursor()
        let cursor = SimpleStubCursor<Content>.stubFeedCursor()

        let feedController = FeedViewController(cursor: cursor.clone())
        let pagedController = FilteredViewController(cursor: cursor.clone())

        let controllers = [
            UINavigationController(rootViewController: feedController),
            UINavigationController(rootViewController: pagedController)
        ]

        let items = [
            UITabBarItem(title: "Common", image: #imageLiteral(resourceName: "ic_feed"), selectedImage: nil),
            UITabBarItem(title: "Paged", image: #imageLiteral(resourceName: "ic_bookmark"), selectedImage: nil)
        ]

        viewControllers = controllers

        zip([feedController, pagedController], ["Feed", "Paged feed"]).forEach {
            $0.0.title = $0.1
        }

        zip(controllers, items).forEach {
            $0.0.tabBarItem = $0.1
        }
    }

}
