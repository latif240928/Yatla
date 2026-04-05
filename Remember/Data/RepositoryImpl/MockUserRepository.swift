// Data/RepositoryImpl/MockUserRepository.swift
import Foundation

final class MockUserRepository: UserRepository {

    private var users: [User] = [
        User(id: "u1", name: "Abdullatif Durdybayew",
             phone: "+993 62445524", departmentIds: ["dept-1"]),
        User(id: "u2", name: "Haknazar Haljanow",
             phone: "+993 61000002", departmentIds: ["dept-1"]),
        User(id: "u3", name: "Durdyyewa Çynar",
             phone: "+993 61000003", departmentIds: ["dept-2"]),
        User(id: "u4", name: "Myrat Oraz",
             phone: "+993 61000004", departmentIds: ["dept-2", "dept-3"]),
        User(id: "u5", name: "Haknazar Haljanow",
             phone: "+993 61000005", departmentIds: ["dept-3"]),
    ]

    func getUsers() async -> [User] { users }

    func fetchUsers(for departmentId: String?) async -> [User] {
        guard let departmentId else { return users }
        return users.filter { $0.departmentIds.contains(departmentId) }
    }

    func searchUsers(query: String) async -> [User] {
        guard !query.isEmpty else { return users }
        let q = query.lowercased()
        return users.filter {
            $0.name.lowercased().contains(q) ||
            $0.phone.contains(q)
        }
    }

    func addUser(_ user: User) async throws {      // ✅ async throws eklendi
        guard !users.contains(where: { $0.id == user.id }) else { return }
        users.append(user)
    }

    func deleteUser(id: String) async throws {     // ✅ async throws eklendi
        users.removeAll { $0.id == id }
    }

    func taskStats(for userId: String) -> UserTaskStats? {
        UserTaskStats(
            userId: userId,
            assignedTaskCount:  7,
            completedTaskCount: 3,
            pendingTaskCount:   2
        )
    }
}
