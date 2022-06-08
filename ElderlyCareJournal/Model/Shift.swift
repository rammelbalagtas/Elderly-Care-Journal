//
//  Shift.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-25.
//

import Foundation

class Shift: Codable {
    
    var id: String
    var memberId: String
    var description: String
    var fromDateTime: String
    var toDateTime: String
    var tasks: [Task]
    var careProviderId: String
    var careProviderName: String
    var status: String
    var uid: String
    var createdOn: String
    var startedOn: String?
    var completedOn: String?
    
    init(id: String, memberId: String, description: String, fromDateTime: String, toDateTime: String, tasks: [Task], careProviderId: String, careProviderName: String, status: String, uid: String, createdOn: String, startedOn: String? = nil, completedOn: String? = nil) {
        self.id = id
        self.memberId = memberId
        self.description = description
        self.fromDateTime = fromDateTime
        self.toDateTime = toDateTime
        self.tasks = tasks
        self.careProviderId = careProviderId
        self.careProviderName = careProviderName
        self.status = status
        self.uid = uid
        self.createdOn = createdOn
        self.startedOn = startedOn
        self.completedOn = completedOn
    }
}
