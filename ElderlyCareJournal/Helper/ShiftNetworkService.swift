//
//  ShiftDBService.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ShiftNetworkService {
    
    private static let db = Firestore.firestore()
    
    public static func createShift(shift: Shift, callback: @escaping (Result<Shift, Error>) -> Void) {
        do {
            let encoder = Firestore.Encoder()
            try db.collection(Constants.Database.shifts).document(shift.id).setData(from: shift.id, encoder: encoder, completion:
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
    
    public static func readShift() {
        
    }
    
    public static func updateShift(shift: Shift, callback: @escaping (Result<Shift, Error>) -> Void) {
        do {
            let encoder = Firestore.Encoder()
            try db.collection(Constants.Database.shifts).document(shift.id).setData(from: shift.id, encoder: encoder, completion:
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
    
    public static func deleteShift(shiftId: String, callback: @escaping (Result<String, Error>) -> Void) {
        db.collection(Constants.Database.shifts).document(shiftId).delete
        { (error) in
            if let error = error {
                callback(.failure(error))
            }
            callback(.success(shiftId))
        }
    }
}


