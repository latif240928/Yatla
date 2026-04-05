
//  UserUseCase.swift
final class GetUsersUseCase {
    private let repository: UserRepository
    init(repository: UserRepository) { self.repository = repository }

    func execute() async -> [User] {
        await repository.getUsers()
    }
}

// SearchUsersUseCase.swift
final class SearchUsersUseCase {
    private let repository: UserRepository
    init(repository: UserRepository) { self.repository = repository }

    func execute(query: String) async -> [User] {
        await repository.searchUsers(query: query)
    }
}
