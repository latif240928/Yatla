//
//  Invitation.swift

import Foundation

struct Invitation: Identifiable {
    let id: String
    let senderName: String
    let senderNumber: String
    let senderDepartment: String
    let date: Date
    let time: Date
}
