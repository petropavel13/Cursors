public protocol ElementStrideableType: PositionableType where Position: ElementIndexableType, Position.ElementIndex: Strideable {
    func position(advancedBy stride: Position.ElementIndex.Stride) -> Position?
}
