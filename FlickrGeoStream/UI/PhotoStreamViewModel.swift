//
//  PhotoStreamViewModel.swift
//  FlickrGeoStream
//
//  Created by Tobias Ottenweller on 26.07.17.
//  Copyright © 2017 Tobias Ottenweller. All rights reserved.
//

import UIKit

class PhotoStreamViewModel {

    private(set) var isRunning = false
    private(set) var images: [UIImage] = []

    private let notificationCenter = NotificationCenter.default
    private let locationController: LocationController
    private let imageManager: ImageManager

    private var observers: [NSObjectProtocol] = []

    init(locationController: LocationController, imageManager: ImageManager) {
        self.locationController = locationController
        self.imageManager = imageManager

        registerObservers()
        updateImages()
        updateRunning()
    }

    deinit {
        observers.forEach { notificationCenter.removeObserver($0) }
    }
    
    func toggleRunning() {
        if locationController.isRunning {
            locationController.stop()
        } else {
            locationController.start()
        }

        updateRunning()
    }
    
    private func registerObservers() {
        let queue = OperationQueue.main

        let addName = Notification.Name.ImageManagerAddedImage
        let addedObserver = notificationCenter.addObserver(forName: addName, object: nil, queue: queue) { [weak self] _ in
            self?.updateImages()
        }
        observers.append(addedObserver)
        
        let changeName = Notification.Name.LocationControllerRunningChanged
        let changeObserver = notificationCenter.addObserver(forName: changeName, object: locationController, queue: queue) { [weak self] _ in
            self?.updateRunning()
        }
        observers.append(changeObserver)
    }
    
    private func updateImages() {
        imageManager.get { [weak self] in
            self?.images = $0
        }
    }

    private func updateRunning() {
        isRunning = locationController.isRunning
    }
}
