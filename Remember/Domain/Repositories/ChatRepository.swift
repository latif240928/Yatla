// Sohbet veri kaynağı: birebir ve grup listesi, mesaj geçmişi ve yazma işlemleri.
//
// Liste uç noktaları kasıtlı olarak özettir (son mesaj + okunmamış sayısı); detay açılınca
// tam geçmiş için `messages(forChatId:)` / `messages(forGroupChatId:)` çağrılmalıdır.
import Foundation

protocol ChatRepository {

    // MARK: - Listeler

    func getChats(for userId: String) async -> [Chat]
    func getGroupChats(for userId: String) async -> [GroupChat]

    // MARK: - Geçmiş

    /// Birebir sohbetin tam mesaj geçmişi. Hata durumunda boş dizi.
    func messages(forChatId chatId: String) async -> [ChatMessage]

    /// Grup sohbetinin tam mesaj geçmişi. Hata durumunda boş dizi.
    func messages(forGroupChatId groupChatId: String) async -> [ChatMessage]

    // MARK: - Değişiklikler

    func sendMessage(chatId: String, message: ChatMessage) async

    /// Sunucuda kalıcı mesajı döner (kimlik/zaman damgası ile) veya API desteklemiyorsa yerel oluşturulan gövdeyi.
    func sendGroupMessage(groupChatId: String, text: String, sender: User) async -> ChatMessage?

    /// Sohbetteki tüm okunmamış mesajları sunucuda okundu olarak işaretler.
    func markAsRead(chatId: String) async

    /// Verilen katılımcı ile birebir sohbeti getirir veya oluşturur. İstek reddedilirse (ör. yetkisiz) `nil`.
    func openChat(withParticipantId participantId: String) async -> Chat?

    func deleteChat(id: String) async
    func muteChat(id: String) async
    func unmuteChat(id: String) async
}
