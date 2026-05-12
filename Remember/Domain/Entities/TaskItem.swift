//
//  TaskItem.swift
import Foundation



struct TaskItem: Identifiable, Equatable, Codable{
    let id: String
    var title: String
    var description: String      // Mazmuny
    var status: TaskStatus
    var department: String
    let departmentId: String
    var assignees: [TaskAssignee]
    var assigneeIds: [String]    // Gosulan ulanyjylaryn id'leri
    let creatorId: String
    let createdAt: Date
    var startDate: Date
    let dueDate: Date
    var files: [TaskFile]
    var comments: [TaskComment]
    let number: Int
}
