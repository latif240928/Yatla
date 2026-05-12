// Sohbet DTO'ları zengin `Chat` / `GroupChat` için ek bağlam (katılımcı `User`, üye listesi, departman) ister;
// bu tamamlama bugün depolarda yapılır. Dosya bilinçli olarak ince tutuldu — çağıranlar doğrudan `ChatDTO` /
// `GroupChatDTO` üzerindeki `.toDomain(...)` giriş noktalarını kullanmalıdır.
import Foundation

enum ChatMapper {}
