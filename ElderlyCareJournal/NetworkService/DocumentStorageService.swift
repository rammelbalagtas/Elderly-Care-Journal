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

    public static func getDownloadURL(path: String, storage: StorageReference, callback: @escaping (Result<URL, Error>) -> Void) {
        
        // Create a reference to the file you want to download
        let reference = storage.child(path)
        
        // Fetch the download URL
        reference.downloadURL
        { url, error in
            if let error = error {
                callback(.failure(error))
            } else {
                if let url = url {
                    callback(.success(url))
                }
            }
        }
    }
    
    public static func delete(path: String, storage: StorageReference, callback: @escaping (Result<String, Error>) -> Void) {
        
        let reference = storage.child(path)
        reference.delete { error in
            if let error = error {
                callback(.failure(error))
            } else {
                callback(.success(path))
            }
        }
    }
    
}
