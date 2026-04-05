// Data/RepositoryImpl/MockTaskOfferRepository.swift
import Foundation

final class MockTaskOfferRepository: TaskOfferRepository {
    static let shared = MockTaskOfferRepository()  // ✅ geri eklendi
        
        private init() {}

    private var offers: [TaskOffer] = [
        TaskOffer(
            id: "offer-1",
            fromUser: User(
                id: "user-2",
                name: "AtaMekan",
                phone: "+993 61517100",
                departmentIds: ["dept-2"]
            ),
            title: "UI bölümüni dizaýn etmeli",
            description: "Baş sahypanyň dizaýnyny täzelemeli.",
            sentAt: Date(),
            status: .pending
        ),
        TaskOffer(
            id: "offer-2",
            fromUser: User(
                id: "user-3",
                name: "Rahym",
                phone: "+993 61000099",
                departmentIds: ["dept-1"]
            ),
            title: "Chess oynamany owret",
            description: "Do you have a free time to play chess with me?",
            sentAt: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
            status: .pending
        ),
    ]

    // ✅ Protocol metodları — async ve doğru isimler
    func fetchIncomingOffers(for userId: String) async -> [TaskOffer] {
        offers.filter { $0.status == .pending }
    }

    func sendOffer(_ offer: TaskOffer, to userId: String) async {
        offers.append(offer)
    }

    func acceptOffer(id: String) async {
        guard let i = offers.firstIndex(where: { $0.id == id }) else { return }
        offers[i].status = .accepted
    }

    func rejectOffer(id: String) async {
        guard let i = offers.firstIndex(where: { $0.id == id }) else { return }
        offers[i].status = .rejected
    }
}
