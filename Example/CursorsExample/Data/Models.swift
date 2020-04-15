public enum ContentType: String, Codable, CaseIterable {
    case audio
    case video
    case image
}

public struct Content: Codable {
    public let id: Int64
    public let title: String
    public let type: ContentType
}

public struct PaginatedFeed: Codable {
    public let totalCount: Int
    public let totalPages: Int
    public let feed: [Content]
}
