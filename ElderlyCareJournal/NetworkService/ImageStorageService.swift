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
    
    public static func uploadImage(path: String, image: UIImage, storage: StorageReference, callback: @escaping (Result<StorageMetadata, Error>) -> Void) {
        guard let imageData = image.pngData() else {
            return
        }
        let ref = storage.child(path)
        
        ref.putData(imageData)
        { data, error in
            guard error == nil else {
                if let error = error {
                    callback(.failure(error))
                }
                return
            }
            if let data = data {
                callback(.success(data))
            }
        }
    }

    public static func downloadImage(path: String, storage: StorageReference, callback: @escaping (Result<UIImage, Error>) -> Void) {
        // Create a reference to the file you want to download
        let imageRef = storage.child(path)
        
        // Download _ with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.getData(maxSize: 1 * 10240 * 10240)
        { data, error in
            if let error = error {
                callback(.failure(error))
            } else {
                if let data = data {
                    if let image = UIImage(data: data) {
                        callback(.success(image))
                    }
                }
            }
        }
    }
    
}
