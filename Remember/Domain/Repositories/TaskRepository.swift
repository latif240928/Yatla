//  TaskRepository.swift
import Foundation

protocol TaskRepository {
    func getTasks() async throws -> [TaskItem]
    
    func createTask(_ task: CreateTask) async throws -> TaskItem
    
    func updateStatus(id: String, status: TaskStatus) async throws -> TaskItem
    
    func deleteTask(id: String) async throws
    
    func addAssignee(taskID: String, userID: String) async throws -> TaskItem
    
    func removeAssignee(taskID: String, assigneeID: String) async throws -> TaskItem
    
    func addComment(taskID: String, text: String) async throws -> TaskComment
    
    func uploadFile(taskId: String, fileURL: URL) async throws -> TaskFile
}
