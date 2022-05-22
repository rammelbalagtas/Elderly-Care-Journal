//
//  ImageStorageService.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-22.
//

import Foundation
import UIKit
import FirebaseStorage

struct ImageStorageService {
    
    public static func uploadImage(path: String, image: UIImage, storage: StorageReference) {
        guard let imageData = image.pngData() else {
            return
        }
        let ref = storage.child(path)
        ref.putData(imageData)
        { _, error in
            guard error == nil else {
                return
            }
        }
    }
    
    public static func downloadImage(path: String, storage: StorageReference) {
        // Create a reference to the file you want to download
        let imageRef = storage.child(path)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.getData(maxSize: 1 * 1024 * 1024)
        { data, error in
            if let error = error {
                //return error
            } else {
                if let data = data {
                    let image = UIImage(data: data)
                }
            }
        }
    }
    
}
