// UI/Components/StatusSheet.swift
import SwiftUI

/// Status/Process popup
struct StatusSheet: View {
    @Binding var selectedStatus: TaskStatus?
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Durum")
                    .font(AppFonts.title3)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider()
                .background(AppColors.divider)

            // "Hemmesi"
            Button(action: {
                selectedStatus = nil
                isPresented = false
            }) {
                HStack {
                    Circle()
                        .fill(AppColors.textSecondary)
                        .frame(width: 10, height: 10)
                    Text("Hemmesi")
                        .font(AppFonts.body)
                        .foregroundColor(.white)
                    Spacer()
                    if selectedStatus == nil {
                        Image(systemName: "checkmark")
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }

            Divider().background(AppColors.divider).padding(.horizontal, 20)

            // Ahli yagdaylar
            ForEach(TaskStatus.allCases, id: \.self) { status in
                Button(action: {
                    selectedStatus = status
                    isPresented = false
                }) {
                    HStack {
                        Circle()
                            .fill(status.color)
                            .frame(width: 10, height: 10)
                        Text(status.displayName)
                            .font(AppFonts.body)
                            .foregroundColor(.white)
                        Spacer()
                        if selectedStatus == status {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }

                if status != TaskStatus.allCases.last {
                    Divider().background(AppColors.divider).padding(.horizontal, 20)
                }
            }

            // Yza çykmak
            Button(action: { isPresented = false }) {
                Text("Ýap")
                    .font(AppFonts.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.surfaceLight)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(AppColors.surface)
        .cornerRadius(20)
        .preferredColorScheme(.dark)
    }
}
