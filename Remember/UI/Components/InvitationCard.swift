// UI/Components/InvitationCard.swift
//
// Kullanıcılar → "Meni çagyranlar" sekmesinde görüntülenen kart.
// Solda davet edenin avatarı/adı/telefonu, sağda departman rozeti +
// saat/tarih içeren temiz iki satırlık bir yığın gösterilir.
// Butonlar kartın alt kısmında yer alır.
import SwiftUI

struct InvitationCard: View {
    let offer: TaskOffer
    var departments: [Department] = []
    var onAccept: (() -> Void)?
    var onReject: (() -> Void)?
    @EnvironmentObject private var container: DIContainer

    private var lang: Language { container.appSettings.selectedLanguage }

    /// "iOS Team" veya "Backend, UI" — eşleşme yoksa "—" döner.
    private var departmentName: String {
        let names = offer.fromUser.departmentIds.compactMap { id in
            departments.first(where: { $0.id == id })?.name
        }
        return names.isEmpty ? "—" : names.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // MARK: – Başlık (avatar + kimlik + meta)
            HStack(alignment: .top, spacing: 12) {
                avatar

                VStack(alignment: .leading, spacing: 3) {
                    Text(offer.fromUser.name)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    Text(offer.fromUser.phone)
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                metaColumn
            }

            // MARK: – Başlık / açıklama
            if !offer.title.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.title)
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)
                    if !offer.description.isEmpty {
                        Text(offer.description)
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                }
            }

            Divider().background(AppColors.divider)

            // MARK: – Eylemler
            HStack(spacing: 12) {
                Button(action: { onReject?() }) {
                    Text(L10n.string(.invitationReject, language: lang))
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.textInverse)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(AppColors.error)
                        )
                }
                Button(action: { onAccept?() }) {
                    Text(L10n.string(.invitationAccept, language: lang))
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.textInverse)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(AppColors.success)
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.divider, lineWidth: 1)
        )
        .shadow(color: AppColors.shadowColor(opacity: 0.04), radius: 8, y: 4)
    }

    // MARK: - Alt görünümler

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(AppColors.primaryLight)
                .frame(width: 48, height: 48)
            Text(offer.fromUser.name.prefix(2).uppercased())
                .font(AppFonts.aestetico(size: 16, weight: .bold))
                .foregroundColor(AppColors.primary)
        }
    }

    /// Sağ taraftaki meta sütunu. Üstte departman rozeti, altta saat +
    /// tarih — çok satırlı meta verilerin düzgün okunması için sağa hizalı.
    private var metaColumn: some View {
        VStack(alignment: .trailing, spacing: 6) {
            // Departman rozeti
            HStack(spacing: 4) {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 9, weight: .semibold))
                Text(departmentName)
                    .font(AppFonts.caption2)
                    .lineLimit(1)
            }
            .foregroundColor(AppColors.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppColors.primaryLight)
            .cornerRadius(8)

            // Saat + tarih üst üste, sağa hizalı
            VStack(alignment: .trailing, spacing: 2) {
                Text(AppDateFormatters.hourMinute.string(from: offer.sentAt))
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
                Text(AppDateFormatters.dayMonthYearDot.string(from: offer.sentAt))
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.textHint)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview("Invitation") {
    ScrollView {
        VStack(spacing: 16) {
            InvitationCard(
                offer: TaskOffer(
                    id: "1",
                    fromUser: User(
                        id: "u1",
                        name: "Abdullatif Durdybayew",
                        phone: "+993 62445524",
                        departmentIds: ["dept-1"]
                    ),
                    title: "UI bölümüni dizaýn etmeli",
                    description: "Baş sahypanyň dizaýnyny täzelemeli.",
                    sentAt: Date(),
                    status: .pending
                ),
                departments: [Department(id: "dept-1", name: "iOS Team")],
                onAccept: {}, onReject: {}
            )
            InvitationCard(
                offer: TaskOffer(
                    id: "2",
                    fromUser: User(
                        id: "u2",
                        name: "Haknazar Haljanow",
                        phone: "+993 61000002",
                        departmentIds: ["dept-2", "dept-3"]
                    ),
                    title: "API integration",
                    description: "Hemme endpoint-leri synap göreliň",
                    sentAt: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
                    status: .pending
                ),
                departments: [
                    Department(id: "dept-2", name: "Backend"),
                    Department(id: "dept-3", name: "Frontend")
                ],
                onAccept: {}, onReject: {}
            )
        }
        .padding()
    }
    .background(AppColors.background)
}
