// UI/Features/Settings/ProfileView.swift
//
// Kendi profil ekranı. `UserPublicProfileView`'dan farkları:
//   • Kullanıcı avatarını (PhotosPicker) ve görünen adını güncelleyebilir.
//   • Telefon numarası kilitlidir çünkü değiştirmek SMS yeniden doğrulaması
//     gerektirir — bu arka uç tarafından her halükarda zorunlu kılınır.
//   • Şifre satırı + "Üýtgetmek" kaydet düğmesi kaldırıldı (ad alanı onayda
//     otomatik kaydedilir, bkz. `commitName`).
//   • Departmanlar salt okunur rozetler olarak gösterilir; yöneticiler üyelikleri yönetir.

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @ObservedObject var vm: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var pickedAvatar: PhotosPickerItem? = nil
    @State private var avatarData: Data? = nil
    @FocusState private var nameFocused: Bool

    private var lang: Language { vm.settings.selectedLanguage }

    @EnvironmentObject private var container: DIContainer
    @State private var allDepartments: [Department] = []

    private var departmentNames: [String] {
        return vm.profile.departmentIds.compactMap { id in
            allDepartments.first(where: { $0.id == id })?.name
        }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    avatarBlock
                    nameCard
                    phoneCard
                    if !departmentNames.isEmpty {
                        departmentsCard
                    }
                    if vm.isSaved {
                        savedToast
                    }
                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationTitle(L10n.string(.profileTitle, language: lang))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            name = vm.profile.name
            if let urlString = vm.profile.imageURL,
               let url = URL(string: urlString),
               let data = try? Data(contentsOf: url) {
                avatarData = data
            }
        }
        .task {
            if let depts = try? await container.departmentRepository.getDepartments() {
                allDepartments = depts
            }
        }
        .onChange(of: pickedAvatar) { _, newItem in
            Task {
                guard let item = newItem,
                      let data = try? await item.loadTransferable(type: Data.self),
                      let url = persistAvatar(data: data) else { return }
                avatarData = data
                vm.updateAvatar(localFileURL: url)
            }
        }
    }

    // MARK: - Bölümler

    private var avatarBlock: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.primary.opacity(0.25),
                                AppColors.primary.opacity(0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)

                if let data = avatarData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } else {
                    Text(vm.profile.name.prefix(2).uppercased())
                        .font(AppFonts.aestetico(size: 36, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }
            }
            .overlay(
                Circle().stroke(AppColors.surface, lineWidth: 4)
            )
            .shadow(color: AppColors.shadowColor(opacity: 0.1), radius: 14, y: 6)

            PhotosPicker(selection: $pickedAvatar, matching: .images) {
                HStack(spacing: 6) {
                    Image(systemName: "camera.fill")
                    Text(L10n.string(.profileAddPhoto, language: lang))
                }
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(AppColors.primaryLight)
                .cornerRadius(12)
            }
        }
        .padding(.top, 6)
    }

    private var nameCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.string(.profileNameLabel, language: lang))
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)

            HStack {
                TextField(L10n.string(.profileNameLabel, language: lang), text: $name)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .onSubmit { commitName() }
                if name != vm.profile.name && !name.isEmpty {
                    Button(action: commitName) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.success)
                            .font(AppFonts.aestetico(size: 22))
                    }
                }
            }
            .padding(14)
            .background(AppColors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        nameFocused ? AppColors.borderFocused : AppColors.divider,
                        lineWidth: nameFocused ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.18), value: nameFocused)
        }
    }

    private var phoneCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.string(.profilePhoneLabel, language: lang))
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)

            HStack {
                Text(vm.profile.phone)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textHint)
                Spacer()
                Image(systemName: "lock.fill")
                    .foregroundColor(AppColors.textHint)
                    .font(AppFonts.aestetico(size: 13))
            }
            .padding(14)
            .background(AppColors.surface.opacity(0.6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.divider, lineWidth: 1)
            )
        }
    }

    private var departmentsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.string(.profileDepartmentsLabel, language: lang))
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)

            FlowLayout(spacing: 6) {
                ForEach(departmentNames, id: \.self) { dept in
                    HStack(spacing: 6) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text(dept)
                            .font(AppFonts.caption1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.primaryLight)
                    .foregroundColor(AppColors.primary)
                    .cornerRadius(10)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.divider, lineWidth: 1)
        )
    }

    private var savedToast: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
            Text(L10n.string(.profileSaved, language: lang))
                .font(AppFonts.subheadline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(AppColors.success)
        .cornerRadius(12)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - İşlemler

    private func commitName() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed != vm.profile.name else { return }
        vm.updateProfile(name: trimmed)
        nameFocused = false
    }

    /// Seçilen avatar baytlarını önbellek dizinine kaydeder ve dosya URL'sini
    /// döner. View model bu URL'yi alır ve yükleme hattı bağlanana kadar
    /// mevcut avatar referansı olarak kullanır.
    private func persistAvatar(data: Data) -> URL? {
        let filename = "avatar-\(UUID().uuidString).jpg"
        let url = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}
