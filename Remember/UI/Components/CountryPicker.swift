// UI/Components/CountryPicker.swift
//
// İki parçalı bileşen:
//   1. `CountryPicker`         – kayıt telefon alanı içinde kullanılan
//                                satır içi buton (bayrak + alan kodu).
//   2. `CountryPickerSheet`    – arama çubuğu ve ~190 ülkelik tam listeyle
//                                yukarı kayan sayfa.
//
// Her ikisi de merkezi tasarım belirteçlerine (`AppShape`, `AppColors`) ve
// `LayoutMetrics` ortamına uyar, böylece seçici iPad'de düzgün ölçeklenir.

import SwiftUI

struct CountryPicker: View {
    @Binding var selectedCountry: Country
    @State private var isPresented = false

    var body: some View {
        Button(action: { isPresented = true }) {
            HStack(spacing: 6) {
                Text(selectedCountry.flag)
                    .font(.system(size: 20))
                Text(selectedCountry.dialCode)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, AppSpacing.m)
            .frame(height: 52)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isPresented) {
            CountryPickerSheet(
                selectedCountry: $selectedCountry,
                isPresented: $isPresented
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
    }
}

// MARK: - Seçici sayfası

struct CountryPickerSheet: View {
    @Binding var selectedCountry: Country
    @Binding var isPresented: Bool
    @State private var query: String = ""
    @FocusState private var searchFocused: Bool
    @EnvironmentObject private var container: DIContainer

    private var lang: Language { container.appSettings.selectedLanguage }

    private var filtered: [Country] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return Country.all }
        return Country.all.filter { $0.matches(query: trimmed) }
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetGrabber(bottomPadding: 6)
            header
            searchBar
            Divider().background(AppColors.divider)
            list
        }
        .background(AppColors.surface.ignoresSafeArea())
    }

    // MARK: - Parçalar

    private var header: some View {
        HStack {
            Text(L10n.string(.countryPickerTitle, language: lang))
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(AppColors.surfaceLight)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.top, AppSpacing.s)
        .padding(.bottom, AppSpacing.m)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textSecondary)
            TextField(
                L10n.string(.search, language: lang),
                text: $query
            )
            .focused($searchFocused)
            .submitLabel(.search)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            if !query.isEmpty {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textHint)
                }
            }
        }
        .padding(.horizontal, AppSpacing.l)
        .padding(.vertical, 10)
        .background(AppColors.surfaceLight)
        .clipShape(AppShape.inputShape)
        .overlay(
            AppShape.inputShape
                .stroke(
                    searchFocused ? AppColors.borderFocused : AppColors.divider,
                    lineWidth: searchFocused ? AppShape.Stroke.focused : AppShape.Stroke.regular
                )
        )
        .padding(.horizontal, AppSpacing.xl)
        .padding(.bottom, AppSpacing.m)
        .animation(.easeInOut(duration: 0.18), value: searchFocused)
    }

    private var list: some View {
        Group {
            if filtered.isEmpty {
                VStack(spacing: 10) {
                    Spacer().frame(height: 40)
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(AppColors.textHint)
                    Text(L10n.string(.noResults, language: lang))
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filtered, id: \.self) { country in
                            row(for: country)
                            Divider()
                                .background(AppColors.divider)
                                .padding(.leading, 60)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func row(for country: Country) -> some View {
        let isSelected = country == selectedCountry
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            selectedCountry = country
            isPresented = false
        } label: {
            HStack(spacing: 14) {
                Text(country.flag)
                    .font(.system(size: 24))
                    .frame(width: 32, height: 32)
                    .background(AppColors.surfaceLight)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(country.name)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    Text(country.iso2)
                        .font(AppFonts.caption2)
                        .foregroundColor(AppColors.textHint)
                }
                Spacer()
                Text(country.dialCode)
                    .font(AppFonts.subheadline.bold())
                    .foregroundColor(AppColors.textSecondary)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, 12)
            .background(isSelected ? AppColors.primary.opacity(0.06) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}
