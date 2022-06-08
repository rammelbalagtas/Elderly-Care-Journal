//
//  Task.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-25.
//

import Foundation

class Task: Codable {
    var description: String
    var status: String
    var completedOn: Date?
    
    init(description: String, status: String) {
        self.description = description
        self.status = status
        self.completedOn = nil
    }
}
