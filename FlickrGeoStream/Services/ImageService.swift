//
//  ImageService.swift
//  FlickrGeoStream
//
//  Created by Tobias Ottenweller on 25.07.17.
//  Copyright © 2017 Tobias Ottenweller. All rights reserved.
//

import UIKit

struct ImageService {
    
    let session: URLSession
    let decoder = JSONDecoder()
    let callbackQueue = DispatchQueue.main
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func get(url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        let task = session.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                self.callbackQueue.async { completionHandler(nil) }
                return
            }
            
            let image = UIImage(data: data)
            self.callbackQueue.async { completionHandler(image) }
        })
        
        task.resume()
    }
}
