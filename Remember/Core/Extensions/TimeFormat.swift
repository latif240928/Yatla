// Tarih/saat biçimlendirme: paylaşılan `DateFormatter` önbelleği (oluşturması maliyetlidir).
import Foundation

/// Merkezi, tembel başlatılmış `DateFormatter` önbelleği.
///
/// `DateFormatter` oluşturmak yerel ayar / takvim / saat dilimi bağladığı için pahalıdır.
/// Küçük ve sabit bir küme paylaşılır; her çizimde yeniden tahsis edilmez.
enum AppDateFormatters {

    /// "12.04.2026"
    static let dayMonthYearDot: DateFormatter = make("dd.MM.yyyy")

    /// "12.04.26"
    static let dayMonthYearShort: DateFormatter = make("dd.MM.yy")

    /// "12 / 04 / 2026"
    static let dayMonthYearSpaced: DateFormatter = make("dd / MM / yyyy")

    /// "April 12"
    static let monthDay: DateFormatter = make("MMMM d")

    /// "14:35"
    static let hourMinute: DateFormatter = make("HH:mm")

    private static func make(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = format
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }
}
