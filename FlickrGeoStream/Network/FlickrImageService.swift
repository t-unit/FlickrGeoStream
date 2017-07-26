//
//  ImageController.swift
//  FlickrGeoStream
//
//  Created by Tobias Ottenweller on 25.07.17.
//  Copyright © 2017 Tobias Ottenweller. All rights reserved.
//

import UIKit
import CoreLocation

struct FlickrImageService {

    let imageService: ImageService
    let searchService: FlickrService
    
    init(imageService: ImageService, searchService: FlickrService) {
        self.imageService = imageService
        self.searchService = searchService
    }
    
    init(apiKey: String) {
        self.init(imageService: ImageService(), searchService: FlickrService(apiKey: apiKey))
    }
    
    func fetch(coordinate: CLLocationCoordinate2D, completionHandler: @escaping (UIImage?) -> Void) {
        searchService.search(coordinate: coordinate) {
            guard let photo = $0?.photos.first else {
                completionHandler(nil)
                return
            }
            self.imageService.get(url: photo.url, completionHandler: completionHandler)
        }
    }
}

