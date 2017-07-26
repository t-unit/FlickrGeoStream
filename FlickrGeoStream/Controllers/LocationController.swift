//
//  LocationController.swift
//  FlickrGeoStream
//
//  Created by Tobias Ottenweller on 25.07.17.
//  Copyright © 2017 Tobias Ottenweller. All rights reserved.
//

import UIKit
import CoreLocation

class LocationController: NSObject {

    private(set) var isRunning = false

    let radius: CLLocationDistance = 100
    let locationManager = CLLocationManager()
    private var currentRegion: CLRegion?
    private let flickrImageService: FlickrImageService

    init(flickrImageService: FlickrImageService) {
        self.flickrImageService = flickrImageService
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // not good for the battery
    }

    func start() {
        guard !isRunning else {
            return
        }
        
        isRunning = true
        locationManager.requestLocation()
    }

    func stop() {
        if let currentRegion = currentRegion {
            locationManager.stopMonitoring(for: currentRegion)
            self.currentRegion = nil
        }
        
        isRunning = false
    }

    private func startMonitoring(withCoordinate coordinate: CLLocationCoordinate2D) {
        if let currentRegion = currentRegion {
            locationManager.stopMonitoring(for: currentRegion)
        }
        
        let region = CLCircularRegion(center: coordinate, radius: radius, identifier: UUID().uuidString)
        locationManager.startMonitoring(for: region)
        currentRegion = region
    }
    
    private func handle(location: CLLocation) {
        flickrImageService.fetch(coordinate: location.coordinate) { image in
            guard let image = image else {
                return // silent failing here
            }

            print(image)
        }
    }
}

extension LocationController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach { handle(location: $0) }
        startMonitoring(withCoordinate: locations.last!.coordinate)
    }
}
