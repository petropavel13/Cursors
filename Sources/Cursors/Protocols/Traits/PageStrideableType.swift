public protocol PageStrideableType: PositionableType where Position: PageIndexableType {
    func position(after page: Position.Page) -> Position?
    func position(before page: Position.Page) -> Position?
}
