public protocol ResettableType {
    init(withInitialStateFrom other: Self)
}

public extension ResettableType {
    func reset() -> Self {
        return Self(withInitialStateFrom: self)
    }
}
