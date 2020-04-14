public protocol ClonableType {
    init(keepingStateOf other: Self)
}

public extension ClonableType {
    func clone() -> Self {
        return Self(keepingStateOf: self)
    }
}
