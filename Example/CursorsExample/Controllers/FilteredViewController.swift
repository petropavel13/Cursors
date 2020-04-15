import Parchment
import Cursors

typealias FeedCursor = CursorType & ClonableType & ResettableType

final class FilteredViewController<Cursor: FeedCursor>: PagingViewController, PagingViewControllerDataSource where Cursor.Element == Content {

    private let cursor: Cursor

    private let contentTypes = ContentType.allCases

    private var pagingEnabled = false

    init(cursor: Cursor) {
        self.cursor = cursor
        var options = PagingOptions()
        options.menuInsets = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)

        super.init(options: options)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self

        view.backgroundColor = .white

        updateNavigationButtons()
    }

    // MARK: - PagingViewControllerDataSource

    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return 3
    }

    func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        let pageContentType = contentTypes[index]
        let pageCursor = cursor.clone()
            .filter { $0.type == pageContentType }

        if pagingEnabled {
            return FeedViewController(cursor: pageCursor.paged(by: 16))
        } else {
            return FeedViewController(cursor: pageCursor)
        }
    }

    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return PagingIndexItem(index: index, title: contentTypes[index].pageTitle)
    }

    // MARK: - Actions

    @objc private func togglePaging() {
        pagingEnabled.toggle()
        updateNavigationButtons()
        reloadData()
    }

    // MARK: - Private

    private func updateNavigationButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Paging: \(pagingEnabled ? "on" : "off")",
            style: .plain,
            target: self,
            action: #selector(togglePaging))
    }
}

private extension ContentType {
    var pageTitle: String {
        switch self {
        case .audio:
            return "Audio"
        case .video:
            return "Video"
        case .image:
            return "Image"
        }
    }
}
