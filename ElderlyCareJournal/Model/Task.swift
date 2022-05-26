//
//  Task.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-25.
//

import Foundation

class Task: Codable {
    init(description: String, status: String) {
        self.description = description
        self.status = status
    }
    
    var description: String
    var status: String
}
