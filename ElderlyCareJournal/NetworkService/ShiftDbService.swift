//
//  ShiftDBService.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ShiftDbService {
    
    private static let db = Firestore.firestore()
    
    public static func create(shift: Shift, callback: @escaping (Result<Shift, Error>) -> Void) {
        do {
            let encoder = Firestore.Encoder()
            try db.collection(Constants.Database.shifts).document(shift.id).setData(from: shift, encoder: encoder, completion:
            { (error) in
                if let error = error {
                    callback(.failure(error))
                }
                callback(.success(shift))
            })
        } catch let error {
            callback(.failure(error))
        }
    }
    
    public static func readWithFilter(memberId: String, careProviderId: String?, status: String, callback: @escaping (Result<[Shift], Error>) -> Void) {
        
        var shifts = [Shift]()
        let db = Firestore.firestore()
        
        if let careProviderId = careProviderId {
            db.collection(Constants.Database.shifts)
                .whereField("memberId", isEqualTo: memberId)
                .whereField("careProviderId", isEqualTo: careProviderId)
                .whereField("status", isEqualTo: status)
                .getDocuments()
            { (querySnapshot, error) in
                if let error = error {
                    callback(.failure(error))
                } else {
                    for document in querySnapshot!.documents {
                        do {
                            let shift = try document.data(as: Shift.self)
                            shifts.append(shift)
                        } catch let error {
                            print("Error converting data: \(error.localizedDescription)")
                        }
                    }
                    callback(.success(shifts))
                }
            }
        } else {
            db.collection(Constants.Database.shifts)
                .whereField("memberId", isEqualTo: memberId)
                .whereField("status", isEqualTo: status)
                .getDocuments()
            { (querySnapshot, error) in
                if let error = error {
                    callback(.failure(error))
                } else {
                    for document in querySnapshot!.documents {
                        do {
                            let shift = try document.data(as: Shift.self)
                            shifts.append(shift)
                        } catch let error {
                            print("Error converting data: \(error.localizedDescription)")
                        }
                    }
                    callback(.success(shifts))
                }
            }
        }
    }
    
    public static func readById(shiftId: String, callback: @escaping (Result<Shift, Error>) -> Void) {
        let docRef = db.collection(Constants.Database.shifts).document(shiftId)
        docRef.getDocument(as: Shift.self)
        { result in
            switch result {
            case .success(let shift):
                callback(.success(shift))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    public static func update(shift: Shift, callback: @escaping (Result<Shift, Error>) -> Void) {
        do {
            let encoder = Firestore.Encoder()
            try db.collection(Constants.Database.shifts).document(shift.id).setData(from: shift, encoder: encoder, completion:
            { (error) in
                if let error = error {
                    callback(.failure(error))
                }
                callback(.success(shift))
            })
        } catch let error {
            callback(.failure(error))
        }
    }
    
    public static func delete(shiftId: String, callback: @escaping (Result<String, Error>) -> Void) {
        db.collection(Constants.Database.shifts).document(shiftId).delete
        { (error) in
            if let error = error {
                callback(.failure(error))
            }
            callback(.success(shiftId))
        }
    }
}


