func asyncReturn<T>(_ returnValue: T) async -> T? {
    try? await Task {
        returnValue
    }.result.get()
}
