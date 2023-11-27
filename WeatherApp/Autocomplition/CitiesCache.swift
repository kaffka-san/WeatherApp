

/// The source of all city names
protocol CitiesSource {

    func loadCities() -> [String]
}

/// The `CitiesCache` object manages the list of city names loaded from an external source.
actor CitiesCache {

    /// Source to load city names.
    let source: CitiesSource
    private var cachedCities: [String]?
    init(source: CitiesSource) {
        self.source = source
    }

    /// The list of city names.
    var cities: [String] {
        if let cities = cachedCities {
            return cities
        }
        let cities = source.loadCities()
        cachedCities = cities
        return cities
    }
}

extension CitiesCache {

    /// Returns a list of city names filtered using given prefix.
    ///
    /// Lookup is case insensitive and diacritic insensitive:
    ///     "ams" will return ["Amstelveen", "Amsterdam", "Amsterdam-Zuidoost", "Amstetten"]
    ///     "krako" will return ["Kraków"]
    ///
    /// Lookup is a linear time operation.
    func lookup(prefix: String) -> [String] {
        cities.filter { $0.hasCaseAndDiacriticInsensitivePrefix(prefix) }
    }
}
