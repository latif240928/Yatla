// Görev teklifi API deposu.
// Backend endpoint'leri hazır olduğunda gerçek ağ çağrıları ile doldurulacak.
import Foundation

final class TaskOfferRepositoryAPI: TaskOfferRepository {

    private let network = NetworkService.shared

    func fetchIncomingOffers(for userId: String) async -> [TaskOffer] {
        // TODO: GET /api/v1/task-offers?user_id=...
        return []
    }

    func sendOffer(_ offer: TaskOffer, to userId: String) async {
        // TODO: POST /api/v1/task-offers
    }

    func acceptOffer(id: String) async {
        // TODO: PATCH /api/v1/task-offers/{id}/accept
    }

    func rejectOffer(id: String) async {
        // TODO: PATCH /api/v1/task-offers/{id}/reject
    }
}
