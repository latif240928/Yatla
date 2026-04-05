//  TaskOfferRepository.swift
import Foundation

protocol TaskOfferRepository {
    func fetchIncomingOffers(for userId: String) async -> [TaskOffer]
    func sendOffer(_ offer: TaskOffer, to userId: String) async
    func acceptOffer(id: String) async
    func rejectOffer(id: String) async
}
