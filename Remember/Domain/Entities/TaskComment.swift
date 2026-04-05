//
//  TaskComment.swift
import Foundation

struct TaskComment: Identifiable, Hashable, Codable {
    let id: String
    let user: User
    let text: String
    let date: Date
}
