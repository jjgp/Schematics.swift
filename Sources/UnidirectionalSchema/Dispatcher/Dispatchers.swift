public enum Dispatchers {
    public static func userInteractive() -> CombinedDispatcher {
        CombinedDispatcher(OnQueueDispatcher(), BarrierDispatcher())
    }
}
