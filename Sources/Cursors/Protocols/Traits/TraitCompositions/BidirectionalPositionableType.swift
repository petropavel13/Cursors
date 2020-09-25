public protocol BidirectionalPositionableType: PositionableType {
    var movingBackwardCurrentPosition: Position { get }
}
