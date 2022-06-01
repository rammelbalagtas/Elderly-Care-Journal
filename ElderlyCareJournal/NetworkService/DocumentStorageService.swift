//
//  DocumentStorageService.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-31.
//

import Foundation
import UIKit
import FirebaseStorage

struct DocumentStorageService {
    
    public static func upload(path: String, localFile: URL, storage: StorageReference, callback: @escaping (Result<StorageMetadata, Error>) -> Void) {

        let ref = storage.child(path)
        
        let uploadTask = ref.putFile(from: localFile)
        { metadata, error in
            guard let metadata = metadata else {
                if let error = error {
                    callback(.failure(error))
                }
                return
            }
            callback(.success(metadata))
        }
        
        uploadTask.resume()
        
    }

    public static func download(path: String, storage: StorageReference, callback: @escaping (Result<UIImage, Error>) -> Void) {
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
