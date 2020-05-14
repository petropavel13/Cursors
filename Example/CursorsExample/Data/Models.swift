enum ContentType: String, Codable, CaseIterable {
    case audio
    case video
    case image
}

struct Content: Codable {
    let id: Int64
    let title: String
    let type: ContentType
}

struct PaginatedFeed: Codable {
    let totalCount: Int
    let totalPages: Int
    let feed: [Content]
}
