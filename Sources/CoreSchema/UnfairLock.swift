import Foundation

public final class UnfairLock {
    public let unfairLock: UnsafeMutablePointer<os_unfair_lock>

    public init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    @inlinable
    public func callAsFunction(block: () -> Void) {
        os_unfair_lock_lock(unfairLock)
        block()
        os_unfair_lock_unlock(unfairLock)
    }

    @inlinable
    public func callAsFunction<T>(block: () -> T) -> T {
        os_unfair_lock_lock(unfairLock)
        defer {
            os_unfair_lock_unlock(unfairLock)
        }

        return block()
    }

    @inlinable
    public func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    @inlinable
    public func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}
