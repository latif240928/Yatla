//  UserRepository.swift
import Foundation

protocol UserRepository {
    func getUsers() async -> [User]
    func fetchUsers(for departmentId: String?) async -> [User]
    func searchUsers(query: String) async -> [User]
    func addUser(_ user: User) async throws
    func deleteUser(id: String) async throws
    func taskStats(for userId: String) -> UserTaskStats?
}
