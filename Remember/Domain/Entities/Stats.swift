// Domain/Entities/Stats.swift — İstatistik panosu için özet sayılar ve grafik kaynakları.
import Foundation

/// İstatistik panosunda gösterilen ana özet metrikler.
///
/// Ham tam sayıları burada tutup yüzdeleri ve histogramları görünüm türetir; böylece tek `Stats` örneği
/// yüzde halkası, haftanın günleri grafiği, yoğun saat bandı ve haftalık karşılaştırmayı birlikte besler.
struct Stats {
    let totalTasks:      Int
    let completedTasks:  Int
    let failedTasks:     Int
    let inProgressTasks: Int
    let returnedTasks:   Int
    let totalUsers:      Int

    /// Gün → o gün tamamlanan görev sayısı (`startOfDay(...)` ile anahtarlanır).
    let dailyTasks:      [Date: Int]

    /// Günün saati (0–23) → o saat diliminde tamamlanan görev sayısı ("en verimli saatler" kartı).
    let hourlyCompletions: [Int: Int]

    /// Haftanın günü (1 = Pazar … 7 = Cumartesi, Calendar ile uyumlu) → o gün tamamlanan görev sayısı (yedi daire satırı).
    let weekdayCompletions: [Int: Int]

    /// Geçerli ISO haftasında tamamlanan görev sayısı.
    let thisWeekCompleted: Int

    /// Önceki ISO haftasında tamamlanan görev sayısı — `thisWeekCompleted` ile haftalık fark için kullanılır.
    let lastWeekCompleted: Int

    /// Yaklaşık 7 günden uzun bekleyen veya devam eden görevler; birikim için ayrı gösterilir.
    let longPendingTasks: [TaskItem]

    var successRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks) * 100
    }

    /// Bugün için tamamlanma oranı (günlük halka grafiği). Aralık 0…1.
    var todayCompletionRatio: Double {
        let today = Calendar.current.startOfDay(for: Date())
        let total = dailyTasks[today] ?? 0
        guard total > 0 else { return 0 }
        return min(1, Double(total) / Double(max(total, 1)))
    }

    /// Bu hafta ile geçen hafta arasındaki fark, yüzde olarak +/- . İki hafta da boşsa 0.
    var weeklyDelta: Double {
        guard lastWeekCompleted > 0 else {
            return thisWeekCompleted > 0 ? 100 : 0
        }
        return (Double(thisWeekCompleted) - Double(lastWeekCompleted))
            / Double(lastWeekCompleted) * 100
    }
}
