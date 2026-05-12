// UI/Features/Settings/StatsView.swift
//
// Kart tabanlı istatistik panosu. Her metrik kendi yuvarlatılmış
// kapsayıcısında bulunur; böylece düzen her cihazda okunabilir kalır.
//
//  Sırasıyla kartlar:
//   1. Günlük tamamlama halkası (bugün, %)
//   2. Ana sayılar (toplam / tamamlanan / bekleyen) — renkli çipler
//   3. En verimli saatler bandı (24 segmentli ölçer)
//   4. En yoğun hafta günleri — 7 küçük daire, tamamlama hacmine göre ölçekli
//   5. Haftalık karşılaştırma (bu hafta ile geçen hafta)
//   6. Uzun süredir bekleyen görevler listesi (7 günden eski görevler)
//
import SwiftUI

struct StatsView: View {
    @ObservedObject var vm: SettingsViewModel

    private var lang: Language { vm.settings.selectedLanguage }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 16) {
                    todayRingCard
                    headlineCountsCard
                    productiveHoursCard
                    weekdayCirclesCard
                    weeklyCompareCard
                    longPendingCard
                    Spacer().frame(height: 60)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
            }
        }
        .navigationTitle(L10n.string(.statsTitle, language: lang))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.refreshStats() }
    }

    // MARK: 1. Günlük tamamlama halkası
    //
    // Bugünün tamamlama oranı, merkezde % etiketi olan dairesel ilerleme
    // halkası olarak gösterilir. Uygulamanın diğer yerlerinde kullanılan
    // "Tamamlandy" durum rengiyle eşleşmek için yeşil paleti kullanır.
    private var todayRingCard: some View {
        let stats = vm.stats
        let total = stats.dailyTasks[Calendar.current.startOfDay(for: Date())] ?? 0
        // Mock tahmini: bugünkü tamamlamaların 8 görevlik hedefe oranı.
        let ratio = min(1.0, Double(total) / 8.0)

        return HStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(AppColors.surfaceLight, lineWidth: 12)
                    .frame(width: 96, height: 96)
                Circle()
                    .trim(from: 0, to: ratio)
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.success, AppColors.statusInProgress],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 96, height: 96)
                    .animation(.spring(response: 0.6, dampingFraction: 0.85), value: ratio)
                Text("\(Int(ratio * 100))%")
                    .font(AppFonts.aestetico(size: 22, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.string(.statsDailyTasks, language: lang))
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text("\(L10n.string(.statsTodayCompleted, language: lang)): \(total)")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card())
    }

    // MARK: 2. Ana sayılar
    private var headlineCountsCard: some View {
        let s = vm.stats
        return VStack(spacing: 10) {
            HStack(spacing: 10) {
                miniStat(
                    title: L10n.string(.statsTotal, language: lang),
                    value: s.totalTasks,
                    color: AppColors.primary,
                    icon: "tray.full.fill"
                )
                miniStat(
                    title: L10n.string(.statsCompleted, language: lang),
                    value: s.completedTasks,
                    color: AppColors.success,
                    icon: "checkmark.seal.fill"
                )
            }
            HStack(spacing: 10) {
                miniStat(
                    title: L10n.string(.statsInProgress, language: lang),
                    value: s.inProgressTasks,
                    color: AppColors.statusInProgress,
                    icon: "hourglass"
                )
                miniStat(
                    title: L10n.string(.statsReturned, language: lang),
                    value: s.returnedTasks,
                    color: AppColors.warning,
                    icon: "arrow.uturn.backward.circle.fill"
                )
            }
        }
    }

    private func miniStat(title: String, value: Int, color: Color, icon: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(AppFonts.aestetico(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("\(value)")
                    .font(AppFonts.aestetico(size: 22, weight: .bold))
                    .foregroundColor(color)
                Text(title)
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card(cornerRadius: 18))
    }

    // MARK: 3. Verimli saatler
    //
    // 24 hücreli ölçer — en uzun çubuklar kullanıcının en yoğun saatleridir.
    // Küçük telefonlara düzgün oturması için yaklaşık 80px yüksekliğindedir.
    private var productiveHoursCard: some View {
        let buckets = vm.stats.hourlyCompletions
        let maxCount = max(1, buckets.values.max() ?? 1)
        let topHour = buckets.max(by: { $0.value < $1.value })?.key

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.string(.statsMostProductiveHours, language: lang))
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                    if let topHour {
                        Text("\(L10n.string(.statsMostActiveRange, language: lang)): \(topHour):00 – \(topHour + 1):00")
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                Spacer()
            }

            HStack(alignment: .bottom, spacing: 3) {
                ForEach(0..<24, id: \.self) { hour in
                    let count = buckets[hour] ?? 0
                    let pct = CGFloat(count) / CGFloat(maxCount)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: hour == topHour
                                    ? [AppColors.success, AppColors.statusInProgress]
                                    : [AppColors.surfaceLight, AppColors.divider],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: max(6, pct * 80))
                }
            }
            .frame(height: 80)

            HStack {
                Text("00")
                Spacer()
                Text("06")
                Spacer()
                Text("12")
                Spacer()
                Text("18")
                Spacer()
                Text("23")
            }
            .font(AppFonts.caption2)
            .foregroundColor(AppColors.textHint)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card())
    }

    // MARK: 4. En yoğun hafta günleri — 7 daire
    private var weekdayCirclesCard: some View {
        let counts = vm.stats.weekdayCompletions
        let maxCount = max(1, counts.values.max() ?? 1)
        let labels = [
            L10n.string(.weekdaySun, language: lang),
            L10n.string(.weekdayMon, language: lang),
            L10n.string(.weekdayTue, language: lang),
            L10n.string(.weekdayWed, language: lang),
            L10n.string(.weekdayThu, language: lang),
            L10n.string(.weekdayFri, language: lang),
            L10n.string(.weekdaySat, language: lang)
        ]

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(L10n.string(.statsBusiestDays, language: lang))
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }

            HStack(spacing: 10) {
                ForEach(1...7, id: \.self) { weekday in
                    let count = counts[weekday] ?? 0
                    let intensity = Double(count) / Double(maxCount)
                    VStack(spacing: 8) {
                        Circle()
                            .fill(
                                AppColors.success.opacity(0.25 + (intensity * 0.7))
                            )
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("\(count)")
                                    .font(AppFonts.aestetico(size: 11, weight: .bold))
                                    .foregroundColor(AppColors.success)
                            )
                        Text(labels[weekday - 1])
                            .font(AppFonts.caption2)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card())
    }

    // MARK: 5. Haftalık karşılaştırma
    private var weeklyCompareCard: some View {
        let s = vm.stats
        let delta = s.weeklyDelta
        let deltaColor: Color = delta >= 0 ? AppColors.success : AppColors.error

        return HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.string(.statsWeeklyCompare, language: lang))
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text("\(L10n.string(.statsThisWeek, language: lang)): \(s.thisWeekCompleted) · \(L10n.string(.statsLastWeek, language: lang)): \(s.lastWeekCompleted)")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text("\(String(format: "%.0f", abs(delta)))%")
            }
            .font(AppFonts.aestetico(size: 16, weight: .bold))
            .foregroundColor(deltaColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(deltaColor.opacity(0.18))
            .cornerRadius(12)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card())
    }

    // MARK: 6. Uzun süredir bekleyen görevler
    private var longPendingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.string(.statsOldUnfinished, language: lang))
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("\(vm.stats.longPendingTasks.count)")
                    .font(AppFonts.aestetico(size: 14, weight: .bold))
                    .foregroundColor(AppColors.warning)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.warning.opacity(0.18))
                    .cornerRadius(10)
            }

            if vm.stats.longPendingTasks.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(AppColors.success)
                    Text(L10n.string(.statsNoData, language: lang))
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                }
            } else {
                ForEach(vm.stats.longPendingTasks.prefix(4)) { task in
                    HStack(spacing: 10) {
                        Circle().fill(AppColors.warning).frame(width: 8, height: 8)
                        Text(task.title)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text(AppDateFormatters.dayMonthYearDot.string(from: task.startDate))
                            .font(AppFonts.caption2)
                            .foregroundColor(AppColors.textHint)
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card())
    }

    // MARK: - Yardımcılar
    private func card(cornerRadius: CGFloat = 22) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(AppColors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppColors.divider, lineWidth: 1)
            )
            .shadow(color: AppColors.shadowColor(opacity: 0.04), radius: 6, y: 3)
    }
}
