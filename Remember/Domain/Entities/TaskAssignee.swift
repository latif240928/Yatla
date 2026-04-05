// Domain/Entities/TaskAssignee.swift
import Foundation

struct TaskAssignee: Identifiable, Hashable, Codable {
    let id: String
    let user: User
    var status: TaskStatus
}
