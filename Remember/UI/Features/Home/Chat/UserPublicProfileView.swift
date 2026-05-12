// UI/Features/Home/Chat/UserPublicProfileView.swift
//
// Kullanıcı bir sohbette "Profili gör"e dokunduğunda veya başka bir
// katılımcıyı incelemesi gerektiğinde gösterilen salt okunur profil.
// Diğer kişilerin şifreleri asla gösterilmez — burada yalnızca genel
// bilgiler (ad, telefon, departmanlar, avatar, temel etkinlik istatistikleri) görünür.
import SwiftUI

struct UserPublicProfileView: View {
    let user: User
    let departments: [Department]
    let stats: UserTaskStats?
    @Environment(\.dismiss) private var dismiss

    private var resolvedDepartmentNames: [String] {
        user.departmentIds.compactMap { id in
            departments.first(where: { $0.id == id })?.name
        }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    appBar
                    headerCard
                    if !resolvedDepartmentNames.isEmpty {
                        departmentsCard
                    }
                    if let stats = stats {
                        statsCard(stats: stats)
                    }
                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .navigationBarHidden(true)
    }

    private var appBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.divider, lineWidth: 1)
                    )
            }
            Spacer()
            Text("Profil")
                .font(AppFonts.aestetico(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            // Başlığın optik olarak ortalı kalması için simetrik yer tutucu.
            Color.clear.frame(width: 36, height: 36)
        }
    }

    private var headerCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.primary.opacity(0.25),
                                AppColors.primary.opacity(0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)
                if let urlString = user.avatarURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            initialsBadge
                        }
                    }
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
                } else {
                    initialsBadge
                }
            }
            .overlay(
                Circle().stroke(AppColors.surface, lineWidth: 4)
            )
            .shadow(color: AppColors.shadowColor(opacity: 0.1), radius: 14, y: 6)

            Text(user.name)
                .font(AppFonts.title2)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            Text(user.phone)
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(AppColors.surface)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(AppColors.divider, lineWidth: 1)
        )
    }

    private var initialsBadge: some View {
        Text(user.name.prefix(2).uppercased())
            .font(AppFonts.aestetico(size: 36, weight: .bold))
            .foregroundColor(AppColors.primary)
    }

    private var departmentsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bölümler")
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)

            FlowLayout(spacing: 6) {
                ForEach(resolvedDepartmentNames, id: \.self) { name in
                    HStack(spacing: 6) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text(name)
                            .font(AppFonts.caption1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.primaryLight)
                    .foregroundColor(AppColors.primary)
                    .cornerRadius(10)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.divider, lineWidth: 1)
        )
    }

    private func statsCard(stats: UserTaskStats) -> some View {
        HStack(spacing: 12) {
            statTile(value: stats.assignedTaskCount, label: "Tabşyrylan", color: AppColors.primary)
            statTile(value: stats.completedTaskCount, label: "Tamamlandy", color: AppColors.success)
            statTile(value: stats.pendingTaskCount, label: "Garaşylýar", color: AppColors.warning)
        }
    }

    private func statTile(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(AppFonts.aestetico(size: 22, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(AppFonts.caption2)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.divider, lineWidth: 1)
        )
    }
}

// MARK: - FlowLayout yardımcısı
//
// Alt öğeler kapsayıcıyı taştığında birden fazla satıra sarar.
// Departman rozeti kümesi için kullanılır ancak herhangi bir çip benzeri
// liste için yeniden kullanılabilir. Yerel `Layout` API'si (iOS 16+) ölçüm işini hafif tutar.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        return arrange(subviews: subviews, in: width).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(subviews: subviews, in: bounds.width)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX,
                                              y: bounds.minY + frame.minY),
                                  proposal: ProposedViewSize(frame.size))
        }
    }

    private func arrange(subviews: Subviews, in maxWidth: CGFloat) -> (size: CGSize, frames: [CGRect]) {
        var frames: [CGRect] = []
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0, width: CGFloat = 0
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            x += size.width + spacing
            width = max(width, x)
            lineHeight = max(lineHeight, size.height)
        }
        return (CGSize(width: width, height: y + lineHeight), frames)
    }
}
