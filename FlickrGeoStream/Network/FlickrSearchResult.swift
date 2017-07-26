//
//  FlickrSearchResult.swift
//  FlickrGeoStream
//
//  Created by Tobias Ottenweller on 25.07.17.
//  Copyright © 2017 Tobias Ottenweller. All rights reserved.
//

import Foundation

struct FlickrSearchResult: Decodable {
    
    struct Photo: Decodable {

        private enum CodingKeys: String, CodingKey {
            case url = "url_m"
        }

        let url: URL
    }

    private enum CodingKeys: String, CodingKey {
        case photos = "photo"
    }
    
    let photos: [Photo]
}
