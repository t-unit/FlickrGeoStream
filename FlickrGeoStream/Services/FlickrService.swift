//
//  FlickrService.swift
//  FlickrGeoStream
//
//  Created by Tobias Ottenweller on 25.07.17.
//  Copyright © 2017 Tobias Ottenweller. All rights reserved.
//

import Foundation
import CoreLocation

class FlickrService {
    
    let apiKey: String
    let session: URLSession
    let decoder = JSONDecoder()
    let callbackQueue = DispatchQueue.main
    
    init(apiKey: String, session: URLSession = URLSession.shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    func search(coordinate: CLLocationCoordinate2D, completionHandler: @escaping (FlickrSearchResult?) -> Void) {
        let url = buildURL(coordinate: coordinate)

        let task = session.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                self.callbackQueue.async { completionHandler(nil) }
                return
            }

            let searchResult = try? self.decoder.decode(FlickrSearchResult.self, from: data)
            self.callbackQueue.async { completionHandler(searchResult) }
        })
        
        task.resume()
    }

    private func buildURL(coordinate: CLLocationCoordinate2D) -> URL {
        var urlComps = URLComponents(string: "https://api.flickr.com/services/rest")!
        urlComps.queryItems = [
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "per_page", value: "1"),
            URLQueryItem(name: "lat", value: String(coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(coordinate.longitude))
        ]
        return urlComps.url!
    }
}
