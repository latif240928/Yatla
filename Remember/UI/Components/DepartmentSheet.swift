// UI/Components/DepartmentSheet.swift
import SwiftUI

struct DepartmentSheet: View {
    @Binding var selectedDepartment: Department?
    @Binding var isPresented: Bool
    @Binding var departments: [Department]
    var onCreateDepartment: ((String) async -> Void)?

    @State private var newDepartmentName: String = ""
    @State private var showAddField: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Bölümler")
                    .font(AppFonts.title3)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider().background(AppColors.divider)

            ScrollView {
                VStack(spacing: 0) {
                    // Hemmesi
                    Button(action: {
                        selectedDepartment = nil
                        isPresented = false
                    }) {
                        HStack {
                            Text("Hemmesi")
                                .font(AppFonts.body)
                                .foregroundColor(.white)
                            Spacer()
                            if selectedDepartment == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }

                    Divider().background(AppColors.divider).padding(.horizontal, 20)

                    // Şahsy — constant, hemise in yokarda
                    Button(action: {
                        selectedDepartment = Department.sahsy
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(AppColors.primary)
                                .frame(width: 20)
                            Text("Şahsy")
                                .font(AppFonts.body)
                                .foregroundColor(.white)
                            Spacer()
                            if selectedDepartment?.id == "sahsy" {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }

                    Divider().background(AppColors.divider).padding(.horizontal, 20)

                    // Beyleki departmanlar
                    ForEach(departments) { dept in
                        Button(action: {
                            selectedDepartment = dept
                            isPresented = false
                        }) {
                            HStack {
                                Text(dept.name)
                                    .font(AppFonts.body)
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedDepartment?.id == dept.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                        Divider().background(AppColors.divider).padding(.horizontal, 20)
                    }
                }
            }

            Divider().background(AppColors.divider)

            // Bölüm gosmak
            if showAddField {
                HStack(spacing: 12) {
                    TextField("Bölüm ady...", text: $newDepartmentName)
                        .font(AppFonts.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppColors.surfaceAlt)
                        .cornerRadius(8)

                    Button(action: {
                        guard !newDepartmentName.isEmpty else { return }
                        let name = newDepartmentName
                        newDepartmentName = ""
                        showAddField = false
                        Task { await onCreateDepartment?(name) }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            } else {
                Button(action: { showAddField = true }) {
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(AppColors.primary)
                        Text("Bölüm goşmak")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
            }

            Button(action: { isPresented = false }) {
                Text("Ýap")
                    .font(AppFonts.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(RoundedRectangle(cornerRadius: 12).fill(AppColors.surfaceLight))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(AppColors.surface)
        .cornerRadius(20)
        .preferredColorScheme(.dark)
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
            Color.black.ignoresSafeArea()
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
