//
//  ImageManager.swift
//  FlickrGeoStream
//
//  Created by Tobias Ottenweller on 26.07.17.
//  Copyright © 2017 Tobias Ottenweller. All rights reserved.
//

import UIKit

extension Notification.Name {
    
    static let ImageManagerAddedImage = Notification.Name("ImageManagerAddedImage")
}


struct ImageManager {
    
    let fileManager: FileManager
    let operationQueue = DispatchQueue(label: "ImageManager", qos: .utility)
    let completionQueue = DispatchQueue.main
    let notificationCenter = NotificationCenter.default
    
    private var documentsDirectory: URL {
        return try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }

    func get(completionHandler: @escaping ([UIImage]) -> Void) {
        operationQueue.async {
            do {
                let fileURLs = try self.fileManager.contentsOfDirectory(at: self.documentsDirectory,
                                                                    includingPropertiesForKeys: [.creationDateKey],
                                                                    options: .skipsHiddenFiles)
                
                let sortedFileURLs = try fileURLs.sorted { (url1, url2) -> Bool in
                    let keys: Set = [URLResourceKey.creationDateKey]
                    let values1 = try url1.resourceValues(forKeys: keys)
                    let values2 = try url2.resourceValues(forKeys: keys)
                    
                    return values1.creationDate! < values2.creationDate!
                }
                
                var images = [UIImage]()
                for url in sortedFileURLs {
                    if !url.absoluteString.hasSuffix(".jpg") {
                        continue
                    }
                    
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
                
                self.completionQueue.async { completionHandler(images) }
            } catch {
                print("failed getting images: \(error)")
                self.completionQueue.async { completionHandler([]) }
            }
        }
    }

    func add(image: UIImage) {
        operationQueue.async {
            let data = UIImageJPEGRepresentation(image, 0.7)
            let path = self.documentsDirectory.appendingPathComponent("\(UUID().uuidString).jpg")

            if self.fileManager.createFile(atPath: path.absoluteString, contents: data, attributes: nil) {
                self.notificationCenter.post(name: .ImageManagerAddedImage, object: self)
            } else {
                print("failed saving image to disk")
            }
        }
    }
}
