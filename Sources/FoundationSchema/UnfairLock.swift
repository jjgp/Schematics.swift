import Foundation

/// A convenience abstraction around the `os_unfair_lock`
public final class UnfairLock {
    /// The underlying `os_unfair_lock`
    public let unfairLock: UnsafeMutablePointer<os_unfair_lock>

    /// Initialize an `os_unfair_lock`
    public init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    /// Execute a block within the lock. This call will be inlined.
    ///
    /// - Parameter block: A block that returns nothing.
    @inlinable
    public func callAsFunction(block: () -> Void) {
        os_unfair_lock_lock(unfairLock)
        block()
        os_unfair_lock_unlock(unfairLock)
    }

    /// Execute a block within the lock. This call will be inlined.
    ///
    /// - Parameter block: A block that returns `T`.
    /// - Returns: `T`.
    @inlinable
    public func callAsFunction<T>(block: () -> T) -> T {
        os_unfair_lock_lock(unfairLock)
        defer {
            os_unfair_lock_unlock(unfairLock)
        }

        return block()
    }

    /// Lock the `os_unfair_lock`
    @inlinable
    public func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    /// Unlock the `os_unfair_lock`
    @inlinable
    public func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}
