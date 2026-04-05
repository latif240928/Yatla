//UI/Features/Users/Components/AddUserSheet
import SwiftUI

struct AddUserSheet: View {
    @Binding var isPresented: Bool
    let departments: [Department]
    var onInvite: ((String, String, Department) -> Void)?

    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var selectedDepartment: Department? = nil
    @State private var showDeptPicker: Bool = false

    var isValid: Bool {
        !name.isEmpty && !phone.isEmpty && selectedDepartment != nil
    }

    var body: some View {
        ZStack {
            AppColors.background.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: 20) {
                Text("Ulanyjy goşmak")
                    .font(AppFonts.title3)
                    .foregroundColor(.white)

                // At
                TextField("Ulanyjy ady", text: $name)
                    .font(AppFonts.body)
                    .foregroundColor(.white)
                    .padding(14)
                    .background(AppColors.surface)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))

                // Telefon
                TextField("Telefon nomery", text: $phone)
                    .font(AppFonts.body)
                    .foregroundColor(.white)
                    .keyboardType(.phonePad)
                    .padding(14)
                    .background(AppColors.surface)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))

                // Department saylayjy
                Button(action: { showDeptPicker = true }) {
                    HStack {
                        Text(selectedDepartment?.name ?? "Iş bölümi saýlamak")
                            .font(AppFonts.body)
                            .foregroundColor(selectedDepartment != nil ? .white : AppColors.textHint)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(14)
                    .background(AppColors.surface)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))
                }

                // Buttonlar
                HStack(spacing: 12) {
                    Button(action: { isPresented = false }) {
                        Text("Yza çykmak")
                            .font(AppFonts.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(RoundedRectangle(cornerRadius: 12).fill(AppColors.surfaceLight))
                    }

                    Button(action: {
                        guard let dept = selectedDepartment else { return }
                        onInvite?(name, phone, dept)
                        isPresented = false
                    }) {
                        Text("Çagyrmak")
                            .font(AppFonts.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isValid ? AppColors.success : AppColors.buttonDisabled)
                            )
                    }
                    .disabled(!isValid)
                }
            }
            .padding(24)
            .background(RoundedRectangle(cornerRadius: 20).fill(AppColors.surface))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColors.primary.opacity(0.3), lineWidth: 1))
            .padding(.horizontal, 24)
        }
        .sheet(isPresented: $showDeptPicker) {
            DepartmentPickerMini(
                departments: departments,
                selectedDepartment: $selectedDepartment,
                isPresented: $showDeptPicker
            )
            .presentationDetents([.medium])
            .preferredColorScheme(.dark)
        }
    }
}

#Preview("Filled") {
    AddUserSheetPreviewFilledWrapper()
}

private struct AddUserSheetPreviewFilledWrapper: View {
    @State private var isPresented: Bool = true

    var body: some View {
        AddUserSheet(
            isPresented: $isPresented,
            departments: [
                Department(id: "1", name: "iOS Team")
            ],
            onInvite: { _,_,_ in }
        )
        .background(AppColors.background)
        .preferredColorScheme(.dark)
    }
}
