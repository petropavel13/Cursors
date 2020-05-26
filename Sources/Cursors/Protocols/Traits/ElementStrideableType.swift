public protocol ElementStrideableType: PositionableType where Position: ElementIndexableType, Position.Element: Strideable {
    func position(advancedBy stride: Position.Element.Stride) -> Position?
}
