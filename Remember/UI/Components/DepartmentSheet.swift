// UI/Components/DepartmentSheet.swift
import SwiftUI

struct DepartmentSheet: View {
    @Binding var selectedDepartment: Department?
    @Binding var isPresented: Bool
    @Binding var departments: [Department]
    var onCreateDepartment: ((String) async -> Void)?
    @EnvironmentObject private var container: DIContainer

    @State private var newDepartmentName: String = ""
    @State private var showAddField: Bool = false

    private var lang: Language { container.appSettings.selectedLanguage }

    var body: some View {
        VStack(spacing: 0) {
            SheetGrabber()

            HStack {
                Text(L10n.string(.deptPickerTitle, language: lang))
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.top, AppSpacing.m)
            .padding(.bottom, AppSpacing.m)

            Divider().background(AppColors.divider)

            ScrollView {
                VStack(spacing: 0) {
                    SheetCheckmarkOptionRow(
                        leading: .none,
                        title: L10n.string(.deptPickerAll, language: lang),
                        horizontalInset: AppSpacing.l,
                        isSelected: selectedDepartment == nil
                    ) {
                        selectedDepartment = nil
                        isPresented = false
                    }

                    SheetInsetDivider(horizontalInset: AppSpacing.l)

                    SheetCheckmarkOptionRow(
                        leading: .symbol(name: "person.fill", foreground: AppColors.primary, width: 20),
                        title: L10n.string(.createTaskPersonal, language: lang),
                        horizontalInset: AppSpacing.l,
                        isSelected: selectedDepartment?.id == "sahsy"
                    ) {
                        selectedDepartment = Department.sahsy
                        isPresented = false
                    }

                    SheetInsetDivider(horizontalInset: AppSpacing.l)

                    ForEach(departments) { dept in
                        SheetCheckmarkOptionRow(
                            leading: .none,
                            title: dept.name,
                            horizontalInset: AppSpacing.l,
                            isSelected: selectedDepartment?.id == dept.id
                        ) {
                            selectedDepartment = dept
                            isPresented = false
                        }
                        SheetInsetDivider(horizontalInset: AppSpacing.l)
                    }
                }
            }

            Divider().background(AppColors.divider)

            if showAddField {
                HStack(spacing: 12) {
                    TextField(L10n.string(.createTaskNewDept, language: lang), text: $newDepartmentName)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, AppSpacing.m)
                        .padding(.vertical, 10)
                        .background(AppColors.surfaceLight)
                        .clipShape(AppShape.inputShape)
                        .overlay(
                            AppShape.inputShape
                                .stroke(AppColors.divider, lineWidth: AppShape.Stroke.regular)
                        )

                    Button(action: {
                        guard !newDepartmentName.isEmpty else { return }
                        let name = newDepartmentName
                        newDepartmentName = ""
                        showAddField = false
                        Task { await onCreateDepartment?(name) }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(AppFonts.aestetico(size: 28))
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal, AppSpacing.l)
                .padding(.vertical, AppSpacing.m)
            } else {
                Button(action: { showAddField = true }) {
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(AppColors.primary)
                        Text(L10n.string(.createTaskNewDept, language: lang))
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primary)
                    }
                    .padding(.horizontal, AppSpacing.l)
                    .padding(.vertical, 14)
                }
            }

            SheetOutlineActionButton(title: L10n.string(.actionClose, language: lang)) { isPresented = false }
                .padding(.horizontal, AppSpacing.l)
                .padding(.vertical, AppSpacing.m)
        }
        // `.cornerRadius` yok: sistem sayfası zaten yuvarlatılmış üst köşeleri
        // sağlıyor, kendi köşelerimizi eklemek görünür bir çift kenar bırakır.
        .background(AppColors.surface.ignoresSafeArea())
    }
}

#Preview {
    DepartmentSheetPreviewWrapper()
}

struct DepartmentSheetPreviewWrapper: View {
    @State private var selectedDepartment: Department? = nil
    @State private var isPresented: Bool = true
    @State private var departments: [Department] = [
        Department(id: "1", name: "Maliýe"),
        Department(id: "2", name: "IT"),
        Department(id: "3", name: "Marketing"),
    ]

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            DepartmentSheet(
                selectedDepartment: $selectedDepartment,
                isPresented: $isPresented,
                departments: $departments,
                onCreateDepartment: { name in
                    departments.append(Department(id: UUID().uuidString, name: name))
                }
            )
            .padding()
        }
    }
}
