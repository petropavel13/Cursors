import UIKit

final class FeedItemCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let iconImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        initializeView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initializeView()
    }

    func configure(with model: Content) {
        titleLabel.text = model.title
        iconImageView.image = model.type.icon
    }

    private func addViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconImageView)
    }

    private func configureAppearance() {
        selectionStyle = .none
        iconImageView.contentMode = .center
    }

    private func configureLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let titleConstraints = [
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 48)
        ]

        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let iconConstraints = [
            iconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            iconImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 32)
        ]

        NSLayoutConstraint.activate(titleConstraints + iconConstraints)
    }

    private func initializeView() {
        addViews()
        configureAppearance()
        configureLayout()
    }
}

private extension ContentType {
    var icon: UIImage {
        switch self {
        case .audio:
            return #imageLiteral(resourceName: "ic_audio")
        case .video:
            return #imageLiteral(resourceName: "ic_video")
        case .image:
            return #imageLiteral(resourceName: "ic_image")
        }
    }
}
