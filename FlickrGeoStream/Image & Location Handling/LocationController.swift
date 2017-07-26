//
//  LocationController.swift
//  FlickrGeoStream
//
//  Created by Tobias Ottenweller on 25.07.17.
//  Copyright © 2017 Tobias Ottenweller. All rights reserved.
//

import UIKit
import CoreLocation

extension Notification.Name {
    
    static let LocationControllerRunningChanged = Notification.Name("LocationControllerRunningChanged")
}

class LocationController: NSObject {

    private(set) var isRunning = false {
        didSet {
            notificationCenter.post(name: .LocationControllerRunningChanged, object: self)
        }
    }

    private let radius: CLLocationDistance = 100
    private let locationManager = CLLocationManager()
    private let notificationCenter = NotificationCenter.default
    private let flickrImageService: FlickrImageService
    private let imageManager: ImageManager
    private var currentRegion: CLRegion?

    init(flickrImageService: FlickrImageService, imageManager: ImageManager = ImageManager()) {
        self.flickrImageService = flickrImageService
        self.imageManager = imageManager
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // not good for the battery
    }
    
    convenience init(apiKey: String) {
        self.init(flickrImageService: FlickrImageService(apiKey: apiKey))
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
        flickrImageService.fetch(coordinate: location.coordinate) { [weak self] image in
            guard let image = image else {
                return // silent failing here
            }
            self?.imageManager.add(image: image)
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        stop()  // should inform user at this point
    }
}
