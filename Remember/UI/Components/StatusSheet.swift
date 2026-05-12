// UI/Components/StatusSheet.swift
import SwiftUI

struct StatusSheet: View {
    @Binding var selectedStatus: TaskStatus?
    @Binding var isPresented: Bool
    @EnvironmentObject private var container: DIContainer

    private var lang: Language { container.appSettings.selectedLanguage }

    var body: some View {
        VStack(spacing: 0) {
            SheetGrabber()

            HStack {
                Text(L10n.string(.status, language: lang))
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)

            Divider().background(AppColors.divider)

            SheetCheckmarkOptionRow(
                leading: .statusDot(AppColors.textSecondary),
                title: L10n.string(.deptPickerAll, language: lang),
                horizontalInset: 20,
                isSelected: selectedStatus == nil
            ) {
                selectedStatus = nil
                isPresented = false
            }

            SheetInsetDivider(horizontalInset: 20)

            ForEach(TaskStatus.allCases, id: \.self) { status in
                SheetCheckmarkOptionRow(
                    leading: .statusDot(status.color),
                    title: status.displayName(language: lang),
                    horizontalInset: 20,
                    isSelected: selectedStatus == status
                ) {
                    selectedStatus = status
                    isPresented = false
                }

                if status != TaskStatus.allCases.last {
                    SheetInsetDivider(horizontalInset: 20)
                }
            }

            Spacer(minLength: 12)

            SheetOutlineActionButton(title: L10n.string(.actionClose, language: lang)) { isPresented = false }
                .padding(.horizontal, AppSpacing.l)
                .padding(.bottom, AppSpacing.l)
        }
        .background(AppColors.surface.ignoresSafeArea())
    }
}
