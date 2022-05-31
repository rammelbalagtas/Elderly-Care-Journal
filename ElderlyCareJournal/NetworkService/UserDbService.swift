//
//  UserDbService.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-26.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserDbService {
    
    private static let db = Firestore.firestore()
    
    public static func create(user: User, callback: @escaping (Result<User, Error>) -> Void) {
        do {
            let encoder = Firestore.Encoder()
            try db.collection(Constants.Database.users).document(user.uid).setData(from: user, encoder: encoder, completion:
            { (error) in
                if let error = error {
                    callback(.failure(error))
                }
                callback(.success(user))
            })
        } catch let error {
            callback(.failure(error))
        }
    }
    
    public static func readAll(userType: String, callback: @escaping (Result<[User], Error>) -> Void) {
        var users = [User]()
        let db = Firestore.firestore()
        db.collection(Constants.Database.users).whereField("userType", isEqualTo: userType).getDocuments()
        { (querySnapshot, error) in
            if let error = error {
                callback(.failure(error))
            } else {
                for document in querySnapshot!.documents {
                    do {
                        let user = try document.data(as: User.self)
                        users.append(user)
                    } catch let error {
                        print("Error converting data: \(error.localizedDescription)")
                    }
                }
                callback(.success(users))
            }
        }
    }
    
    public static func read(uid: String) -> User? {
        return nil
    }
    
    public static func update(user: User, callback: @escaping (Result<User, Error>) -> Void) {
        do {
            let encoder = Firestore.Encoder()
            try db.collection(Constants.Database.users).document(user.uid).setData(from: user, encoder: encoder, completion:
            { (error) in
                if let error = error {
                    callback(.failure(error))
                }
                callback(.success(user))
            })
        } catch let error {
            callback(.failure(error))
        }
    }
    
    public static func deleteShift(uid: String, callback: @escaping (Result<String, Error>) -> Void) {
        db.collection(Constants.Database.users).document(uid).delete
        { (error) in
            if let error = error {
                callback(.failure(error))
            }
            callback(.success(uid))
        }
    }
}
