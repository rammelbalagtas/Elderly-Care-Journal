//
//  Shift.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-25.
//

import Foundation

struct Shift: Codable {
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
}
