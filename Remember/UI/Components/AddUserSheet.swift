// UI/Components/AddUserSheet.swift
//
// Yeni kullanıcı davet etmek için alt sayfa. ChatsView ve UsersView
// tarafından `.sheet(isPresented:)` ile aynı şekilde kullanılır.
// Görünüm kasıtlı olarak düz bir içerik gövdesidir — `.sheet` zaten
// karartma katmanını ve kapatma hareketini sağlar, bu yüzden iç içe
// `ZStack { AppColors.overlay … }` olmamalıdır.
import SwiftUI

struct AddUserSheet: View {
    @Binding var isPresented: Bool
    let departments: [Department]
    var onInvite: ((String, String, Department) -> Void)?
    @EnvironmentObject private var container: DIContainer

    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var selectedDepartment: Department? = nil
    @State private var showDeptPicker: Bool = false
    @FocusState private var focusedField: Field?

    private var lang: Language { container.appSettings.selectedLanguage }

    private enum Field { case name, phone }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !phone.trimmingCharacters(in: .whitespaces).isEmpty
            && selectedDepartment != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetGrabber(bottomPadding: 16)

            Text(L10n.string(.addUserTitle, language: lang))
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
                .padding(.top, 4)
                .padding(.bottom, 20)

            VStack(spacing: 12) {
                inputField(
                    placeholder: L10n.string(.addUserName, language: lang),
                    text: $name,
                    field: .name,
                    keyboard: .default
                )

                inputField(
                    placeholder: L10n.string(.addUserPhone, language: lang),
                    text: $phone,
                    field: .phone,
                    keyboard: .phonePad
                )

                departmentPickerRow
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 16)

            HStack(spacing: 12) {
                SheetOutlineActionButton(title: L10n.string(.addUserCancel, language: lang)) { isPresented = false }

                SheetGradientActionButton(title: L10n.string(.addUserInvite, language: lang), isEnabled: isValid) {
                    handleInvite()
                }
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppColors.surface.ignoresSafeArea())
        .sheet(isPresented: $showDeptPicker) {
            DepartmentPickerMini(
                departments: departments,
                selectedDepartment: $selectedDepartment,
                isPresented: $showDeptPicker
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - Alt görünümler

    private func inputField(
        placeholder: String,
        text: Binding<String>,
        field: Field,
        keyboard: UIKeyboardType
    ) -> some View {
        TextField(placeholder, text: text)
            .font(AppFonts.body)
            .foregroundColor(AppColors.textPrimary)
            .keyboardType(keyboard)
            .focused($focusedField, equals: field)
            .padding(14)
            .background(AppColors.surfaceLight)
            .clipShape(AppShape.inputShape)
            .overlay(
                AppShape.inputShape
                    .stroke(
                        focusedField == field ? AppColors.borderFocused : AppColors.divider,
                        lineWidth: focusedField == field ? AppShape.Stroke.focused : AppShape.Stroke.regular
                    )
            )
            .animation(.easeInOut(duration: 0.18), value: focusedField)
    }

    private var departmentPickerRow: some View {
        Button(action: { showDeptPicker = true }) {
            HStack {
                Text(selectedDepartment?.name ?? L10n.string(.addUserDeptSelect, language: lang))
                    .font(AppFonts.body)
                    .foregroundColor(
                        selectedDepartment != nil
                        ? AppColors.textPrimary
                        : AppColors.textHint
                    )
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(14)
            .background(AppColors.surfaceLight)
            .clipShape(AppShape.inputShape)
            .overlay(
                AppShape.inputShape
                    .stroke(AppColors.divider, lineWidth: AppShape.Stroke.regular)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - İşlemler

    private func handleInvite() {
        guard let dept = selectedDepartment else { return }
        onInvite?(
            name.trimmingCharacters(in: .whitespaces),
            phone.trimmingCharacters(in: .whitespaces),
            dept
        )
        isPresented = false
    }
}

#Preview("AddUserSheet") {
    Color.black.opacity(0.3)
        .sheet(isPresented: .constant(true)) {
            AddUserSheet(
                isPresented: .constant(true),
                departments: [
                    Department(id: "dept-1", name: "iOS Team"),
                    Department(id: "dept-2", name: "Backend")
                ],
                onInvite: { _, _, _ in }
            )
            .presentationDetents([.medium, .large])
        }
}
