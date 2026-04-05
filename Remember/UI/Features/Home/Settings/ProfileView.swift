// UI/Features/Settings/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @ObservedObject var vm: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var showPasswordChange: Bool = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // Avatar
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary.opacity(0.2))
                                .frame(width: 100, height: 100)
                            Image(systemName: "person.fill")
                                .font(.system(size: 44))
                                .foregroundColor(AppColors.primary)
                        }
                        Button("Surat goş") { /* image picker */ }
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primary)
                    }
                    .padding(.top, 10)

                    // At
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Adyňyz")
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textSecondary)
                        TextField("Adyňyz", text: $name)
                            .font(AppFonts.body)
                            .foregroundColor(.white)
                            .padding(14)
                            .background(AppColors.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.divider, lineWidth: 1)
                            )
                    }

                    // Telefon
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Telefon")
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textSecondary)
                        HStack {
                            Text(vm.profile.phone)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textHint)
                            Spacer()
                            Image(systemName: "lock.fill")
                                .foregroundColor(AppColors.textHint)
                                .font(.system(size: 13))
                        }
                        .padding(14)
                        .background(AppColors.surface.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )
                    }

                    // password
                    Button(action: { showPasswordChange = true }) {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.orange)
                            Text("Açar sözi üýtgetmek")
                                .font(AppFonts.body)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textSecondary)
                                .font(.system(size: 13))
                        }
                        .padding(14)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                    }

                    // save
                    Button(action: {
                        vm.updateProfile(name: name)
                        dismiss()
                    }) {
                        HStack {
                            if vm.isSaved {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                Text("Saklandy!")
                            } else {
                                Text("Üýtgetmek")
                            }
                        }
                        .font(AppFonts.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(name == vm.profile.name
                                      ? AppColors.buttonDisabled
                                      : AppColors.primary)
                        )
                    }
                    .disabled(name == vm.profile.name)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { name = vm.profile.name }
    }
}
