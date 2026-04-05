//  TaskOfferUseCase.swift
import Foundation

final class FetchTaskOffersUseCase {
    private let repo: TaskOfferRepository
    init(repo: TaskOfferRepository) { self.repo = repo }

    func execute(for userId: String) async -> [TaskOffer] {
        await repo.fetchIncomingOffers(for: userId)
    }
}

final class RespondToOfferUseCase {
    private let repo: TaskOfferRepository
    init(repo: TaskOfferRepository) { self.repo = repo }

    func accept(offerId: String) async { await repo.acceptOffer(id: offerId) }
    func reject(offerId: String) async { await repo.rejectOffer(id: offerId) }
}

final class SendTaskOfferUseCase {
    private let repo: TaskOfferRepository
    init(repo: TaskOfferRepository) { self.repo = repo }

    func execute(from sender: User, to userId: String, title: String, description: String) async {
        let offer = TaskOffer(
            id: UUID().uuidString,
            fromUser: sender,
            title: title,
            description: description,
            sentAt: Date(),
            status: .pending
        )
        await repo.sendOffer(offer, to: userId)
    }
}
