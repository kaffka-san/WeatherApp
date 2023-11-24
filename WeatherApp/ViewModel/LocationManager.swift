//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 03.07.2023.
//

import Foundation
import CoreLocation

class LocationDataManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
            locationManager.requestLocation()

        case .restricted:
            authorizationStatus = .restricted

        case .denied:
            authorizationStatus = .denied

        case .notDetermined:
            authorizationStatus = .notDetermined
            manager.requestWhenInUseAuthorization()

        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country: String?, _ error: Error?) -> Void) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}
