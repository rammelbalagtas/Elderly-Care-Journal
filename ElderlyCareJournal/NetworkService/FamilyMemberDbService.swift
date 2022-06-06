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
    
    public static func readMembers(uid: String, callback: @escaping (Result<[FamilyMember], Error>) -> Void) {
        var familyMembers = [FamilyMember]()
        db.collection(Constants.Database.familyMembers).whereField("uid", isEqualTo: uid).getDocuments()
        { (querySnapshot, error) in
            if let error = error {
                callback(.failure(error))
            } else {
                for document in querySnapshot!.documents {
                    do {
                        let FamilyMember = try document.data(as: FamilyMember.self)
                        familyMembers.append(FamilyMember)
                    } catch let error {
                        print("Error converting data: \(error.localizedDescription)")
                    }
                }
                callback(.success(familyMembers))
            }
        }
    }
    
    public static func readClients(careProviderId: String, callback: @escaping (Result<[FamilyMember], Error>) -> Void) {
        
        var memberIds = [String]()
        
        db.collection(Constants.Database.shifts).whereField("careProviderId", isEqualTo: careProviderId).getDocuments()
        { (querySnapshot, error) in
            if let error = error {
                callback(.failure(error))
            } else {
                for document in querySnapshot!.documents {
                    do {
                        let shift = try document.data(as: Shift.self)
                        if !memberIds.contains(shift.memberId) {
                            memberIds.append(shift.memberId)
                        }
                    } catch let error {
                        print("Error converting data: \(error.localizedDescription)")
                    }
                }
                if memberIds.isEmpty {
                    callback(.success([]))
                } else {
                    readMembersRange(memberIds: memberIds)
                    { result in
                        switch result {
                        case .success(let data):
                            callback(.success(data))
                        case .failure(let error):
                            callback(.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    public static func readMembersRange(memberIds: [String], callback: @escaping (Result<[FamilyMember], Error>) -> Void) {
        
        var familyMembers = [FamilyMember]()
        
        db.collection(Constants.Database.familyMembers).whereField("memberId", in: memberIds).getDocuments()
        { (querySnapshot, error) in
            if let error = error {
                callback(.failure(error))
            } else {
                for document in querySnapshot!.documents {
                    do {
                        let FamilyMember = try document.data(as: FamilyMember.self)
                        familyMembers.append(FamilyMember)
                    } catch let error {
                        print("Error converting data: \(error.localizedDescription)")
                    }
                }
                callback(.success(familyMembers))
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
