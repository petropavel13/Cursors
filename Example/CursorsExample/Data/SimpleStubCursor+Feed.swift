import Cursors

extension SimpleStubCursor {
    static func stubFeedCursor(pageSize: Int = 12) -> SimpleStubCursor<Content> {
        let contentTypes = ContentType.allCases

        let feedItems: [Content] = (1...Int64.random(in: 128...256)).map {
            let title: String
            let contentType = contentTypes.randomElement()!

            switch contentType {
            case .audio:
                title = "Audio message \($0)"
            case .video:
                title = "Video message \($0)"
            case .image:
                title = "Image message \($0)"
            }

            return Content(id: $0, title: title, type: contentType)
        }

        let totalCount = feedItems.count

        let pages = stride(from: 0, to: totalCount, by: pageSize).map {
            Array(feedItems[$0..<min($0 + pageSize, totalCount)])
        }

        return SimpleStubCursor<Content>(pages: pages)
    }
}
