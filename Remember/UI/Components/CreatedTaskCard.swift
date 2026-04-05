// UI/Components/CreatedTaskCard.swift
import SwiftUI

// MARK: - "İş döretmek" bölümi ucin task kardy
struct CreatedTaskCard: View {
    let task: TaskItem
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Header + Chevron
                HStack(alignment: .center) {
                    Text(task.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.bottom, 12)

                // MARK: - gok divider çyzgy
                Rectangle()
                    .fill(AppColors.primary.opacity(0.4))
                    .frame(height: 1)
                    .padding(.bottom, 12)

                // MARK: - Description (italik)
                Text(task.description.isEmpty ? "Mazmuny ýok" : task.description)
                    .font(.system(size: 13, weight: .regular).italic())
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
                    .padding(.bottom, 14)

                // MARK: - Ulanyjylar listi — hakyky maglumatlardan
                if !task.assignees.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(task.assignees.prefix(3).enumerated()), id: \.element.id) { index, assignee in
                            HStack(spacing: 0) {
                                // Cep: nomer + ulanyjy ady
                                Text("\(index + 1).\(assignee.user.name)")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white)
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color(hex: assignee.status.colorHex))
                                        .frame(width: 8, height: 8)
                                    Text(assignee.status.displayName)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        if task.assignees.count > 3 {
                            Text("+\(task.assignees.count - 3) adam")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textHint)
                        }
                    }
                    .padding(.bottom, 14)
                }

                // MARK: - Date pill
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.primary)
                    Text(formatDateRange(start: task.startDate, end: task.dueDate))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .overlay(
                    Capsule()
                        .stroke(AppColors.primary.opacity(0.6), lineWidth: 1)
                )
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.primary.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Date format: 09.02.2026r
    private func formatDateRange(start: Date, end: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd.MM.yyyy"
        return "\(fmt.string(from: start)) - \(fmt.string(from: end))"
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ForEach(TaskItem.createdMockList) { task in
                CreatedTaskCard(task: task)
            }
        }
        .padding(16)
    }
    .background(AppColors.background)
    .preferredColorScheme(.dark)
}
