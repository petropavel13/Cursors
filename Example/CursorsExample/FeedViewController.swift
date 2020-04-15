import UIKit
import Cursors

final class FeedViewController<Cursor: CursorType & ResettableType>: UIViewController, UITableViewDataSource where Cursor.Element == Content {

    private var content: [Content] = []

    private var cursor: Cursor

    private let tableView = UITableView()

    init(cursor: Cursor) {
        self.cursor = cursor

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addViews()
        bindViews()
        configureAppearance()
        configureLayout()
    }

    private func addViews() {
        view.addSubview(tableView)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)

        tableView.refreshControl = refreshControl
    }

    private func bindViews() {
        tableView.dataSource = self

        tableView.register(FeedItemCell.self, forCellReuseIdentifier: "FeedItemCell")

        loadData()
    }

    private func configureLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureAppearance() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
    }

    private func loadData() {
        cursor.loadNextPage { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(result):
                    self.handle(result: result)
                case let .failure(error):
                    self.handle(error: error)
                }
            }
        }
    }

    private func handle(result: Cursor.SuccessResult) {
        tableView.refreshControl?.endRefreshing()
        content.append(contentsOf: result.elements)
        tableView.reloadData()

        if result.exhausted {
            tableView.finishInfiniteScroll()
            tableView.removeInfiniteScroll()
        } else {
            tableView.finishInfiniteScroll()

            tableView.addInfiniteScroll { _ in
                self.loadData()
            }
        }
    }

    private func handle(error: Cursor.Failure) {
        tableView.refreshControl?.endRefreshing()
        tableView.finishInfiniteScroll()
    }

    // MARK: - Actions

    @objc func reloadData() {
        cursor = cursor.reset()
        content.removeAll()
        loadData()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedItemCell", for: indexPath)

        guard let feedCell = cell as? FeedItemCell else {
            return UITableViewCell()
        }

        feedCell.configure(with: content[indexPath.row])
        return feedCell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
}
