
// UI/Features/Users/Components/InvitationCard.swift
import SwiftUI

struct InvitationCard: View {
    let offer: TaskOffer
    var onAccept: (() -> Void)?
    var onReject: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Üst: Avatar + İsim + Department + Tarih
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Text(offer.fromUser.name.prefix(2).uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(offer.fromUser.name)
                        .font(AppFonts.headline)
                        .foregroundColor(.white)
                    Text(offer.fromUser.phone)
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(offer.fromUser.departmentIds.first ?? "—")
                        .font(AppFonts.caption2)
                        .foregroundColor(AppColors.textHint)
                    Text(formatDateTime(offer.sentAt))
                        .font(AppFonts.caption2)
                        .foregroundColor(AppColors.textHint)
                }
            }

            Divider().background(AppColors.divider)

            // Buttonlar
            HStack(spacing: 12) {
                Button(action: { onReject?() }) {
                    Text("Ýatyrmak")
                        .font(AppFonts.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppColors.error))
                }

                Button(action: { onAccept?() }) {
                    Text("Kabul etmek")
                        .font(AppFonts.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppColors.success))
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(AppColors.surface))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.divider, lineWidth: 1))
    }

    private func formatDateTime(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm - dd.MM.yyyy"
        return fmt.string(from: date)
    }
}

#Preview("Invitation") {
    InvitationCard(
        offer: TaskOffer(
            id: "1",
            fromUser: User(
                id: "u1",
                name: "Abdullatif Durdybayew",
                phone: "+993 62445524",
                departmentIds: ["iOS Team"]
            ),
            title: "New Task",
            description: "API integration",
            sentAt: Date(),
            status: .pending
        ),
        onAccept: {
            print("Accepted")
        },
        onReject: {
            print("Rejected")
        }
    )
    .padding()
    
    InvitationCard(
        offer: TaskOffer(
            id: "1",
            fromUser: User(
                id: "u1",
                name: "Haknazar Haljanow",
                phone: "+993 XXXXXXXX",
                departmentIds: ["iOS Team"]
            ),
            title: "New Task",
            description: "API integration",
            sentAt: Date(),
            status: .pending
        ),
        onAccept: {
            print("Accepted")
        },
        onReject: {
            print("Rejected")
        }
    )
    .padding()
    .background(AppColors.textPrimary)
    
}
