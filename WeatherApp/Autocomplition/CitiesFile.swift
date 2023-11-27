
import Foundation

struct CitiesFile: CitiesSource {
    let location: URL

    init(location: URL) {
        self.location = location
    }

    /// Looks up for `cities` file in the main bundle
    init?() {
        guard let location = Bundle.main.url(forResource: "cities", withExtension: nil) else {
            print("cities file is not in the main bundle")
            assertionFailure("cities file is not in the main bundle")
            return nil
        }

        self.init(location: location)
    }

    func loadCities() -> [String] {
        do {
            let data = try Data(contentsOf: location)
            let string = String(data: data, encoding: .utf8)
            return string?.components(separatedBy: .newlines) ?? []
        }
        catch {
            return []
        }
    }
}
