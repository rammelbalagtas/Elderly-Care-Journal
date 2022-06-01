//
//  FamilyMemberDbService.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-26.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FamilyMemberDbService {
    
    private static let db = Firestore.firestore()
    
    public static func create(familyMember: FamilyMember, callback: @escaping (Result<FamilyMember, Error>) -> Void) {
        do {
            let encoder = Firestore.Encoder()
            try db.collection(Constants.Database.familyMembers).document(familyMember.memberId).setData(from: familyMember, encoder: encoder, completion:
            { (error) in
                if let error = error {
                    callback(.failure(error))
                }
                callback(.success(familyMember))
            })
        } catch let error {
            callback(.failure(error))
        }
    }
    
    public static func readAll(uid: String, callback: @escaping (Result<[FamilyMember], Error>) -> Void) {
        var FamilyMembers = [FamilyMember]()
        let db = Firestore.firestore()
        db.collection(Constants.Database.familyMembers).whereField("uid", isEqualTo: uid).getDocuments()
        { (querySnapshot, error) in
            if let error = error {
                callback(.failure(error))
            } else {
                for document in querySnapshot!.documents {
                    do {
                        let FamilyMember = try document.data(as: FamilyMember.self)
                        FamilyMembers.append(FamilyMember)
                    } catch let error {
                        print("Error converting data: \(error.localizedDescription)")
                    }
                }
                callback(.success(FamilyMembers))
            }
        }
    }
    
    public static func read() {
        
    }
    
    public static func update(familyMember: FamilyMember, callback: @escaping (Result<FamilyMember, Error>) -> Void) {
        do {
            let encoder = Firestore.Encoder()
            try db.collection(Constants.Database.familyMembers).document(familyMember.memberId).setData(from: familyMember, encoder: encoder, completion:
            { (error) in
                if let error = error {
                    callback(.failure(error))
                }
                callback(.success(familyMember))
            })
        } catch let error {
            callback(.failure(error))
        }
    }
    
    public static func delete(id: String, callback: @escaping (Result<String, Error>) -> Void) {
        db.collection(Constants.Database.familyMembers).document(id).delete
        { (error) in
            if let error = error {
                callback(.failure(error))
            }
            callback(.success(id))
        }
    }
}
