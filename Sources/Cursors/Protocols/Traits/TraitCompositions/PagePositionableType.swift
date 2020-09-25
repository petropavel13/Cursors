public protocol PagePositionableType: PositionableType where Position: PageIndexableType {
    func position(after page: Position.PageIndex) -> Position?
    func position(before page: Position.PageIndex) -> Position?
}
