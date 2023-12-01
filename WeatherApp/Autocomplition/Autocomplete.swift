import Combine
import Foundation

@MainActor
final class AutocompleteObject: ObservableObject {
    let delay: TimeInterval = 0.3
    @Published var suggestions: [String] = []

    init() {
    }

    private let citiesCache = CitiesCache(source: CitiesFile()!)
    private var task: Task<Void, Never>?

    func autocomplete(_ text: String) {
        guard !text.isEmpty else {
            suggestions = []
            task?.cancel()
            return
        }

        task?.cancel()

        task = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000.0))
                guard !Task.isCancelled else {
                    return
                }

                let newSuggestions = await citiesCache.lookup(prefix: text)

                suggestions = newSuggestions
            } catch {}
        }
    }
}
