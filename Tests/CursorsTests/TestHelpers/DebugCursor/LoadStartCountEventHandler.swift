import Cursors

final class LoadStartCountEventHandler<Cursor: CursorType>: CursorObserverEventHandler {
    private(set) var onLoadForwardCount: Int
    private(set) var onLoadBackwardCount: Int

    init() {
        onLoadForwardCount = 0
        onLoadBackwardCount = 0
    }

    // MARK: - ResettableType

    convenience init(withInitialStateFrom other: LoadStartCountEventHandler<Cursor>) {
        self.init()
    }

    // MARK: - CloneableType

    init(keepingStateOf other: LoadStartCountEventHandler<Cursor>) {
        onLoadForwardCount = other.onLoadForwardCount
        onLoadBackwardCount = other.onLoadBackwardCount
    }

    // MARK: - DebugCursorState

    func onLoadStart(direction: LoadDirection) {
        switch direction {
        case .forward:
            onLoadForwardCount += 1
        case .backward:
            onLoadBackwardCount += 1
        }
    }

    func onResult(successResult: Cursor.SuccessResult, direction: LoadDirection) {
        // nothing
    }

    func onError(failure: Cursor.Failure, direction: LoadDirection) {
        // nothing
    }

    func onFinish(direction: LoadDirection) {
        // nothing
    }
}

extension CursorType {
    func countRequests() -> CursorObserver<Self, LoadStartCountEventHandler<Self>> {
        return CursorObserver(cursor: self, eventHander: LoadStartCountEventHandler())
    }
}
