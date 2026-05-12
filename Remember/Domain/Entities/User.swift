//
//  User.swift
import Foundation

struct User: Identifiable, Equatable, Hashable, Codable, Sendable {
    let id: String
    var name: String
    var phone: String
    var departmentIds: [String] = []
    var avatarURL: String?
    var isAdmin: Bool = false
    var createdAt: Date?

    static let mockUser1 = User(id: "mock-user-1", name: "Latif Mock", phone: "+993-62445524")

    static let empty = User(
        id: "",
        name: "",
        phone: "",
        departmentIds: []
    )
}

struct UserTaskStats: Sendable {
    let userId: String
    var assignedTaskCount: Int
    var completedTaskCount: Int
    var pendingTaskCount: Int
}
