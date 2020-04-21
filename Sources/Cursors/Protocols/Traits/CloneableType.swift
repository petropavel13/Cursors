public protocol CloneableType {
    init(keepingStateOf other: Self)
}

public extension CloneableType {
    func clone() -> Self {
        return Self(keepingStateOf: self)
    }
}
